y#!/bin/bash

# Check for internet connectivity
check_for_internet() {
    clear
    if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
        :
    else
        echo "No internet connection. Unable to download dependencies."
        exit 1
    fi
}

display_warning() {
    echo "The following packages will be installed:"
    for pkg in "${arch_packages[@]}" "${paru_packages[@]}"; do
        echo "Package: $pkg"
    done
    echo "Do you want to continue? (Y/n)"
    read -r confirm
    case "$confirm" in
        y|Y) ;;
        *) exit ;;
    esac
}

check_for_internet "$@"

# Install the missing packages if we don't have them
arch_packages=("git" "rust" "hyprland" "waybar" "firefox" "file-roller" "pipewire" "thunar" "wireplumber" "foot" "polkit-gnome" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk" "swaymsg" "pavucontrol" "ttf-font-awesome" "ttf-jetbrains-mono" "qt5-wayland" "qt6-wayland" "nwg-look" "papirus-icon-theme")
echo "Installing pacman pkgs: ${arch_packages[*]}"

if [[ -f /etc/arch-release ]]; then
    display_warning
    for package in "${arch_packages[@]}"; do
        if ! sudo pacman -Q "$package" >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm --needed "$package"
        else
            echo "$package is already installed."
        fi
    done
else
    echo "Your distro is not supported!"
    exit 1
fi

# Install paru (AUR helper)
if ! sudo pacman -Q paru >/dev/null 2>&1; then
    echo "paru is not installed. Installing..."
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si
    cd ../
    rm -rf paru/
else
    echo "paru is already installed."
fi

# Install aur packages
paru_packages=("dracula-gtk-theme" "hyprshot" "swaync" "wlogout" "fuzzel" "hyprpaper" "blueberry" "network-manager-applet")
echo "Installing aur pkgs: ${paru_packages[*]}"
for package in "${paru_packages[@]}"; do
    if ! paru -Q "$package" >/dev/null 2>&1; then
        paru -S --noconfirm --needed "$package"
    else
        echo "$package is already installed."
    fi
done

git clone https://github.com/Broly1/hyprland-dots.git
cd hyprland-dots || exit

directories=("foot" "fuzzel" "hypr" "wallpaper" "waybar" "wlogout")
for dir in "${directories[@]}"; do
    cp -r "$dir" ~/.config/
    find ~/.config/"$dir" -type f -exec chmod +x {} +
    find ~/.config/"$dir" -type d -exec chmod +x {} +
done

# Desktop Manager Setup (optional)
echo "Would you like to install the SDDM login manager?"
echo "Note: If you're using GNOME desktop, skip this step."
echo "      Only install SDDM if you are installing on vanilla arch with no Gnome or KDE desktop environments."
echo "(Y/n)"
read -r choice
case "$choice" in
    y|Y)
        echo "Installing SDDM..."
        sudo pacman -S --noconfirm sddm
        sudo systemctl enable sddm.service
        echo "SDDM installed and enabled."
        ;;
    *)
        echo "Skipping SDDM setup."
        ;;
esac


