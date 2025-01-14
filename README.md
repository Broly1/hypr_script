**Distro**: Archlinux  
**Theme**: Dracula  
**Icons**: Papirus Dark  
**Terminal**: Ghostty  
**Wallpaper**: [Loop](https://basicappleguy.com/basicappleblog/strokes)

### Additional Information :upside_down_face: :upside_down_face:  
**Installation**:  
Install minimal Archlinux with NetworkManager and PipeWire for audio.  
Use this [OneLiner](https://github.com/Broly1/hypr_script/blob/master/my-hype.sh) to install and configure everything.  
<pre>
<code>curl -o my-hype.sh https://raw.githubusercontent.com/Broly1/hypr_script/master/my-hype.sh && chmod +x my-hype.sh && ./my-hype.sh</code>
</pre>  

## Video
https://files.catbox.moe/t6kl3h.mp4

This script is an automated installer for Arch Linux systems, designed to set up a range of packages, settings, and customizations for the Hyprland desktop environment. It performs several tasks, including package installation, system and graphical environment configuration, and theme customizations. Below, I explain what each part of the script does:

### 1. **Main Function:**  
The `main()` function is responsible for running the main flow of the script. It begins by checking the internet connection and then proceeds with the installation and configuration of necessary packages.

   **Inside the `main()` function:**  

   - **Package Check and Installation:**  
     The script defines two lists of packages:  
     - `arch_packages`: essential system packages (like `git`, `rust`, `firefox`, among others).  
     - `paru_packages`: additional packages from the AUR (Arch User Repository).  
     
     The script checks if these packages are already installed, using `pacman` for the official repository packages and `paru` for AUR packages. If a package is missing, it will be automatically installed.

   - **Installing `paru`:**  
     If `paru` (an AUR helper) is not yet installed, the script clones the official repository and installs `paru` from the source code.

   - **Installing AUR Packages:**  
     Once `paru` is installed, the script uses it to install AUR packages that are missing from the system.

   - **Cloning Configuration Repository:**  
     The script clones a repository with specific configurations for Hyprland (`hyprland-dots`) and copies various configuration directories to the `~/.config/` directory.

   - **Adjusting `pacman.conf`:**  
     The script enables color display in `pacman`, activates the `ILoveCandy` visual effect for `pacman`, and sets the number of simultaneous downloads to 15 by editing the `pacman` configuration file.

   - **Bluetooth Configuration:**  
     The script asks the user if they want to enable Bluetooth. If the user agrees, it adjusts the Bluetooth configuration file and enables the Bluetooth service on the system.

   - **Zram Configuration:**  
     The script asks the user if they want to configure Zram, a memory compression technique that simulates swap. If the user agrees, the script adjusts the `/etc/systemd/zram-generator.conf` file.

   - **Configuring Login Manager `ly`:**  
     The script asks the user if they want to enable `ly` (a login manager). If yes, the script sets it to start automatically and adjusts the login animation.

   - **GTK and Icon Theme Configuration:**  
     The script sets the GTK theme to "Dracula" and the icon theme to "Papirus-Dark" using the `gsettings` command.

   - **Setting Thunar as the Default File Manager:**  
     The script sets Thunar as the default file manager for opening folders on the system.

### 2. **Output and Log:**  
   - The script ends with a success message and logs the entire process in the `my_hype_log.txt` file, which can be consulted later for diagnostics.

This script installs configurations for my monitors, so don’t forget to adjust the resolution in the [hyprland.conf](https://github.com/Broly1/hyprland-dots/blob/hyper1/hypr/hyprland.conf) file.  
If you prefer to install manually or modify something, check the official repository:  
[https://github.com/Broly1/hyprland-dots](https://github.com/Broly1/hyprland-dots)

```
# See https://wiki.hyprland.org/Configuring/Monitors/ for more details.
monitor=DVI-D-1, 1920x1080@144, 2560x0, 1
monitor=DP-1, 2560x1080@200, 2560x1080, 1
```

---
