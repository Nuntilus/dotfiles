# Usage
```
stow <config>
## use --rebase to adopt other configs
```
## Install
Run `./setup.sh` on an Arch-based system to install Paru and the packages in
`packages.txt`, symlink custom binaries and systemd files, and Stow the
remaining configurations into your home directory.

## Fixe playback isues
```
sudo pacman -S pipewire pipewire-pulse wireplumber
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
# Zsh plugins
```
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```
# Dependenys
The complete package list is in `packages.txt`. Run `./setup.sh` to install
it, including the runtime dependencies used by the Hyprland, Waybar, Zsh,
Fastfetch, and Tmux configurations.
## hypr
- hyprland
- hyprpaper
- hypridle
- hyprlock
## other
- wofi
- waybar
- alacritty
- pipewire
- pipewire-pulse
- wireplumber
- yazi
- wlogout
- Nvim
- nwg-look
- nwg-displays
- nmtui-go
- swaync
- ttf-jetbrains-mono
- zsh
- stow
