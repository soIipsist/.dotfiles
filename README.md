# dotfiles

A collection of setup configuration files, tools and scripts aimed at enhancing productivity. Users can tailor their installation preferences specific to their selected operating system.

Each operating system has a subdirectory containing a setup script, a `.json` configuration file named after the OS, and dotfiles for customization. To configure, run the setup script for your OS as described below.

## Installation

Follow these steps to configure your environment:

1. **Navigate to the appropriate directory for your operating system**  
   Choose the directory corresponding to your operating system (`windows`, `mac`, or `linux`). Inside that directory, locate the configuration file specific to your OS (with a `.json` extension).

2. **Edit the configuration file**  
   Open the configuration file for your operating system and adjust the settings as needed. For a comprehensive list of valid configuration parameters, refer to the [valid parameters section](#valid-parameters).

3. **Execute the setup script**  
   Once you've configured the necessary settings, run the provided setup shell script to complete the installation:

   ```bash
    ./setup.sh <dotfile_folder_1> <dotfile_folder_2>

This will automatically configure your environment based on your edits to the configuration file.

## Valid Parameters

### Windows (windows.json)

These are the valid parameters that can be specified in the `windows.json` file:

- **`pc_name`**: Name of your PC.
- **`product_key`**: Windows product key.
- **`environment_variables`**: Dictionary of environment variables.
- **`shortcuts`**: Array of shortcut dictionaries, each with `description`, `hotkey`, and `target_path`.
- **`enabled_features`**: List of enabled Windows features.
- **`disabled_features`**: List of disabled Windows features.
- **`file_explorer_start_folder`**: Start folder in File Explorer (1 = This PC, 2 = Quick Access, 3 = Downloads).
- **`show_file_extensions`**: Whether file extensions are visible (default: `true`).
- **`classic_context_menu`**: Enable/disable classic context menu (default: `true`).
- **`remove_desktop_shortcuts`**: Remove desktop shortcuts (default: `false`).
- **`activate_office`**: Activate Microsoft Office 365 using KMS client key (default: `false`).
- **`fonts_directory`**: Directory containing font files to install.
- **`wallpaper_path`**: Default wallpaper image path.
- **`lockscreen_path`**: Default lock screen image path.
- **`disk_timeout_ac`**: AC disk timeout (default: `0`).
- **`disk_timeout_dc`**: DC disk timeout (default: `0`).
- **`hibernate_timeout_ac`**: AC hibernate timeout (default: `0`).
- **`hibernate_timeout_dc`**: DC hibernate timeout (default: `0`).
- **`standby_timeout_ac`**: AC standby timeout (default: `0`).
- **`standby_timeout_dc`**: DC standby timeout (default: `0`).
- **`monitor_timeout_ac`**: AC monitor timeout (default: `0`).
- **`monitor_timeout_dc`**: DC monitor timeout (default: `0`).
- **`lockscreen_timeout_ac`**: AC lockscreen timeout (default: `0`).
- **`lockscreen_timeout_dc`**: DC lockscreen timeout (default: `0`).
- **`first_day_of_week`**: Sets the first day of the week (default: `0` = Monday).
- **`short_date`**: Short date format (default: `dd/MM/yyyy`).
- **`long_date`**: Long date format (default: `dddd, d MMMM, yyyy`).
- **`short_time`**: Short time format (default: `HH:mm`).
- **`time_format`**: Time format (default: `HH:mm:ss`).
- **`timezone`**: Timezone ID (use `Get-TimeZone -ListAvailable` to view valid formats).
- **`git_username`**: Global Git username.
- **`git_email`**: Global Git email.
- **`dotfiles`**: List of dotfile directory names in the `windows` subdirectory (default: all).
- **`package_providers`**: List of package providers to install (default: all).
- **`chocolatey_packages`**: List of `Chocolatey` packages to install.
- **`winget_packages`**: List of `winget` packages to install.
- **`wsl_packages`**: List of `apt` packages for `wsl` (Ubuntu).
- **`scoop_packages`**: List of `Scoop` packages to install.
- **`windows_packages`**: List of Windows application packages to install.
- **`uninstall_packages`**: Whether to uninstall packages (default: `false`).
- **`reboot`**: Whether to reboot after setup (default: `true`).
- **`reboot_time`**: System reboot time in seconds (default: `0`).

### Linux (linux.json)

The following parameters are valid for the `linux.json` file:

- **`hostname`**: Name of your PC.
- **`apt_packages`**: List of `apt` packages to install.
- **`pip_packages`**: List of `pip` packages to install.
- **`brew_packages`**: List of `brew` packages to install.
- **`git_home`**: Default `git` home path.
- **`git_repos`**: List of git repositories to clone.
- **`git_email`**: Global Git email.
- **`git_username`**: Global Git username.
- **`wallpaper_path`**: Default wallpaper path.
- **`lockscreen_path`**: Default lock screen path.
- **`dotfiles`**: List of dotfile directory names in the `linux` subdirectory (default: all).
- **`dotfiles_directory`**: Default dotfiles directory (default: `$HOME`).
- **`scripts`**: List of scripts to be executed in the dotfile subdirectories. If not specified, all scripts will be executed.
- **`excluded_scripts`**: The scripts specified will not be executed.
- **`install_homebrew`**: Install homebrew to your machine (default: `false`).
- **`install_zoxide`**: Install zoxide (default: `false`).

### macOS (mac.json)

These parameters can be specified in the `mac.json` file:

- **`hostname`**: `HostName` of your PC.
- **`local_hostname`**: `LocalHostName` of your PC.
- **`computer_name`**: `ComputerName`.
- **`install_homebrew`**: Install homebrew to your machine (default: `false`).
- **`brewfile_path`**: Path to the `brewfile` for installing `brew` packages (default: `mac/Brewfile`).
- **`brew_packages`**: List of `brew` packages to install.
- **`brew_cask_packages`**: List of `brew` cask packages to install.
- **`pip_packages`**: List of `pip` packages to install.
- **`git_home`**: Default `git` home path.
- **`git_repos`**: List of git repositories to clone.
- **`git_email`**: Global `git` email.
- **`git_username`**: Global `git` username.
- **`wallpaper_path`**: Default wallpaper path.
- **`default_shell`**: Default shell.
- **`dotfiles`**: List of dotfile directory names in the `mac` subdirectory (default: all).
- **`dotfiles_directory`**: Default dotfiles directory (default: `$HOME`).
- **`scripts`**: List of scripts to be executed in the dotfile subdirectories. If not specified, all scripts will be executed.
- **`excluded_scripts`**: The scripts specified will not be executed.
- **`theme`**: You can change the default theme based on your preferences. A `theme.json` file can be used to specify personalized color values. (default: `.themes/main.json`)

### Examples

- [windows_example.json](https://github.com/soIipsist/dotfiles/blob/main/examples/windows_example.json)
- [linux_example.json](https://github.com/soIipsist/dotfiles/blob/main/examples/linux_example.json)
- [mac_example.json](https://github.com/soIipsist/dotfiles/blob/main/examples/mac_example.json)
