# nix-config

Declarative macOS configuration using `nix-darwin`, `home-manager`, and `sops-nix` for secrets. Supports Apple Silicon.

Everything — shell, tools, editor, fonts, apps, system settings — is managed from this repo. A single command rebuilds the entire system.

---

## Contents

- [How it works](#how-it-works)
- [Project structure](#project-structure)
- [Setup](#setup)
  - [New machine](#new-machine) — machine not yet defined in this repo
  - [Existing machine](#existing-machine) — machine already defined, reinstalling or restoring
- [Rebuild & update](#rebuild--update)
- [Regenerating your SSH key](#regenerating-your-ssh-key)
- [Built-in commands](#built-in-commands)
- [Post-build manual steps](#post-build-manual-steps)
- [Day-to-day reference](#day-to-day-reference)
- [Project templates](#project-templates)

---

## How it works

| Layer | Tool | What it manages |
|---|---|---|
| System | `nix-darwin` | macOS settings, fonts, Homebrew apps, system packages |
| User | `home-manager` | Shell, dev tools, git, SSH, editor config |
| Secrets | `sops-nix` | SSH keys, API tokens, encrypted at rest |
| Apps | `homebrew` | GUI apps (casks) and Mac App Store apps |

When you run `rebuild`, Nix reads the config, computes what changed, and applies it atomically. If something breaks, roll back to the previous generation.

Secrets are encrypted using `age`, derived from your SSH key. Your SSH key is the master key for everything — lose it and you lose access to your secrets.

---

## Project structure

```
nix-config/
├── flake.nix                   # Entry point — defines all machines
├── flake.lock                  # Pinned dependency versions
├── .sops.yaml                  # Defines which age keys can decrypt which secrets
├── hosts/
│   ├── common/
│   │   ├── darwin-common.nix   # Shared macOS settings, Homebrew apps, fonts
│   │   └── common-packages.nix # System-wide CLI tools
│   └── darwin/
│       ├── <your-machine>/     # Machine-specific config
│       └── mac-pro/            # Mac Pro config
├── home-manager/
│   ├── profiles/
│   │   ├── base.nix            # User environment (shell, git, SSH, aliases...)
│   │   ├── <your-machine>.nix  # Machine-specific home config
│   │   └── mac-pro.nix         # Mac Pro home config
│   └── programs/
│       ├── rust/               # Rust toolchain + rust-analyzer
│       ├── nix/                # Nix LSP (nixd) + formatter (nixfmt)
│       ├── node/               # Node.js environment
│       ├── git/                # Git config
│       └── iterm2/             # iTerm2 preferences (declarative)
├── assets/
│   ├── starship/               # Prompt config
│   ├── idea/                   # IntelliJ layout
│   ├── raycast/                # Raycast settings (import manually)
│   └── wallpapers/
├── secrets/
│   ├── <your-machine>/         # Machine-specific secrets (ssh_key, tokens)
│   ├── shared/                 # Secrets accessible by all machines
│   └── secrets_example.yaml    # Template for machine secrets
└── templates/                  # Flake templates for new projects
    ├── node-lts/
    └── esp32-rust-project/
```

---

## Setup

> **Which path should I follow?**
>
> - [New machine](#new-machine) — you're setting up a machine that is not yet defined in `flake.nix` (brand new or third machine)
> - [Existing machine](#existing-machine) — the machine is already in `flake.nix`, you're reinstalling or restoring

---

### New machine

Steps 1–6 are shared, then the paths diverge.

#### 1. Install Xcode command line tools

Required for git and other build tools.

```sh
xcode-select --install
```

#### 2. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after installation so `nix` is on your PATH.

#### 3. Generate an SSH key and add it to GitHub

This SSH key will become your permanent key — it will be stored encrypted in the repo and deployed on every rebuild.

```sh
ssh-keygen -t ed25519 -C "utopiaeh01@gmail.com"
```

Copy the public key and add it to GitHub at **Settings → SSH and GPG keys**:

```sh
cat ~/.ssh/id_ed25519.pub
```

#### 4. Clone this repo

```sh
git clone git@github.com:utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

#### 5. Open the bootstrap shell

```sh
nix develop
```

This drops you into a shell with `sops`, `age`, and `ssh-to-age` available — the tools needed to set up secrets before the first build.

#### 6. Derive your age key from your SSH key

sops encrypts secrets using `age`. This step converts your SSH private key into an age private key and saves it locally so sops can decrypt secrets during the build.

```sh
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

Get your age **public** key — you will need it in the next step:

```sh
age-keygen -y ~/.config/sops/age/keys.txt
# outputs something like: age1abc123...
```

#### 7. Set the hostname

```sh
sudo scutil --set HostName <your-machine>
sudo scutil --set LocalHostName <your-machine>
```

#### 8. Register the machine in the repo

**Add it to `flake.nix`** under `darwinConfigurations`:

```nix
<your-machine> = libx.mkDarwin { hostname = "<your-machine>"; };
```

**Add its age public key to `.sops.yaml`** (the key from step 6):

```yaml
- path_regex: ^secrets/<your-machine>/.*\.yaml$
  key_groups:
    - age:
        - age1abc123...
```

**Create the machine config** at `hosts/darwin/<your-machine>/default.nix`:

```nix
{ config, username, pkgs, lib, ... }:
{
  sops = {
    age.sshKeyPaths = [ "/Users/${username}/.ssh/id_ed25519" ];
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

**Create the home-manager profile** at `home-manager/profiles/<your-machine>.nix`:

```nix
{ ... }:
{
  imports = [ ./base.nix ];
}
```

#### 9. Create and encrypt the machine secrets

```sh
mkdir -p secrets/<your-machine>
cp secrets/secrets_example.yaml secrets/<your-machine>/secrets.yaml
```

Open `secrets/<your-machine>/secrets.yaml` and fill in:
- `ssh_key` — paste the full contents of `~/.ssh/id_ed25519`
- any other tokens required

Encrypt it:

```sh
sops -e secrets/<your-machine>/secrets.yaml > secrets/<your-machine>/secrets.enc.yaml
rm secrets/<your-machine>/secrets.yaml
```

> Never commit the unencrypted `.yaml` file — only the `.enc.yaml`.

#### 10. First build

`nix run .#rebuild` calls `darwin-rebuild` internally, which doesn't exist until nix-darwin is installed. Use this two-step bootstrap for the very first build:

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After this completes, `darwin-rebuild` is on your PATH and `nix run .#rebuild` works for all future updates.

> If you see errors like `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'`, run `sudo ssh-keygen -A` and rebuild.

---

### Existing machine

Use this path when the machine is already defined in `flake.nix` — you're reinstalling, restoring, or setting up on the same machine again.

#### 1. Install Xcode command line tools

```sh
xcode-select --install
```

#### 2. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after installation.

#### 3. Add your SSH key to GitHub

If you already have the SSH key (e.g. from a backup), add its public key to GitHub at **Settings → SSH and GPG keys**:

```sh
cat ~/.ssh/id_ed25519.pub
```

If you don't have the key anymore, follow the [new machine](#new-machine) path and regenerate everything.

#### 4. Clone this repo

```sh
git clone git@github.com:utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

#### 5. Open the bootstrap shell

```sh
nix develop
```

#### 6. Restore your age key

sops needs the age private key to decrypt secrets during the build. Regenerate it from your SSH key:

```sh
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

#### 7. Verify hostname

Make sure your hostname matches what's defined in `flake.nix`:

```sh
scutil --get LocalHostName
```

To change it:

```sh
sudo scutil --set HostName <your-machine>
sudo scutil --set LocalHostName <your-machine>
```

#### 8. First build

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

> If you see errors like `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'`, run `sudo ssh-keygen -A` and rebuild.

---

## Rebuild & update

Rebuild after any config change:

```sh
nix run .#rebuild
```

Update all dependencies and rebuild:

```sh
nix flake update && nix run .#rebuild
```

Update a single input (e.g. rust toolchain):

```sh
nix flake update rust-overlay && nix run .#rebuild
```

Roll back to the previous generation:

```sh
nix run .#rollback
```

List all generations:

```sh
darwin-rebuild --list-generations
```

---

## Regenerating your SSH key

The SSH private key is stored as a sops-encrypted secret and deployed by sops-nix to `~/.ssh/id_ed25519` on every rebuild. Because of this, you can't just run `ssh-keygen` — the key is managed by Nix.

The tricky part: sops uses your **current** SSH key (converted to an age key) to decrypt secrets. If you replace the key without a proper transition, sops won't be able to decrypt anything during the next rebuild. The solution is to keep both old and new age keys active during the transition, then remove the old one after the new key is deployed.

#### Step 1 — Generate a new key pair

```sh
ssh-keygen -t ed25519 -f /tmp/new_ssh_key -N "" -C "utopiaeh01@gmail.com"
```

> Saves to `/tmp` because `~/.ssh/id_ed25519` is a symlink managed by sops-nix — you can't write to it directly. `-N ""` means no passphrase.

#### Step 2 — Convert the new SSH key to an age public key

```sh
nix shell nixpkgs#ssh-to-age --command ssh-to-age < /tmp/new_ssh_key.pub
```

> sops doesn't use SSH keys directly — it works with age keys. This converts your new SSH public key into the `age1...` string you'll put in `.sops.yaml`.

#### Step 3 — Add both old and new age keys to `.sops.yaml`

```yaml
- age:
    - age1oldkey...  # old — keep during transition so rebuild can still decrypt
    - age1newkey...  # new
```

> Both keys are needed at this point. The next rebuild will still use the old SSH key (still on disk) to decrypt — removing it now would break the rebuild before the new key is deployed.

#### Step 4 — Re-encrypt secrets with both keys

```sh
sops updatekeys secrets/<your-machine>/secrets.enc.yaml --yes
sops updatekeys secrets/shared/secrets.enc.yaml --yes
```

> Now both old and new age keys can decrypt the secrets files.

#### Step 5 — Update the `ssh_key` secret with the new private key

```sh
sops secrets/<your-machine>/secrets.enc.yaml
```

> Opens the secrets file decrypted in your editor. Replace the `ssh_key` value with the contents of `/tmp/new_ssh_key`, save, and close — sops re-encrypts automatically on exit.

#### Step 6 — Rebuild

```sh
nix run .#rebuild
```

> sops decrypts using the old SSH key (still active on disk), reads the new `ssh_key` value, and writes it to `/run/secrets/ssh_key` → `~/.ssh/id_ed25519`.

#### Step 7 — Update the public key file and refresh the SSH agent

sops-nix only manages the private key — `~/.ssh/id_ed25519.pub` is not updated automatically and will be stale.

```sh
ssh-keygen -yf /run/secrets/ssh_key > ~/.ssh/id_ed25519.pub
ssh-add -D
ssh-add ~/.ssh/id_ed25519
```

#### Step 8 — Add the new key to GitHub and remove the old one

Go to **github.com → Settings → SSH and GPG keys**, add the new public key and delete the old one.

Test the connection:

```sh
ssh -T git@github.com
```

#### Step 9 — Remove the old age key and re-encrypt

Edit `.sops.yaml` to remove the old age key, keeping only the new one. Then re-encrypt:

```sh
sops updatekeys secrets/<your-machine>/secrets.enc.yaml --yes
sops updatekeys secrets/shared/secrets.enc.yaml --yes
```

> Now only the new key can decrypt the secrets. The transition is complete.

#### Step 10 — Clean up temp files

```sh
rm /tmp/new_ssh_key /tmp/new_ssh_key.pub
```

---

## Built-in commands

### Shell aliases

Available in every terminal after rebuild:

| Command | What it does |
|---|---|
| `fix-sound` | Kills and restarts the macOS audio daemon |
| `idea [path]` | Opens a project in IntelliJ IDEA |
| `dev` | `cd ~/Developer` |
| `lg` | Opens lazygit |
| `, package-name` | Runs a Nix package without installing it |
| `tpl-node` | Initializes a Node.js project from the flake template |
| `tpl-esp32` | Initializes an ESP32-S3 Rust project from the flake template |

### The `,` command

Runs any Nix package without installing it. Downloaded on first use, cached for instant reuse. Nothing ends up on your PATH permanently.

```sh
, cowsay hello
, ffmpeg -i video.mp4 output.gif
, python3
```

### Flake apps

| Command | What it does |
|---|---|
| `nix run .#rebuild` | Build and switch to current config |
| `nix run .#rollback` | Roll back to the previous generation |
| `nix run .#cleanup` | Garbage collect generations older than 14 days |

---

## Post-build manual steps

Most configuration is applied automatically on rebuild. A few things require a manual step.

### iTerm2

Preferences are managed declaratively and applied on each rebuild. If the theme or font looks wrong, quit and reopen iTerm2.

Font for macOS Terminal (if preferred over iTerm2):
```
MesloLGL Nerd Font
```

### Raycast

Import settings manually from `assets/raycast/`.

### FlashSpace

Config is applied automatically from `home-manager/programs/flashspace/` on each rebuild.

### Apps requiring permission grants

- **MiddleClick** — enable in Accessibility settings
- **AltTab** — grant Screen Recording permission
- **BetterDisplay** — grant Screen Recording permission

---

## Day-to-day reference

### Where to add things

| What | Where |
|---|---|
| New GUI app | `homebrew.casks` in `darwin-common.nix` |
| New CLI tool (system-wide) | `environment.systemPackages` in `common-packages.nix` |
| New CLI tool (personal) | `home.packages` in `base.nix` |
| Shell alias | `programs.zsh.shellAliases` in `base.nix` |
| Environment variable | `home.sessionVariables` in `base.nix` |
| Machine-specific package | `hosts/darwin/<your-machine>/default.nix` |

### Rust toolchain

Managed via `rust-overlay` in `home-manager/programs/rust/default.nix`. Includes `rust-analyzer`, `rust-src`, and `llvm-tools`. Updates automatically after `nix flake update rust-overlay && nix run .#rebuild`.

### Nix LSP in Zed

`nixd` is configured in `home-manager/programs/nix/default.nix` and Zed is pointed to it via `~/.config/zed/settings.json`. No manual setup needed.

### Clean up disk space

```sh
nix run .#cleanup
```

Garbage collects store paths older than 14 days.

---

## Project templates

Bootstrap new projects with automatic `direnv` integration. Both `direnv` and `nix-direnv` are enabled — entering a project directory loads its dev environment without losing your shell aliases or prompt.

### Available templates

| Command | Description |
|---|---|
| `tpl-node` | Node.js project (nodejs, pnpm, yarn, typescript) |
| `tpl-esp32` | ESP32-S3 Rust project (espflash, ldproxy, esp-generate) |

### Usage

```sh
mkdir -p ~/Developer/my-app && cd ~/Developer/my-app
tpl-node        # or tpl-esp32
direnv allow
```

After `direnv allow`, entering the directory automatically loads the dev environment. To reload after editing `flake.nix`:

```sh
direnv reload
```
