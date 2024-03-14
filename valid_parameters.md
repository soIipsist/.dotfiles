# Valid parameters

## Windows

The following is a list of valid parameters that can be specified in your `windows.json` file:

`pc_name`: Sets the name of your PC.

`product_key`: Sets Windows product key.

`environment_variables`: Sets environment variables (must be a dictionary).

`shortcuts`: An array of shortcuts for existing applications. For each shortcut dictionary, `description`, `hotkey` and `target_path` attributes must be defined.

`enabled_features`: Specifies a list of Windows enabled features.

`disabled_features`: Specifies a list of Windows disabled features.

`file_explorer_start_folder`: Specifies start folder launch path [This PC: 1], [Quick access: 2], [Downloads: 3]

`show_file_extensions`: Indicates whether file extensions should be visible. Default value: true.

`classic_context_menu`: Enable/disable classic context menu. Default value: true.

`remove_desktop_shortcuts`: Indicates whether to remove existing windows desktop shortcuts. Default value: false.

`activate_office`: Indicates whether to activate Microsoft Office 365 using KMS client key. Default value: false.

`fonts_directory`: Specifies the directory containing font files to be installed.

`wallpaper_path`: Specifies the default wallpaper image using the provided path.

`lockscreen_path`: Specifies the default lock screen image using the provided path.

`disk_timeout_ac`: Alternating Current (AC) disk timeout. Set by default to 0.

`disk_timeout_dc`: Direct Current (DC) disk timeout. Set by default to 0.

`hibernate_timeout_ac`: Alternating Current (AC) hibernate timeout. Set by default to 0.

`hibernate_timeout_dc`: Direct Current (DC) hibernate timeout. Set by default to 0.

`standby_timeout_ac`: Alternating Current (AC) standby timeout. Set by default to 0.

`standby_timeout_dc`: Direct Current (DC) standby timeout. Set by default to 0.

`monitor_timeout_ac`: Alternating Current (AC) monitor timeout. Set by default to 0.

`monitor_timeout_dc`: Direct Current (DC) disk monitor. Set by default to 0.

`lockscreen_timeout_ac`: Alternating Current (AC) lockscreen timeout. Set by default to 0.

`lockscreen_timeout_dc`: Direct Current (DC) lockscreen timeout. Set by default to 0.

`first_day_of_week`: Sets first day of the week. Set by default to 0 (Monday).

`short_date`: Sets short date format. Set by default to "dd/MM/yyyy".

`long_date`: Sets long date format. Set by default to "dddd, d MMMM, yyyy".

`short_time`: Sets short time format. Set by default to "HH:mm".

`time_format`: Sets time format. Set by default to "HH:mm:ss".

`timezone`: Sets timezone id. To view a list of all valid timezone formats, execute `Get-TimeZone -ListAvailable`.

`git_username`: Sets global git username.

`git_email`: Sets global git email.

`dotfiles`: Specifies a list of dotfile directory names in the `windows` subdirectory. By default, all dotfile directories will be taken into account.

`package_providers`: Specifies a list of package providers to be installed. By default, all package providers will be installed.

`chocolatey_packages`: Specifies a list of `Chocolatey` packages to be installed.

`winget_packages`: Specifies a list of `winget` packages to be installed.

`wsl_packages`: Specifies a list of `apt` packages to be installed within `wsl` (Ubuntu).

`scoop_packages`: Specifies a list of `Scoop` packages to be installed.

`windows_packages`: Specifies a list of Windows application packages to be installed.

`uninstall_packages`: Indicates whether to install or uninstall the specified packages. Set by default to false.

`reboot`: Indicates whether to reboot after the setup is complete. Default value: true.

`reboot_time`: System reboot time in seconds. Default value: 0.

## Linux

The following is a list of valid parameters that can be specified in your `linux.json` file:

`hostname`: Sets the name of your PC.

`apt_packages`: Specifies a list of `apt` packages that should be installed.

`pip_packages`: Specifies a list of `pip` packages that should be installed.

`git_email`: Sets global git email.

`git_username`: Sets global git username.

`wallpaper_path`: Sets the default wallpaper.

`lockscreen_path`: Sets the default lockscreen.

`dotfiles`: Specifies a list of dotfile directory names in the `linux` subdirectory. By default, `all` dotfile directories will be taken into account.

## macOS

The following is a list of valid parameters that can be specified in your `mac.json` file:

`hostname`: Sets the `HostName` of your PC.

`local_hostname`: Sets the `LocalHostName` of your PC.

`computer_name`: Sets `ComputerName`.

`brewfile_path`: Sets the `brewfile` path to install `brew` packages from. By default `mac/Brewfile` is used.

`pip_packages`: Specifies a list of `pip` packages that should be installed.

`git_email`: Sets global git email.

`git_username`: Sets global git username.

`wallpaper_path`: Sets the default wallpaper.

`default_shell`: Sets the default shell.

`dotfiles`: Specifies a list of dotfile directory names in the `mac` subdirectory. By default, `all` dotfile directories will be taken into account.

## Examples

1. [windows_example.json](https://github.com/soIipsis/dotfiles/blob/main/examples/windows_example.json)
2. [linux_example.json](https://github.com/soIipsis/dotfiles/blob/main/examples/linux_example.json)
3. [mac_example.json](https://github.com/soIipsis/dotfiles/blob/main/examples/mac_example.json)
