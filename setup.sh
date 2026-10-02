#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bin_dir="$repo_dir/.bin"
package_file="$repo_dir/packages.txt"

if [[ $EUID -eq 0 ]]; then
    echo "Run this script as your normal user, not root." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman is required." >&2
    exit 1
fi

install_paru() {
    if command -v paru >/dev/null 2>&1; then
        return
    fi

    sudo pacman -S --needed --noconfirm git base-devel

    local build_dir
    build_dir=$(mktemp -d)
    trap 'rm -rf -- "$build_dir"' EXIT
    git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
    (
        cd "$build_dir/paru"
        makepkg -si --noconfirm
    )
    trap - EXIT
    rm -rf -- "$build_dir"
}

link_bin_files() {
    local source relative target target_root

    while IFS= read -r -d '' source; do
        relative=${source#"$bin_dir"/}
        target_root=/

        case "$relative" in
            .config/*)
                target_root=$HOME
                ;;
        esac

        target="$target_root/$relative"
        if [[ "$target_root" == / ]]; then
            sudo mkdir -p -- "$(dirname -- "$target")"
            if [[ -e "$target" && ! -L "$target" ]]; then
                sudo mv -- "$target" "$target.backup.$(date +%s)"
            fi
            sudo ln -sfn -- "$source" "$target"
        else
            mkdir -p -- "$(dirname -- "$target")"
            if [[ -e "$target" && ! -L "$target" ]]; then
                mv -- "$target" "$target.backup.$(date +%s)"
            fi
            ln -sfn -- "$source" "$target"
        fi
    done < <(find "$bin_dir" -type f -print0)
}

install_packages() {
    mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' "$package_file")
    ((${#packages[@]} > 0)) || return
    paru -S --needed --noconfirm -- "${packages[@]}"
}

switch_to_pipewire() {
    if ! pacman -Qq pulseaudio >/dev/null 2>&1; then
        return
    fi

    echo "Replacing native PulseAudio with PipeWire's PulseAudio-compatible server."
    systemctl --user disable --now pulseaudio.service 2>/dev/null || true
    local pulse_packages=(pulseaudio)
    pacman -Qq pulseaudio-bluetooth >/dev/null 2>&1 &&
        pulse_packages+=(pulseaudio-bluetooth)
    sudo pacman -R --noconfirm "${pulse_packages[@]}"
}

stow_configs() {
    local config package
    command -v stow >/dev/null 2>&1 || {
        echo "stow was not installed." >&2
        return 1
    }

    for config in "$repo_dir"/*/; do
        package=${config%/}
        package=${package##*/}
        [[ "$package" == ".bin" ]] && continue
        stow --restow --target "$HOME" "$package"
    done
}

install_paru
switch_to_pipewire
install_packages
link_bin_files
stow_configs
systemctl --user daemon-reload
systemctl --user enable --now pipewire pipewire-pulse wireplumber
systemctl --user enable --now battery-low.path battery-low.timer
paru -Rns kitty
notify-send "Setup finished" --urgency=critical
