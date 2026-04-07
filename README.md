# nix-config

Declarative macOS configuration using `nix-darwin`, `home-manager`, and `sops-nix`. Supports Apple Silicon.

Everything — shell, tools, editor, fonts, apps, system settings — is managed from this repo. A single command rebuilds the entire system.

---

## Contents

- [How it works](#how-it-works)
- [Project structure](#project-structure)
- [Setup](#setup)
  - [New machine](#new-machine)
  - [Existing machine](#existing-machine)
- [Day-to-day](#day-to-day)
- [Secrets](#secrets)
  - [Rotating your SSH key](#rotating-your-ssh-key)
  - [Recovery](#recovery)

---

## How it works

| Layer | Tool | What it manages |
|---|---|---|
| System | `nix-darwin` | macOS settings, fonts, Homebrew, system packages |
| User | `home-manager` | Shell, dev tools, git, SSH, editor config |
| Secrets | `sops-nix` | SSH keys, API tokens — encrypted at rest |
| Apps | `homebrew` | GUI apps (casks) and Mac App Store apps |

Run `rebuild` → Nix computes what changed → applies atomically. If something breaks, roll back.

### Secrets

Secrets are encrypted with `age`. A standalone age key lives at `~/.config/sops/age/keys.txt` — this is the master decryption key. On every build, sops-nix uses it to decrypt `secrets.enc.yaml` and place secrets at their configured paths (e.g. `~/.ssh/id_ed25519`).

> **Back up `keys.txt` immediately after generating it** — save it to the macOS Passwords app, 1Password, or similar. This file is not managed by Nix and is never committed to git. Losing it means losing access to all your secrets.

---

## Project structure

```
nix-config/
├── flake.nix                        # Entry point — defines all machines
├── flake.lock                       # Pinned dependency versions
├── .sops.yaml                       # Which age keys can decrypt which secrets
├── hosts/
│   ├── common/
│   │   ├── darwin-common.nix        # Shared macOS settings, Homebrew, fonts
│   │   └── common-packages.nix      # System-wide CLI tools
│   └── darwin/
│       └── <machine>/               # Machine-specific config
├── home-manager/
│   ├── profiles/
│   │   ├── base.nix                 # Shell, git, SSH, aliases, env vars
│   │   └── <machine>.nix            # Machine-specific home config
│   └── programs/                    # rust, node, git, nix LSP, iterm2...
├── assets/                          # starship, raycast, wallpapers...
├── secrets/
│   ├── <machine>/secrets.enc.yaml   # Encrypted machine secrets
│   └── secrets_example.yaml         # Template
└── templates/                       # Flake templates (node, esp32)
```

---

## Setup

> **Which path?**
> - [New machine](#new-machine) — not yet in `flake.nix`
> - [Existing machine](#existing-machine) — already in `flake.nix`, restoring or reinstalling

---

### New machine

#### 1. Install prerequisites

```sh
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after Nix installs.

#### 2. Generate an SSH key and add it to GitHub

This key will be stored as an encrypted secret and managed by Nix after the first build.

```sh
ssh-keygen -t ed25519 -C "you@email.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub   # add this to github.com → Settings → SSH and GPG keys
```

#### 3. Clone this repo

```sh
git clone git@github.com:utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

#### 4. Open the bootstrap shell

```sh
nix develop
```

This gives you `sops`, `age`, and related tools before the first build.

#### 5. Generate your age key

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt   # note this public key — needed in next step
```

> **Back this up now.** Save `~/.config/sops/age/keys.txt` to the macOS Passwords app or 1Password before continuing.

#### 6. Set the hostname

```sh
sudo scutil --set HostName <your-machine>
sudo scutil --set LocalHostName <your-machine>
```

#### 7. Register the machine in the repo

**`flake.nix`** — add under `darwinConfigurations`:
```nix
<your-machine> = libx.mkDarwin { hostname = "<your-machine>"; };
```

**`.sops.yaml`** — add the age public key from step 5:
```yaml
- path_regex: ^secrets/<your-machine>/.*\.yaml$
  key_groups:
    - age:
        - age1abc123...   # public key from step 5
```

**`hosts/darwin/<your-machine>/default.nix`**:
```nix
{ config, username, pkgs, lib, ... }:
{
  sops = {
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../../secrets/${config.networking.hostName}/secrets.enc.yaml;

    secrets."ssh_key" = {
      path = "/Users/${username}/.ssh/id_ed25519";
      owner = username;
      mode = "0600";
    };
  };
}
```

> Do not add `age.sshKeyPaths` pointing at `~/.ssh/id_ed25519`. That creates a circular dependency — sops needs the SSH key to decrypt secrets, but the SSH key is itself a secret. Use `age.keyFile` only.

**`home-manager/profiles/<your-machine>.nix`**:
```nix
{ ... }:
{
  imports = [ ./base.nix ];
}
```

#### 8. Create and encrypt secrets

```sh
mkdir -p secrets/<your-machine>
cp secrets/secrets_example.yaml /tmp/secrets.yaml
```

Edit `/tmp/secrets.yaml` — paste the contents of `~/.ssh/id_ed25519` as the `ssh_key` value.

```sh
nix shell nixpkgs#sops --command sops --encrypt /tmp/secrets.yaml > secrets/<your-machine>/secrets.enc.yaml
rm /tmp/secrets.yaml   # never commit the unencrypted file
```

> After the first build, use `nix run .#edit-secrets -- <your-machine>` to edit secrets instead.

#### 9. First build

`darwin-rebuild` doesn't exist yet — use this bootstrap:

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After this, `nix run .#rebuild` works for all future updates.

> If you see `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'`, run `sudo ssh-keygen -A` and rebuild.

---

### Existing machine

Use this when the machine is already defined in `flake.nix` — reinstalling or restoring.

#### 1. Install prerequisites

```sh
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after Nix installs.

#### 2. Restore your age key

sops-nix needs `~/.config/sops/age/keys.txt` to decrypt secrets during the build.

```sh
mkdir -p ~/.config/sops/age
# paste the key from your backup (Passwords app, 1Password, etc.)
nano ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

> If you've lost the age key, stop here and follow the [full recovery](#if-both-keys-are-lost--full-reset) steps instead.

#### 3. Clone this repo

> You need an SSH key to clone via SSH. Your SSH key will be deployed by sops-nix after the build — but to get there you need to clone first. Options:
> - Clone via HTTPS: `git clone https://github.com/utopiaeh/nix-config.git ~/nix-config`
> - Or place a temporary SSH key: check your GitHub **Settings → SSH and GPG keys** for the public key, restore the private key from backup if available

```sh
git clone https://github.com/utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

#### 4. Verify hostname

```sh
scutil --get LocalHostName   # must match what's in flake.nix
```

To change it:
```sh
sudo scutil --set HostName <your-machine>
sudo scutil --set LocalHostName <your-machine>
```

#### 5. First build

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After a successful build, sops-nix places your SSH key at `~/.ssh/id_ed25519`. Add the public key to GitHub if you haven't already:

```sh
cat ~/.ssh/id_ed25519.pub   # add to github.com → Settings → SSH and GPG keys
ssh -T git@github.com       # verify
```

---

## Day-to-day

### Rebuild

```sh
nix run .#rebuild                                    # apply config changes
nix flake update && nix run .#rebuild                # update all dependencies
nix flake update rust-overlay && nix run .#rebuild   # update one input
nix run .#rollback                                   # roll back to previous generation
nix run .#cleanup                                    # garbage collect (older than 14 days)
nix run .#edit-secrets -- <machine>                  # edit encrypted secrets
darwin-rebuild --list-generations                    # list all generations
```

### Shell aliases

| Command | What it does |
|---|---|
| `fix-sound` | Restarts the macOS audio daemon |
| `idea [path]` | Opens a project in IntelliJ IDEA |
| `dev` | `cd ~/Developer` |
| `lg` | Opens lazygit |
| `, <package>` | Runs a Nix package without installing it |
| `tpl-node` | Initializes a Node.js project from template |
| `tpl-esp32` | Initializes an ESP32-S3 Rust project from template |

The `,` command is especially useful — e.g. `, ffmpeg -i video.mp4 output.gif`. Downloaded on first use, cached for reuse, nothing stays on your PATH permanently.

### Where to add things

| What | Where |
|---|---|
| New GUI app | `homebrew.casks` in `darwin-common.nix` |
| New CLI tool (system-wide) | `environment.systemPackages` in `common-packages.nix` |
| New CLI tool (personal) | `home.packages` in `base.nix` |
| Shell alias | `programs.zsh.shellAliases` in `base.nix` |
| Environment variable | `home.sessionVariables` in `base.nix` |
| Machine-specific package | `hosts/darwin/<machine>/default.nix` |

### Post-build manual steps

- **iTerm2** — if theme or font looks wrong, quit and reopen
- **Raycast** — import settings manually from `assets/raycast/`
- **FlashSpace** — config applied automatically from `home-manager/programs/flashspace/`
- **MiddleClick** — enable in Accessibility settings
- **AltTab / BetterDisplay** — grant Screen Recording permission

### Project templates

```sh
mkdir -p ~/Developer/my-app && cd ~/Developer/my-app
tpl-node        # Node.js (pnpm, typescript)
tpl-esp32       # ESP32-S3 Rust project
direnv allow    # load dev environment
```

---

## Secrets

### Rotating your SSH key

The age key in `keys.txt` is independent of the SSH key — rotating SSH only requires updating the secret value. No `.sops.yaml` changes needed.

#### 1. Generate a new SSH key pair

```sh
ssh-keygen -t ed25519 -f /tmp/new_ssh_key -N "" -C "you@email.com"
```

> Saves to `/tmp` because `~/.ssh/id_ed25519` is a symlink managed by sops-nix.

#### 2. Update the secret

```sh
nix run .#edit-secrets -- <your-machine>
```

Replace the `ssh_key` value with the contents of `/tmp/new_ssh_key`, save and close.

#### 3. Rebuild

```sh
nix run .#rebuild
```

#### 4. Update the public key file

sops-nix only manages the private key — the public key file won't update automatically.

```sh
ssh-keygen -yf /run/secrets/ssh_key > ~/.ssh/id_ed25519.pub
ssh-add -D && ssh-add ~/.ssh/id_ed25519
```

#### 5. Update GitHub

Go to **github.com → Settings → SSH and GPG keys**, add the new public key, remove the old one.

```sh
ssh -T git@github.com   # verify
```

#### 6. Clean up

```sh
rm /tmp/new_ssh_key /tmp/new_ssh_key.pub
```

---

### Recovery

Use this if sops fails to activate on boot — `~/.ssh/id_ed25519` is missing or broken and you can't push to GitHub.

**Why it happens:** sops-nix decrypts secrets on boot using `keys.txt`. If that file is missing, decryption fails and no secrets are placed.

---

#### If `keys.txt` exists but sops still failed

```sh
# verify decryption works manually
nix shell nixpkgs#sops --command sops --decrypt secrets/<your-machine>/secrets.enc.yaml

# if that works, just rebuild
darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

---

#### If `keys.txt` is lost — restore from backup

```sh
mkdir -p ~/.config/sops/age
nano ~/.config/sops/age/keys.txt   # paste from Passwords app / 1Password
chmod 600 ~/.config/sops/age/keys.txt
darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

---

#### If both keys are lost — full reset

You cannot decrypt the old secrets. Regenerate everything.

**1. Generate a new age key:**
```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt   # note the public key
```

**2. Generate a new SSH key:**
```sh
ssh-keygen -t ed25519 -C "you@email.com" -f /tmp/new_ssh_key -N ""
```

**3. Update `.sops.yaml`** — replace the old age public key with the new one from step 1.

**4. Re-create secrets** — create a plaintext file:
```yaml
# /tmp/secrets.yaml
ssh_key: |
    <contents of /tmp/new_ssh_key>
```

Encrypt it:
```sh
nix shell nixpkgs#sops --command sops --encrypt /tmp/secrets.yaml > secrets/<your-machine>/secrets.enc.yaml
rm /tmp/secrets.yaml
```

**5. Place the SSH key temporarily** so the build can complete:
```sh
cp /tmp/new_ssh_key ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

**6. Rebuild:**
```sh
darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

**7.** Add the new SSH public key to GitHub, remove the old one.

**8. Back up `keys.txt`** to the macOS Passwords app or 1Password.

```sh
rm /tmp/new_ssh_key /tmp/new_ssh_key.pub
```
