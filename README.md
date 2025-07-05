# dotfiles

My dotfiles managed with yadm

## Getting Started

### Install yadm

Goto [yadm github](https://yadm.io/docs/install) and follow the instructions.

Then clone this repo with yadm

```bash
yadm clone git@github.com:wiesel78/dotfiles.git
```

### Install fzf

[fzf github](https://github.com/junegunn/fzf/tree/master?tab=readme-ov-file#using-git)

### Install tmux 

```bash
pacman -S tmux
```

Start tmux and install plugins with `STRG+S + I`

Install tmuxifier [tmuxifier github](https://github.com/jimeh/tmuxifier?tab=readme-ov-file#installation)

### Install cargo

Install cargo as standalone or with rustup or so and then install with cargo

```bash
cargo install exa
cargo install starship
cargo install vivid
cargo install prompt
cargo install ripgrep
```

## Windows

A few windows specific things

### Installs

* with cygwin
  * make
  * unzip
  * wget
  * curl
  * tar
  * gzip
  * tree-sitter

## Dark Mode

to set dark mode as preferred mode

* for gtk create and fill the files like in this repo
  * ~/.config/gtk-3.0/settings.ini
  * ~/.config/gtk-4.0/settings.ini
* qt export the environment variable in your rc file like .bashrc or .zshrc
  * `export QT_QPA_PLATFORMTHEME=qt5ct`
* for chrome
  * install `xdg-desktop-portal-hyprland` if needed
  * create and fill `~/.config/xdg-desktop-portal/portals.conf` like in this repo
  * restart the service `systemctl --user restart xdg-desktop-portal`
  * eventually set it in gsettings `gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'`
  * restart all chrome instances

