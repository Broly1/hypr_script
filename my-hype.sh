#!/bin/bash

log="my_hype_log.txt"

banner() {
    cat <<'EOF'

╔╗─╔╗────────╔╗────────╔╗
║║─║║────────║║────────║║
║╚═╝╠╗─╔╦══╦═╣║╔══╦═╗╔═╝║
║╔═╗║║─║║╔╗║╔╣║║╔╗║╔╗╣╔╗║
║║─║║╚═╝║╚╝║║║╚╣╔╗║║║║╚╝║
╚╝─╚╩═╗╔╣╔═╩╝╚═╩╝╚╩╝╚╩══╝
────╔═╝║║║
────╚══╝╚╝
EOF
}

clear
banner "$@"

# Check for internet connectivity
check_for_internet() {
    if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
        :
    else
        echo "No internet connection. Unable to download dependencies."
        exit 1
    fi
}

# Prompt user to answer yes or no
ask_user() {
    while true; do
        echo -n "$1 (y/n): "
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

main() {
    check_for_internet "$@"

    # Package lists
    arch_packages=(
        "git"
        "less"
        "base-devel"
        "dosfstools"
        "nano"
        "rust"
        "hyprland"
        "waybar"
        "firefox"
        "engrampa"
        "pipewire"
        "thunar"
        "thunar-archive-plugin"
        "gvfs"
        "wireplumber"
        "ghostty"
        "polkit-gnome"
        "xdg-desktop-portal-hyprland"
        "xdg-desktop-portal"
        "pavucontrol"
        "ttf-font-awesome"
        "ttf-jetbrains-mono"
        "qt5-wayland"
        "qt6-wayland"
        "nwg-look"
        "papirus-icon-theme"
        "qt6-svg"
        "qt6-declarative"
        "cliphist"
        "wl-clipboard"
        "xdg-user-dirs"
        "ly"
    )

    paru_packages=(
        "dracula-gtk-theme"
        "hyprshot"
        "swaync"
        "wlogout"
        "fuzzel"
        "hyprpaper"
        "blueberry"
        "vscodium-bin"
        "network-manager-applet"
    )

    if [[ -f /etc/arch-release ]]; then
        echo -e "\nWe need all these packages:\n"
        echo -e "Arch packages to install:"
        printf "%-30s %-30s %-30s\n" "${arch_packages[@]}" "${paru_packages[@]}"| column -t
        echo -e "\nThis script will only install\nthe missing packages from this list.\n"

        if ! ask_user "Do you want to continue?"; then
            echo "Installation aborted."
            exit 0
        fi

        # Install Arch packages
        for package in "${arch_packages[@]}"; do
            if pacman -Q "$package" >/dev/null 2>&1; then
                echo "$package is already installed."
            else
                echo "Installing missing package: $package"
                sudo pacman -S --noconfirm --needed "$package"
            fi
        done

        if ! sudo pacman -Q paru >/dev/null 2>&1; then
            echo "paru is not installed. Installing..."
            git clone https://aur.archlinux.org/paru-bin.git
            cd paru-bin || exit
            makepkg -si --noconfirm
            cd ../
            rm -rf paru-bin/
        else
            echo "paru is already installed."
        fi

        # Install AUR packages
        for package in "${paru_packages[@]}"; do
            if paru -Q "$package" >/dev/null 2>&1; then
                echo "$package is already installed."
            else
                echo "Installing missing package: $package"
                paru -S --noconfirm --needed "$package"
            fi
        done

        echo -e "\nAll specified packages are now installed."
    else
        echo "Your distro is not supported!"
        exit 1
    fi

    git clone https://github.com/Broly1/hyprland-dots.git
    cd hyprland-dots || exit

    directories=(
        "ghostty"
        "fuzzel"
        "hypr"
        "wallpaper"
        "waybar"
        "wlogout"
        "Thunar"
    )
    for dir in "${directories[@]}"; do
        cp -r "$dir" ~/.config/
        find ~/.config/"$dir" -type f -exec chmod +x {} +
        find ~/.config/"$dir" -type d -exec chmod +x {} +
    done

    # Enable bash color ILoveCandy and 15 simultaneous Downloads
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup || { echo "Failed to back up pacman.conf."; exit 1; }
    sudo sed -i 's/#Color/Color/' /etc/pacman.conf || { echo "Failed to enable Color."; exit 1; }
    if ! grep -q "^ILoveCandy$" /etc/pacman.conf; then
        sudo sed -i '/^Color$/a ILoveCandy' /etc/pacman.conf || { echo "Failed to add ILoveCandy."; exit 1; }
    else
        echo "ILoveCandy is already present in /etc/pacman.conf. Skipping addition."
    fi
    sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 15/' /etc/pacman.conf || { echo "Failed to enable ParallelDownloads."; exit 1; }

    echo "Pacman color, ILoveCandy, and parallel downloads enabled."

    # Enable Bluetooth
    clear
    banner "$@"
    if ask_user "Do you want to enable Bluetooth?"; then
        sudo cp /etc/bluetooth/main.conf /etc/bluetooth/main.conf.backup || { echo "Failed to back up Bluetooth configuration."; exit 1; }
        sudo sed -i 's/#AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf || { echo "Failed to configure Bluetooth."; exit 1; }   
        sudo systemctl start bluetooth.service
        sudo systemctl enable bluetooth.service
        echo "Bluetooth configuration successful."
    else
        echo "Skipping Bluetooth configuration."
    fi

    # Configure zram swap
    clear
    banner "$@"
    if ask_user "Do you want to configure zram swap?"; then
        sudo cp /etc/systemd/zram-generator.conf /etc/systemd/zram-generator.conf.backup || { echo "Failed to back up zram configuration."; exit 1; }
        sudo tee /etc/systemd/zram-generator.conf >/dev/null <<EOF || { echo "Failed to configure zram."; exit 1; }
[zram0]
zram-size = ram
EOF
    else
        echo "Skipping zram configuration."
    fi

    # Enble ly login manager
     clear
    banner "$@"
    if ask_user "Do you want to enable ly login manager?"; then
        sudo systemctl enable ly.service
        sudo sed -i 's/animation = none/animation = doom/' /etc/ly/config.ini || { echo "Failed to change ly animation."; exit 1; }      
        sudo sed -i 's/hide_borders = false/hide_borders = true/' /etc/ly/config.ini || { echo "Failed to change ly animation."; exit 1; }
       else
        echo "Skipping enabling ly."
    fi

    # Set gtk + icons themes
    echo "Setting GTK theme and icon theme..."
    gsettings set org.gnome.desktop.interface gtk-theme Dracula || { echo "Failed to set GTK theme."; exit 1; }
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark || { echo "Failed to set icon theme."; exit 1; }
    gsettings set org.gnome.desktop.wm.preferences button-layout : || { echo "Failed to set window manager button layout."; exit 1; }

    # Set Thunar as default for opening folders
    xdg-mime default thunar.desktop inode/directory || { echo "Failed to set Thunar as default file manager."; exit 1; }
}

main "$@" | tee "$log" 
