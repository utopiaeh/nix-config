# nix-config

Declarative Nix configuration for macOS (Apple Silicon supported), using `nix-darwin`, `home-manager`, and `sops` for secrets and dotfiles.

---

## ✅ Installing for macOS

This configuration supports Apple Silicon Macs.

### 1. Install dependencies

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

The hostname should match the one set in the `flake.nix` file.
Alternatively, you can change the hostname in `flake.nix` to match your machine's actual hostname.

---

## 🔐 Secrets

### 3.1 If you do not have an SSH key

```sh
ssh-keygen -t ed25519 -C "utopiaeh01@gmail.com"
```

### 3.2 Create the directory for sops if it doesn’t exist

```sh
mkdir -p ~/.config/sops/age
```

### 3.3 Generate an AGE-SECRET-KEY

```sh
nix run nixpkgs#ssh-to-age -- -private-key -i .ssh/id_ed25519 > ~/.config/sops/age/keys.txt
```

### 3.4 Get age public key

```sh
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

### 3.5 Copy `secrets_example` to `secrets.yaml` and replace with your keys

Example: to get your private key from `~/.ssh`:

```sh
bat --plain id_ed25519
```

### 3.6 Encrypt your secrets with sops

```sh
sops -e secrets/flow48/secrets.yaml > secrets/flow48/secrets.enc.yaml
```

> ⚠️ **IMPORTANT**
> After encrypting, remove `secrets.yaml` to avoid accidentally committing it to Git.

### 3.7 Fix missing SSH host key errors

If you see:

```
Cannot read ssh key '/etc/ssh/ssh_host_rsa_key': no such file or directory
Cannot read ssh key '/etc/ssh/ssh_host_ed25519_key': no such file or directory
```

Run:

```sh
sudo ssh-keygen -A
```

### 3.8 Add your public SSH key to GitHub

To copy your public key from `~/.ssh`:

```sh
bat --plain id_ed25519.pub
```

### 3.9 Create a rule in `.sops.yaml` with your age public key

---


## 🛠️ Build

Use the `rebuild` alias.

* By default, it should be your hostname replace `<<hostname/profile>>` with your hostname

```sh
nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.<<hostname/profile>>.system"
```

## 🛠️ Rebuild

Use the `rebuild` alias.

* By default, it uses your hostname
* You can also pass a specific profile:

```sh
rebuild mac-pro
```

---

## ⚙️ Post-Rebuild Configuration and Tweaks

### 1. Configure the Dock

Check the `custom-dock` file in the `hosts/darwin` directory — it defines the default Dock apps.

### 2. iTerm2 is pre-configured

Includes a custom theme, Starship prompt, and keybindings.

#### 2.1 For macOS Terminal

Set the font manually to: `MesloLGLNF`

---

### 3. CleanShot X

* Should be activated with your license.
* After activation, launch the **LuLu** app and block CleanShot’s network access to prevent license checks (useful if reusing a license across machines).

> ⚠️ **IMPORTANT**
> This also disables CleanShot’s cloud functionality.

---

### 4. NodeJS Package Notes

While `NodeJS` and tools like `@aws-amplify/cli` can be installed declaratively via Home Manager, global packages **can’t be uninstalled via Nix**.

#### 4.1 To remove packages:

```sh
npm uninstall -g @aws-amplify/cli
```

#### 4.2 To fully remove references:

```sh
rm -rf ~/.npm-global/lib/node_modules/@aws-amplify
rm ~/.npm-global/bin/amplify
```

---

### 5. Manual App Configuration

Some apps are installed but require manual configuration after the first launch:

* MiddleClick
* HiddenBar
* AltTab
* BetterDisplay

---

### 5.1 Raycast

Settings must be imported manually from:
`data/raycast/*`

---

## 💡 Tip

You can define an alias in shell config  `data/mac-dot-zshrc` like this:

```sh
rebuild() {
  local host="${1:-$(hostname)}"
  sudo darwin-rebuild switch --flake ".#$host"
}
```

---


