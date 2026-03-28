# nix-config

Declarative macOS configuration using `nix-darwin`, `home-manager`, and `sops-nix` for secrets. Supports Apple Silicon.

Everything — shell, tools, editor, fonts, apps, system settings — is managed from this repo. A single command rebuilds the entire system.

---

## How it works

| Layer | Tool | What it manages |
|---|---|---|
| System | `nix-darwin` | macOS settings, fonts, Homebrew apps, system packages |
| User | `home-manager` | Shell, dev tools, git, SSH, editor config |
| Secrets | `sops-nix` | SSH keys, API tokens, encrypted at rest |
| Apps | `homebrew` | GUI apps (casks) and Mac App Store apps |

When you run `rebuild`, Nix reads the config, computes what changed, and applies it atomically. If something breaks, roll back to the previous generation.

---

## Project structure

```
nix-config/
├── flake.nix                   # Entry point — defines all machines
├── flake.lock                  # Pinned dependency versions
├── hosts/
│   ├── common/
│   │   ├── darwin-common.nix   # Shared macOS settings, Homebrew apps, fonts
│   │   └── common-packages.nix # System-wide CLI tools
│   └── darwin/
│       ├── flow48/             # MacBook Pro config
│       └── mac-pro/            # Mac Pro config
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
├── assets/
│   ├── starship/               # Prompt config
│   ├── idea/                   # IntelliJ layout
│   ├── raycast/                # Raycast settings (import manually)
│   └── wallpapers/
├── secrets/
│   ├── flow48/                 # Machine-specific secrets (ssh_key, github_token)
│   ├── shared/                 # Shared secrets (cleanshot_license)
│   └── secrets_example.yaml    # Template for flow48 secrets
└── templates/                  # Flake templates for new projects
    ├── node-lts/
    └── esp32-rust-project/
```

---

## Setting up on a fresh machine

### 1. Install Xcode command line tools

```sh
xcode-select --install
```

### 2. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal after installation so `nix` is on your PATH.

### 3. Set up your SSH key

If you don't have one:

```sh
ssh-keygen -t ed25519 -C "utopiaeh01@gmail.com"
```

Add the public key to GitHub: **Settings → SSH and GPG keys**

```sh
cat ~/.ssh/id_ed25519.pub
```

If you see errors like `Cannot read ssh key '/etc/ssh/ssh_host_rsa_key'` later, run:

```sh
sudo ssh-keygen -A
```

### 4. Clone this repo

```sh
git clone git@github.com:utopiaeh/nix-config.git ~/nix-config
cd ~/nix-config
```

### 5. Open the bootstrap shell

```sh
nix develop
```

This drops you into a shell with `sops`, `age`, and `ssh-to-age` — the tools needed to set up secrets before the first build.

### 6. Set up secrets

Secrets are encrypted with `sops` and `age`, derived from your SSH key.

---

**Already have encrypted secrets in the repo?**

Just regenerate the age key from your SSH key — sops will decrypt automatically during rebuild:

```sh
mkdir -p ~/.config/sops/age
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

Skip to step 7.

---

**Setting up secrets for the first time or with a new SSH key?**

Derive your age key:

```sh
mkdir -p ~/.config/sops/age
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

Get your age public key and add it to `.sops.yaml` under the rules for your machine:

```sh
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

Create and encrypt `secrets/flow48/secrets.yaml`:

```sh
cp secrets/secrets_example.yaml secrets/flow48/secrets.yaml
# fill in: ssh_key (cat ~/.ssh/id_ed25519) and github_token
sops -e secrets/flow48/secrets.yaml > secrets/flow48/secrets.enc.yaml
```

Create and encrypt `secrets/shared/secrets.yaml`:

```sh
cp secrets/shared/secrets_example.yaml secrets/shared/secrets.yaml
# fill in: cleanshot_license
sops -e secrets/shared/secrets.yaml > secrets/shared/secrets.enc.yaml
```

> **Important:** Delete the unencrypted files after encrypting — never commit them.

```sh
rm secrets/flow48/secrets.yaml secrets/shared/secrets.yaml
```

---

### 7. Set your hostname

Your hostname must match the name defined in `flake.nix` (`flow48` or `mac-pro`). Check your current local hostname:

```sh
scutil --get LocalHostName
```

To change it:

```sh
sudo scutil --set HostName flow48
sudo scutil --set LocalHostName flow48
```

### 8. First build (bootstrap only)

`nix run .#rebuild` won't work yet — it calls `darwin-rebuild` internally, which doesn't exist until nix-darwin is installed. This two-step command bootstraps it:

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(scutil --get LocalHostName).system"
./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"
```

After this completes, `darwin-rebuild` is on your PATH and `nix run .#rebuild` works for all future updates.

---

## Rebuild & update

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
# or
darwin-rebuild switch --rollback
```

List generations:

```sh
darwin-rebuild --list-generations
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

### Flake apps (work before shell is configured)

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

### CleanShot X

1. Open CleanShot X and enter your license key
2. In a new terminal (or after `source ~/.zshrc`), run `cleanshot-activate`
3. Run `rebuild` — license servers are blocked permanently via `/etc/hosts`

To re-activate after a license reset:
```sh
rm ~/.config/cleanshot-activated && rebuild
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
| Machine-specific package | `flow48.nix` or `mac-pro.nix` |

### Rust toolchain

Managed via `rust-overlay` in `home-manager/programs/rust/default.nix`. Includes `rust-analyzer`, `rust-src`, and `llvm-tools`. Updates automatically after `nix flake update rust-overlay && rebuild`.

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
