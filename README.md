# nix-config

Declarative Nix configuration for macOS (Apple Silicon supported), using `nix-darwin`, `home-manager`, and `sops` for secrets and dotfiles.

---

## ⚡ Quick Start

**In this section:**

- Minimal command sequence to bootstrap a new machine  
- Install Xcode CLI tools and Nix  
- Ensure hostname matches `flake.nix`  
- Set up secrets (SSH + age + sops)  
- Build and switch to your configuration using `nix` or `rebuild`

If you just want to get a machine up and running, follow these steps in order:

```sh
# 1. Install Xcode command line tools
xcode-select --install

# 2. Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 3. Open a new terminal so `nix` is on your PATH

# 4. Make sure your hostname matches the one used in flake.nix

# 5. Set up secrets (SSH + age + sops)
#    - Generate SSH key (if needed)
#    - Generate age key
#    - Create and encrypt secrets.yaml

# 6. Build and switch to your configuration
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.$(hostname).system"
# or simply use the rebuild helper once configured:
# rebuild
```

---

## 📚 Table of Contents

- [⚡ Quick Start](#-quick-start)
- [✅ Installation (macOS)](#-installation-macos)
  - [1. Install Xcode command line tools](#1-install-xcode-command-line-tools)
  - [2. Install Nix](#2-install-nix)
  - [3. Set your hostname](#3-set-your-hostname)
- [🔐 Secrets Setup (sops + age)](#-secrets-setup-sops--age)
  - [1. If you do not have an SSH key](#1-if-you-do-not-have-an-ssh-key)
  - [2. Create the directory for sops](#2-create-the-directory-for-sops-if-it-doesnt-exist)
  - [3. Generate an AGE-SECRET-KEY](#3-generate-an-age-secret-key)
  - [4. Get the age public key](#4-get-the-age-public-key)
  - [5. Create secrets.yaml from secrets_example](#5-create-secretsyaml-from-secrets_example)
  - [6. Encrypt your secrets with sops](#6-encrypt-your-secrets-with-sops)
  - [7. Fix missing SSH host key errors](#7-fix-missing-ssh-host-key-errors-if-needed)
  - [8. Add your public SSH key to GitHub](#8-add-your-public-ssh-key-to-github)
  - [9. Add a rule in .sops.yaml](#9-add-a-rule-in-sopsyaml)
- [🏗️ Build](#-build)
- [🔁 Rebuild](#-rebuild)
- [⚙️ Post-Rebuild Configuration & Tweaks](#-post-rebuild-configuration--tweaks)
  - [1. Dock configuration](#1-dock-configuration)
  - [2. iTerm2](#2-iterm2)
  - [3. CleanShot X](#3-cleanshot-x)
  - [4. Node.js package notes](#4-nodejs-package-notes)
  - [5. Manual app configuration](#5-manual-app-configuration)
- [💡 Tips](#-tips)
- [📦 Project Templates & direnv](#-project-templates--direnv)

---

## ✅ Installation (macOS)

**In this section:**

- Install Xcode command line tools  
- Install Nix using Determinate Systems installer  
- Ensure `nix` is on your `PATH`  
- Align your macOS hostname with `flake.nix`

This configuration supports Apple Silicon Macs.

### 1. Install Xcode command line tools

```sh
xcode-select --install
```

### 2. Install Nix

Thanks to the [installer](https://zero-to-nix.com/concepts/nix-installer) by [Determinate Systems](https://determinate.systems/)!

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, open a new terminal session to make the `nix` executable available in your `$PATH`.

> ⚠️ **IMPORTANT**  
> The installer will ask if you want to install Determinate Nix. Answer *No*.

---

### 3. Set your hostname

The hostname should match the one set in `flake.nix`.

You can either:

- Change your macOS hostname to match the one in `flake.nix`, or  
- Change the hostname in `flake.nix` to match your machine’s actual hostname.

---

## 🔐 Secrets Setup (sops + age)

**In this section:**

- Generate an SSH key (if needed)  
- Set up age keys for `sops`  
- Create and encrypt `secrets.yaml`  
- Fix SSH host key errors  
- Add SSH keys to GitHub  
- Configure `.sops.yaml` rules

### 1. If you do not have an SSH key

```sh
ssh-keygen -t ed25519 -C "utopiaeh01@gmail.com"
```

### 2. Create the directory for sops (if it doesn’t exist)

```sh
mkdir -p ~/.config/sops/age
```

### 3. Generate an `AGE-SECRET-KEY`

```sh
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

### 4. Get the age public key

```sh
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

### 5. Create `secrets.yaml` from `secrets_example`

Copy the example:

```sh
cp secrets/flow48/secrets_example.yaml secrets/flow48/secrets.yaml
```

Then replace the placeholders with your own keys.

Example: to show your private key from `~/.ssh`:

```sh
bat --plain ~/.ssh/id_ed25519
```

### 6. Encrypt your secrets with sops

```sh
sops -e secrets/flow48/secrets.yaml > secrets/flow48/secrets.enc.yaml
```

> ⚠️ **IMPORTANT**  
> After encrypting, remove `secrets.yaml` to avoid accidentally committing it to Git.

### 7. Fix missing SSH host key errors (if needed)

If you see errors like:

```text
Cannot read ssh key '/etc/ssh/ssh_host_rsa_key': no such file or directory
Cannot read ssh key '/etc/ssh/ssh_host_ed25519_key': no such file or directory
```

Run:

```sh
sudo ssh-keygen -A
```

### 8. Add your public SSH key to GitHub

To display your public key from `~/.ssh`:

```sh
bat --plain ~/.ssh/id_ed25519.pub
```

Add that key to GitHub under **Settings → SSH and GPG keys**.

### 9. Add a rule in `.sops.yaml`

Create or update `.sops.yaml` to include a rule with your age public key so that future `sops` edits use it automatically.

---

## 🏗️ Build

**In this section:**

- Build your `nix-darwin` configuration using `nix`  
- Understand the `darwinConfigurations.<<hostname/profile>>.system` target

You can build the darwin system directly with `nix` (what your `rebuild` alias wraps).

By default, it should use your hostname. Replace `<<hostname/profile>>` with your hostname:

```sh
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.<<hostname/profile>>.system"
```

---

## 🔁 Rebuild

**In this section:**

- Use the `rebuild` alias for day-to-day updates  
- Target specific profiles (e.g. `mac-pro`)

Use the `rebuild` alias (defined below in [💡 Tips](#-tips)).

- By default, it uses your current `hostname`
- You can also pass a specific profile:

```sh
rebuild mac-pro
```

---

## ⚙️ Post-Rebuild Configuration & Tweaks

**In this section:**

- Configure Dock layout  
- Use the pre-configured iTerm2 setup  
- Configure CleanShot X with LuLu  
- Handle global Node.js packages  
- Manually configure a few GUI apps

### 1. Dock configuration

Check the `custom-dock` file in `hosts/darwin` — it defines the default Dock apps.

### 2. iTerm2

iTerm2 is pre-configured with:

- custom theme
- Starship prompt
- keybindings

#### 2.1 macOS Terminal

If you prefer macOS Terminal, set the font manually to:

```text
MesloLGLNF
```

---

### 3. CleanShot X

- Should be activated with your license.
- After activation, launch the **LuLu** app and block CleanShot’s network access to prevent license checks (useful if reusing a license across machines).

> ⚠️ **IMPORTANT**  
> This also disables CleanShot’s cloud functionality.

---

### 4. Node.js package notes

While `nodejs` and tools like `@aws-amplify/cli` can be installed declaratively via Home Manager, **global NPM packages can’t be uninstalled via Nix**.

#### 4.1 Remove a global package

```sh
npm uninstall -g @aws-amplify/cli
```

#### 4.2 Fully remove references

```sh
rm -rf ~/.npm-global/lib/node_modules/@aws-amplify
rm ~/.npm-global/bin/amplify
```

---

### 5. Manual app configuration

Some apps are installed but require manual configuration after first launch:

- MiddleClick
- HiddenBar
- AltTab
- BetterDisplay

#### 5.1 Raycast

Raycast settings must be imported manually from:

```text
data/raycast/*
```

---

## 💡 Tips

**In this section:**

- Define a `rebuild` helper function  
- Update flake inputs and rebuild  
- Clean the Nix store and remove old generations

You can define a `rebuild` alias in your shell config (`data/mac-dot-zshrc`) like this:

```sh
rebuild() {
  local host="${1:-$(hostname)}"
  if [[ $# -gt 0 ]]; then
    shift
  fi
  sudo darwin-rebuild switch --flake ".#${host}" "$@"
}
```

To update your dependencies and rebuild your system:

```sh
nix flake update
rebuild
```

To clean the Nix store and remove old generations:

```sh
cleanup
```

---

## 📦 Project Templates & direnv

This repo also exposes **flake templates** to quickly bootstrap new projects that integrate nicely with your global Zsh + Home Manager setup and `direnv`.

### ⚙️ Requirements

These are already enabled in this config:

- Nix with flakes and `nix-command`
- `direnv` + `nix-direnv` via Home Manager:

  ```nix
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  ```

With this setup, `direnv` will automatically load your project’s Nix dev environment into your existing Zsh shell (so you keep autosuggestions, syntax highlighting, aliases, etc.).

### 🧩 Available templates

The flake in this repo exposes templates under `templates`:

- `node-lts`  
  Path: `./data/templates/note-lts`  
  Description: Node.js project starter (flake devShell + `.envrc` for direnv)

- `esp32-rust`  
  Path: `./data/templates/esp32-rust-project`  
  Description: ESP32‑S3 Rust project starter (devShell + `.envrc` for direnv)

The default template is `node`.

### 🧪 Using the Node.js project template

To create a new Node‑based project that uses the Node devShell and direnv:

```sh
mkdir -p ~/Developer/my-node-app
cd ~/Developer/my-node-app

# Initialize from this repo's Node template
nix flake init -t "path:/Users/utopiaeh/nix-config#node"

# Trust direnv for this directory
direnv allow
```

This will create:

- `flake.nix` – with a devShell that includes:
  - `nodejs_20`
  - `pnpm`
  - `yarn`
  - `typescript`
- `.envrc` – containing:

  ```sh
  use flake
  ```

After `direnv allow`, whenever you `cd` into this project:

- `direnv` will call Nix to load the devShell environment,
- Your existing Home Manager Zsh session stays active,
- You keep autosuggestions + syntax highlighting from `programs.zsh` in `home-manager/profiles/base.nix`.

### 🧪 Using the ESP32‑S3 Rust project template

To create a new ESP32‑S3 Rust project:

```sh
mkdir -p ~/Developer/mcu/my-esp32-project
cd ~/Developer/mcu/my-esp32-project

# Initialize from this repo's ESP32 Rust template
nix flake init -t "path:/Users/utopiaeh/nix-config#esp32-rust"

# Trust direnv for this directory
direnv allow
```

This will create:

- `flake.nix` – with a devShell that includes:
  - `rust-analyzer`
  - `espflash`
  - `ldproxy`
  - `esp-generate`
  - sensible defaults:
    - `CARGO_BUILD_TARGET = "xtensa-esp32s3-none-elf"`
    - `RUST_BACKTRACE = 1`
- `.envrc` – containing:

  ```sh
  use flake
  ```

Again, entering this directory will automatically load the ESP32 dev environment via `direnv` while preserving your global Zsh configuration from Home Manager.

### 💻 Day‑to‑day workflow with templates + direnv

For any project created from these templates:

1. `cd` into the project directory.
2. On the first time: `direnv allow`.
3. Afterwards, simply `cd` in/out:
   - Zsh (with Home Manager config) stays the same.
   - The project’s flake devShell is layered on top by `direnv`.

You rarely need to run `nix develop` manually. If you edit `flake.nix` in a project, just run:

```sh
direnv reload
```

to pick up the changes in your current shell.
