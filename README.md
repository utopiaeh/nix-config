# nix-config

Declarative macOS configuration using `nix-darwin`, `home-manager`, and `sops-nix` for secrets. Supports Apple Silicon.

Everything — shell, tools, editor, fonts, apps, system settings — is managed from this repo. A single command rebuilds the entire system.

---

## Table of Contents

- [How it works](#how-it-works)
- [Project structure](#project-structure)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Secrets setup](#secrets-setup-sops--age)
- [Build & Rebuild](#build--rebuild)
- [Built-in shell commands](#built-in-shell-commands)
- [Post-rebuild steps](#post-rebuild-steps)
- [Day-to-day tips](#day-to-day-tips)
- [Project templates & direnv](#project-templates--direnv)

---

## How it works

| Layer | Tool | What it manages |
|---|---|---|
| System | `nix-darwin` | macOS settings, fonts, Homebrew apps, system packages |
| User | `home-manager` | Shell, dev tools, git, SSH, editor config |
| Secrets | `sops-nix` | SSH keys, API tokens, encrypted at rest |
| Apps | `homebrew` | GUI apps (casks) and Mac App Store apps |

When you run `rebuild`, Nix reads the config, computes what changed, and applies it atomically. If something breaks, you can roll back to the previous generation.

---

## Project structure

```
nix-config/
├── flake.nix                   # Entry point — defines all machines
├── flake.lock                  # Pinned dependency versions
├── hosts/
│   ├── common/
│   │   ├── darwin-common.nix   # Shared macOS settings, Homebrew apps, fonts
│   │   └── common-packages.nix # System-wide CLI tools (kubectl, gh, sops...)
│   └── darwin/
│       ├── flow48/             # MacBook Pro config (overrides common)
│       └── mac-pro/            # Mac Pro config (overrides common)
├── home-manager/
│   ├── profiles/
│   │   ├── base.nix            # User environment (shell, git, SSH, aliases...)
│   │   ├── flow48.nix          # MacBook Pro home config
│   │   └── mac-pro.nix         # Mac Pro home config
│   └── programs/
│       ├── rust/               # Rust toolchain + rust-analyzer
│       ├── nix/                # Nix LSP (nixd) + formatter (nixfmt)
│       ├── node/               # Node.js environment
│       ├── git/                # Git config
│       └── iterm2/             # iTerm2 preferences (declarative)
├── data/
│   ├── starship/               # Prompt config
│   ├── idea/                   # IntelliJ layout
│   ├── raycast/                # Raycast settings (import manually)
│   └── wallpapers/
├── secrets/                    # Encrypted secrets (sops)
└── templates/                  # Flake templates for new projects
    ├── node-lts/
    └── esp32-rust-project/
```

---

## Quick Start

If you just want to get a machine running fast:

```sh
# 1. Install Xcode command line tools
xcode-select --install

# 2. Install Nix (answer No to "Determinate Nix" prompt)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. Open a new terminal so nix is on your PATH

# 4. Set up secrets (see Secrets setup section below)

# 5. Make sure your hostname matches the one in flake.nix

# 6. Build and apply
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(hostname).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(hostname)"
```

After the first build, use the `rebuild` command for all future updates.

---

## Installation

### 1. Install Xcode command line tools

```sh
xcode-select --install
```

### 2. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

> **Important:** The installer will ask if you want "Determinate Nix". Answer **No** — use plain Nix.

Open a new terminal after installation so `nix` is on your PATH.

### 3. Set your hostname

Your hostname must match the name used in `flake.nix`. Either:

- Change your macOS hostname to match `flake.nix`, **or**
- Edit `flake.nix` to use your actual hostname

To check your current hostname:
```sh
hostname
```

To change it:
```sh
sudo scutil --set HostName your-hostname
sudo scutil --set LocalHostName your-hostname
```

---

## Secrets setup (sops + age)

Secrets (SSH keys, tokens) are encrypted with `sops` and `age`. They are decrypted automatically during rebuild using your SSH key.

### 1. Generate an SSH key (if you don't have one)

```sh
ssh-keygen -t ed25519 -C "utopiaeh01@gmail.com"
```

### 2. Create the sops directory

```sh
mkdir -p ~/.config/sops/age
```

### 3. Derive an age key from your SSH key

```sh
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

### 4. Get your age public key

```sh
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

Copy this value — you'll need it in step 7.

### 5. Create your secrets file

```sh
cp secrets/flow48/secrets_example.yaml secrets/flow48/secrets.yaml
```

Open the file and replace the placeholder values with your actual keys. To view your private SSH key:

```sh
cat ~/.ssh/id_ed25519
```

### 6. Encrypt your secrets

```sh
sops -e secrets/flow48/secrets.yaml > secrets/flow48/secrets.enc.yaml
```

> **Important:** Delete `secrets.yaml` after encrypting — never commit the unencrypted file.

### 7. Register your age key in `.sops.yaml`

Open `.sops.yaml` and add a rule with your age public key (from step 4) so sops knows how to encrypt/decrypt files for your machine.

### 8. Fix missing SSH host key errors (if needed)

If you see errors like `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'`, run:

```sh
sudo ssh-keygen -A
```

### 9. Add your SSH public key to GitHub

```sh
cat ~/.ssh/id_ed25519.pub
```

Add this at **GitHub → Settings → SSH and GPG keys**.

---

## Build & Rebuild

### First build

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(hostname).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(hostname)"
```

### All subsequent rebuilds

Once configured, use the built-in `rebuild` command from any terminal:

```sh
rebuild           # uses current hostname automatically
rebuild mac-pro   # target a specific machine profile
```

To update all dependencies and rebuild:

```sh
nix flake update
rebuild
```

To update only one dependency (e.g. rust toolchain):

```sh
nix flake update rust-overlay
rebuild
```

---

## Built-in shell commands

These are defined in your shell config and available in every terminal:

| Command | What it does |
|---|---|
| `rebuild [host]` | Runs `darwin-rebuild switch` for the current or specified host |
| `cleanup` | Removes Nix generations older than 14 days and garbage collects the store |
| `fix-sound` | Restarts the macOS audio daemon (fixes audio glitches) |
| `idea [path]` | Opens a project in IntelliJ IDEA |
| `, package-name` | Runs a Nix package without installing it (via `nix run`) |
| `lg` | Opens lazygit |
| `dev` | `cd ~/Developer` |

---

## Post-rebuild steps

Most things are configured automatically. A few require manual steps after the first install.

### Dock

The Dock layout is defined in `hosts/darwin/flow48/` — it is applied on rebuild.

### iTerm2

iTerm2 preferences are managed declaratively and copied automatically on each rebuild. If the theme or font looks wrong, quit and reopen iTerm2.

Font for macOS Terminal (if you prefer it over iTerm2):
```
MesloLGL Nerd Font
```

### CleanShot X

1. After rebuild, open CleanShot X and enter your license key
2. In a **new terminal** (or run `source ~/.zshrc`), run `cleanshot-activate`
3. Run `rebuild` — license servers are now blocked permanently via `/etc/hosts`

To re-activate on a new machine or after a license reset:
```sh
rm ~/.config/cleanshot-activated && rebuild
```

License server blocking is kernel-level and applies from boot, so there is no race condition.

### Raycast

Import your settings manually from:
```
data/raycast/
```

### AWS Amplify CLI

The Amplify CLI has no Nix package and is installed automatically via npm on the first rebuild of the `flow48` profile. This only runs if `amplify` is not already on your PATH.

To remove it manually:
```sh
npm uninstall -g @aws-amplify/cli
rm -rf ~/.npm-global/lib/node_modules/@aws-amplify
rm ~/.npm-global/bin/amplify
```

### Apps that need manual setup after first launch

- **MiddleClick** — enable in Accessibility settings
- **AltTab** — grant Screen Recording permission
- **BetterDisplay** — grant Screen Recording permission

---

## Day-to-day tips

### Where to add things

| What | Where |
|---|---|
| New GUI app | `homebrew.casks` in `darwin-common.nix` |
| New CLI tool (system-wide) | `environment.systemPackages` in `common-packages.nix` |
| New CLI tool (personal) | `home.packages` in `base.nix` |
| Shell alias | `programs.zsh.shellAliases` in `base.nix` |
| Environment variable | `home.sessionVariables` in `base.nix` |
| Machine-specific package | `flow48.nix` or `mac-pro.nix` |

### Rust toolchain

The stable Rust toolchain is managed via `rust-overlay` in `home-manager/programs/rust/default.nix`. It includes `rust-analyzer`, `rust-src`, and `llvm-tools`. After a `nix flake update rust-overlay && rebuild`, the toolchain updates automatically.

### Nix LSP in Zed

`nixd` is the Nix language server and is configured in `home-manager/programs/nix/default.nix`. Zed is pointed to it via `~/.config/zed/settings.json`. No manual installation needed.

### Roll back a bad rebuild

```sh
# List generations
darwin-rebuild --list-generations

# Roll back to previous
darwin-rebuild switch --rollback
```

### Clean up disk space

```sh
cleanup
```

This removes system and user generations older than 14 days and runs `nix-collect-garbage`.

---

## Project templates & direnv

This repo exposes flake templates to bootstrap new projects that automatically integrate with your shell and dev environment via `direnv`.

Both `direnv` and `nix-direnv` are already enabled in this config. When you `cd` into a project directory, the project's Nix dev environment is loaded automatically — without losing your shell aliases, prompt, or completions.

### Available templates

| Template | Description |
|---|---|
| `node` | Node.js project with devShell (nodejs, pnpm, yarn, typescript) |
| `esp32-rust` | ESP32-S3 Rust project with devShell (rust-analyzer, espflash, ldproxy) |

### Node.js project

```sh
mkdir -p ~/Developer/my-app && cd ~/Developer/my-app
tpl-node
direnv allow
```

### ESP32-S3 Rust project

```sh
mkdir -p ~/Developer/mcu/my-esp32 && cd ~/Developer/mcu/my-esp32
tpl-esp32
direnv allow
```

After `direnv allow`, entering the directory automatically loads the dev environment. If you edit `flake.nix`, reload with:

```sh
direnv reload
```
