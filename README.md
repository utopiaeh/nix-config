# nix-config

Declarative macOS configuration using `nix-darwin`, `home-manager`, and `sops-nix`. Apple Silicon only (`aarch64-darwin`).

Everything — shell, tools, editor, fonts, apps, system settings — is managed from this repo. A single command rebuilds the entire system.

---

## Contents

- [Quickstart (new Mac)](#quickstart-new-mac)
- [How it works](#how-it-works)
- [Project structure](#project-structure)
- [Setup](#setup)
  - [New machine](#new-machine)
  - [Existing machine](#existing-machine)
  - [First build notes](#first-build-notes)
- [Day-to-day](#day-to-day)
- [CI](#ci)
- [Secrets](#secrets)
  - [Adding a new secret](#adding-a-new-secret)
  - [Rotating your SSH key](#rotating-your-ssh-key)
  - [Rotating the age key](#rotating-the-age-key)
  - [Recovery](#recovery)
- [Forking this repo](#forking-this-repo)

---

## Quickstart (new Mac)

For a Mac already registered in this repo (your hostname already exists in `flake.nix`). You'll need your **age key** from your password manager backup (see [Secrets](#secrets)) — it's a small text file.

> Only `flow48` uses sops secrets. On `mac-pro`, skip step 2; step 5 creates its SSH key.
>
> Sign in to the **App Store** before step 4: the build installs Mac App Store apps (Xcode, Amphetamine) and fails if you're signed out. See [First build notes](#first-build-notes).

**1. Install Xcode tools and Nix:**
```sh
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```
Open a new terminal window after this finishes.

**2. Restore your age key** (from the Passwords app, 1Password, etc.):
```sh
mkdir -p ~/.config/sops/age
nano ~/.config/sops/age/keys.txt   # paste the key, save (Ctrl+O, Enter, Ctrl+X)
chmod 600 ~/.config/sops/age/keys.txt
```

**3. Clone this repo:**
```sh
git clone https://github.com/utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

**4. Build your Mac:**
```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```
This takes a while the first time — it's installing everything.

**5. Add your SSH key to GitHub:**
```sh
# flow48 (key restored by sops, which restores only the private key):
ssh-keygen -yf ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
# mac-pro (no secrets, create the key):
ssh-keygen -t ed25519 -C "you@email.com" -f ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
```
Copy the output, then go to github.com → Settings → SSH and GPG keys → New SSH key, and paste it.

Then grant the app permissions in [Post-build manual steps](#post-build-manual-steps).

Done. From now on, run `nix run .#rebuild` any time you want to pull in updates.

Something went wrong? See [Existing machine](#existing-machine) below for the detailed version, or [Recovery](#recovery) if secrets aren't working.

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

Secrets are encrypted with `age`. A standalone age key lives at `~/.config/sops/age/keys.txt` — this is the master decryption key. On every activation (`darwin-rebuild switch`, not `nix build`), sops-nix uses it to decrypt `secrets.enc.yaml` and place secrets at their configured paths (e.g. `~/.ssh/id_ed25519`).

> On macOS the `sops` CLI looks for the key in `~/Library/Application Support/sops/age/keys.txt`, not `~/.config`. The repo's apps (`edit-secrets`, `check-secrets`) set `SOPS_AGE_KEY_FILE` for you, and after the first build your shell has it too. Running `sops` by hand before that: prefix it with `SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt`.
>
> Only `flow48` has secrets today; `mac-pro` has no sops config.

> **Back up `keys.txt` immediately after generating it** — save it to the macOS Passwords app, 1Password, or similar. This file is not managed by Nix and is never committed to git. Losing it means losing access to all your secrets.

---

## Project structure

```
nix-config/
├── flake.nix                        # Entry point — defines all machines
├── flake.lock                       # Pinned dependency versions
├── .sops.yaml                       # Which age keys can decrypt which secrets
├── .github/workflows/                # CI — flake check, key scan, build, weekly input updates
├── .claude/commands/                # Claude Code commands: /nix-check, /nix-add, /nix-diff
├── lib/default.nix                  # mkDarwin helper: wires nix-darwin, home-manager, sops, nix-homebrew
├── overlays/                        # nixpkgs overlays (auto-imported)
├── hosts/
│   ├── common/
│   │   ├── darwin/default.nix       # Shared macOS settings, fonts, activation
│   │   ├── darwin/homebrew.nix      # Homebrew casks and Mac App Store apps (taps: lib/default.nix)
│   │   ├── darwin/settings/         # macOS defaults, hotkeys, app preferences
│   │   └── common-packages.nix      # System-wide CLI tools
│   └── darwin/
│       └── <machine>/               # Machine-specific config (+ custom-dock.nix)
├── home-manager/
│   ├── profiles/
│   │   ├── base.nix                 # Shell, git, SSH, aliases, env vars
│   │   └── <machine>.nix            # Machine-specific home config
│   └── programs/                    # rust, node, git, nix LSP, ghostty, claude, idea...
├── assets/                          # starship theme, wallpapers...
├── secrets/
│   ├── <machine>/secrets.enc.yaml   # Encrypted machine secrets
│   └── secrets_example.yaml         # Template
└── templates/                       # Flake templates (node, esp32, api-rust)
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
<your-machine> = libx.mkDarwin { hostname = "<your-machine>"; };   # username defaults to "utopiaeh" (lib/default.nix)
```

**`.github/workflows/check.yml`** — add `<your-machine>` to the build `matrix.host` list (and to the host list in `.claude/commands/nix-check.md`).

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

> The `sops` block is optional: a machine without secrets (like `mac-pro`) just omits it, skips steps 5 and 8, and manages its SSH key by hand.

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
nix shell nixpkgs#sops --command sops --encrypt \
  --filename-override secrets/<your-machine>/secrets.enc.yaml \
  --output secrets/<your-machine>/secrets.enc.yaml /tmp/secrets.yaml
rm /tmp/secrets.yaml   # never commit the unencrypted file
```

> After the first build, use `nix run .#edit-secrets -- <your-machine>` to edit secrets instead.

#### 9. Stage the new files

Flakes only see files git knows about — untracked files fail with `path ... does not exist`:

```sh
git add flake.nix .sops.yaml hosts/darwin/<your-machine> home-manager/profiles/<your-machine>.nix secrets/<your-machine>
nix run .#scan-keys   # make sure no private key got staged
```

#### 10. First build

`darwin-rebuild` doesn't exist yet — use this bootstrap (read [First build notes](#first-build-notes) first):

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After this, `nix run .#rebuild` works for all future updates.

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

Read [First build notes](#first-build-notes) first.

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After a successful build, sops-nix places your SSH key at `~/.ssh/id_ed25519` (machines with secrets only). It restores only the private key, so recreate the public one and add it to GitHub if you haven't already:

```sh
ssh-keygen -yf ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
cat ~/.ssh/id_ed25519.pub   # add to github.com → Settings → SSH and GPG keys
ssh -T git@github.com       # verify
```

---

### First build notes

- **Sign in to the App Store first.** `masApps` (Xcode, Amphetamine) install during the Homebrew step; signed out, that step fails and the rest of activation (home-manager, secrets) doesn't run.
- **Homebrew is installed for you** by nix-homebrew, and `onActivation.cleanup = "uninstall"` **removes every cask and formula not listed in the config**. On a Mac that already has apps from `brew install`, add them to `homebrew.nix` first or they'll be uninstalled.
- **Rebuild twice on a fresh Mac.** Dock settings are applied before Homebrew installs the apps, so the first Dock may have missing icons; a second `nix run .#rebuild` fixes it.
- **`/etc` conflicts:** if activation stops with `Unexpected files in /etc` (e.g. `/etc/zshrc`, `/etc/bashrc`), rename them as the message says (`sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin`) and rerun.
- If you see `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'`, run `sudo ssh-keygen -A` and rebuild.

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
nix run .#check-secrets -- <machine>                 # verify secrets decrypt cleanly
nix run .#scan-keys                                  # fail if a private key or unencrypted secret is in the repo
darwin-rebuild --list-generations                    # list all generations
```

### Claude Code commands

Project commands in `.claude/commands/`, available when Claude Code runs inside this repo:

| Command | What it does |
|---|---|
| `/nix-check` | Runs what CI runs: `scan-keys`, nixfmt on changed files, `nix flake check`, host builds. Never switches. |
| `/nix-add <thing>` | Finds a package or cask and adds it where the [table below](#where-to-add-things) says, then runs `/nix-check` |
| `/nix-diff` | Builds the current host and summarizes what would change vs the running system |

### Shell aliases

| Command | What it does |
|---|---|
| `fix-sound` | Restarts the macOS audio daemon |
| `dev` | `cd ~/Developer` |
| `cl` | Clear terminal |
| `lg` | Opens lazygit |
| `tscl` | Runs `npx tsc` |
| `, <package>` | Runs a Nix package without installing it |
| `tpl-node` | Initializes a Node.js project from template |
| `tpl-esp32` | Initializes an ESP32-S3 Rust project from template |
| `tpl-api-rust` | Initializes a Rust API project (Diesel, PostgreSQL) from template |

The `,` command is especially useful — e.g. `, ffmpeg -i video.mp4 output.gif`. Downloaded on first use, cached for reuse, nothing stays on your PATH permanently.

### Where to add things

| What | Where |
|---|---|
| New GUI app | `homebrew.casks` in `hosts/common/darwin/homebrew.nix` |
| New CLI tool (system-wide) | `environment.systemPackages` in `common-packages.nix` |
| New CLI tool (personal) | `home.packages` in `base.nix` |
| Shell alias | `programs.zsh.shellAliases` in `base.nix` |
| Environment variable | `home.sessionVariables` in `base.nix` |
| Machine-specific package | `hosts/darwin/<machine>/default.nix` |
| Machine-specific home config | `home-manager/profiles/<machine>.nix` |
| Tool with its own config | `home-manager/programs/<tool>.nix` (imported in `base.nix`) |

### Post-build manual steps

Grant these in **System Settings → Privacy & Security** when each app asks (or add them by hand):

| App | What to do |
|---|---|
| **Switch** | Accessibility, plus Screen Recording for window thumbnails. Set hotkeys in its settings (not declarable). |
| **FlashSpace** | Accessibility |
| **macshot** | Screen Recording |
| **WheelClick** | Accessibility (its menu bar icon is hidden by config) |
| **Tinycast** | Accessibility. Its ⌘Space palette hotkey is set by the config; import a backup from `assets/*.tinycast` for the rest. |
| **Docker Desktop** | Launch once to finish setup (also provides the driver `minikube` needs) |
| **Claude Usage Tracker** | On first launch, follow its setup to paste your claude.ai session key |
| **Ghostty** | Installed by Nix into `~/Applications/Home Manager Apps`; config in `home-manager/programs/ghostty.nix` |
| **Terminal you rebuild from** | **App Management** (System Settings → Privacy & Security), so home-manager can update its app copies; without it activation stops with "permission denied" |
| **IntelliJ IDEA** | Launch once, then rebuild to install the layout; quit IDEA before rebuilding or it overwrites the layout on exit |

**FlashSpace config** is only copied from `home-manager/programs/flashspace/` when `~/.config/flashspace/` has no files yet. After that FlashSpace owns them: changes in the repo don't reach an existing Mac, and to save changes made in the app back to the repo run `~/.config/scripts/backup_flashspace.sh` (then review and commit).

### Project templates

```sh
mkdir -p ~/Developer/my-app && cd ~/Developer/my-app
tpl-node        # Node.js (pnpm, typescript)
tpl-esp32       # ESP32-S3 Rust project
tpl-api-rust    # Rust API (Diesel, PostgreSQL)
direnv allow    # load dev environment
```

---

## CI

GitHub Actions (`.github/workflows/`), actions pinned to commit SHAs:

- `check.yml` — on pushes to `main` and on PRs: `nix flake check --no-build`, `nix run .#scan-keys`, and a full build of the `mac-pro` and `flow48` system derivations. Secrets aren't needed for this — sops-nix only decrypts at activation (`darwin-rebuild switch`), not at build time.
- `update-flake.yml` — weekly (Mondays 06:00 UTC), opens a PR bumping all flake inputs and triggers `check.yml` on it. Review and merge manually; nothing auto-merges.

Garbage collection is manual: Determinate Nix manages the Nix daemon (`nix.enable = false`), so nix-darwin's `nix.gc` options don't apply. Run `nix run .#cleanup` when you want to reclaim space.

---

## Secrets

Only machines with a `sops` block (today: `flow48`) have secrets. Edit them with `nix run .#edit-secrets -- <machine>` and verify with `nix run .#check-secrets -- <machine>`.

### Adding a new secret

**1. Add the value** — opens the decrypted file in `$EDITOR`, re-encrypts on save:
```sh
nix run .#edit-secrets -- <your-machine>
```
Add a key, e.g. `github_token: ghp_...`.

**2. Declare it** in `hosts/darwin/<your-machine>/default.nix`:
```nix
sops.secrets."github_token" = {
  owner = username;
  mode = "0400";
  # path = "/Users/${username}/.config/app/token";   # optional, default /run/secrets/github_token
};
```

**3. Use it** by path, never by value (the value must not end up in the Nix store):
```nix
config.sops.secrets."github_token".path
```

**4. Rebuild** with `nix run .#rebuild`.

Secrets are system-level (the sops-nix home-manager module isn't imported), so they're declared in `hosts/`, not `home-manager/`.

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

### Rotating the age key

Use this when you still have the current key (for a lost key, see [full reset](#if-both-keys-are-lost--full-reset)).

**1. Generate the new key next to the old one:**
```sh
nix develop   # for age / sops
age-keygen -o ~/.config/sops/age/keys.new.txt
age-keygen -y ~/.config/sops/age/keys.new.txt   # new public key
```

**2. Update `.sops.yaml`** — replace the old public key with the new one for `<your-machine>`.

**3. Re-encrypt for the new key** from the repo root (sops reads `.sops.yaml` there; it decrypts with the old key, so keep `keys.txt` in place):
```sh
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops updatekeys secrets/<your-machine>/secrets.enc.yaml
```

**4. Swap the key files and verify:**
```sh
mv ~/.config/sops/age/keys.new.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
nix run .#check-secrets -- <your-machine>
```

**5. Back up the new `keys.txt`** (Passwords app / 1Password), replacing the old backup, then commit `.sops.yaml` and the re-encrypted file.

---

### Recovery

Use this if sops fails to activate on boot — `~/.ssh/id_ed25519` is missing or broken and you can't push to GitHub.

**Why it happens:** sops-nix decrypts secrets on boot using `keys.txt`. If that file is missing, decryption fails and no secrets are placed.

---

#### If `keys.txt` exists but sops still failed

```sh
# verify decryption works (uses ~/.config/sops/age/keys.txt explicitly)
nix run .#check-secrets -- <your-machine>

# if that works, just rebuild
nix run .#rebuild
```

---

#### If `keys.txt` is lost — restore from backup

```sh
mkdir -p ~/.config/sops/age
nano ~/.config/sops/age/keys.txt   # paste from Passwords app / 1Password
chmod 600 ~/.config/sops/age/keys.txt
nix run .#rebuild
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
nix shell nixpkgs#sops --command sops --encrypt \
  --filename-override secrets/<your-machine>/secrets.enc.yaml \
  --output secrets/<your-machine>/secrets.enc.yaml /tmp/secrets.yaml
rm /tmp/secrets.yaml
```

**5. Place the SSH key temporarily** so you can push the new `.sops.yaml` and secrets file before the rebuild deploys it:
```sh
cp /tmp/new_ssh_key ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

**6. Rebuild:**
```sh
nix run .#rebuild
```

**7.** Add the new SSH public key to GitHub, remove the old one.

**8. Back up `keys.txt`** to the macOS Passwords app or 1Password.

```sh
rm /tmp/new_ssh_key /tmp/new_ssh_key.pub
```

---

## Forking this repo

The config is personal. Before building it on your own Mac, change:

| What | Where |
|---|---|
| Username (default `utopiaeh`) | `lib/default.nix` (`username ? ...`), or pass `username` per host in `flake.nix` |
| Hostnames | `darwinConfigurations` in `flake.nix`, the build matrix in `.github/workflows/check.yml`, `.claude/commands/nix-check.md` |
| Git name and email | `home-manager/programs/git.nix` |
| Time zone | `time.timeZone` in `hosts/common/darwin/default.nix` |
| Secrets | Delete `secrets/<machine>/` and the recipients in `.sops.yaml`, then follow [New machine](#new-machine) steps 5 and 8 with your own age key |
| Apps and taps | `hosts/common/darwin/homebrew.nix`, taps in `lib/default.nix` + `flake.nix` inputs, per-host casks and docks in `hosts/darwin/<machine>/` |
| Personal app settings | `hosts/common/darwin/settings/`, `home-manager/programs/` (macshot translate language, FlashSpace profiles, Claude config) |
| Wallpaper | `wallpaper` in `home-manager/profiles/base.nix` |
| Template aliases | `tpl-*` in `home-manager/profiles/base.nix` point at `github:utopiaeh/nix-config` |
| Clone URLs | This README |
