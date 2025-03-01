function Get-Default-Values-From-Json {
    param (
        [object]$WindowsData,
        [string]$DotfilesDirectory 
    )
    
    foreach ($key in $WindowsData.PSObject.Properties.Name) {
        $value = $WindowsData.$key
        
        # Check if value is a string, starts with $, and corresponds to an environment variable
        if ($value -is [string] -and $value.StartsWith("$") ) {
            $envVarName = $value.Substring(1) # Remove the $ symbol
            $envVarValue = [System.Environment]::GetEnvironmentVariable($envVarName)
            
            if ($envVarValue) {
                $WindowsData.$key = $envVarValue
            }
        }

    }
    
    return $WindowsData
}

function Replace-Root {
    param (
        [string]$Value,
        [string]$RootPath
    )

    # Ensure the value starts with '/' before replacing
    if ($Value -match "^/") {
        return "$RootPath$Value"
    }

    return $Value
}

$ParentDirectory = $PSScriptRoot
$DotfilesDirectory = Split-Path -Path $PSScriptRoot -Parent
$WindowsDataPath = Join-Path -Path $ParentDirectory -ChildPath "windows.json"
# $WindowsDataPath = "..\windows\windows_example.json"

$WindowsData = Get-Content -Path $WindowsDataPath -Raw | ConvertFrom-Json
$WindowsData = Get-Default-Values-From-Json -WindowsData $WindowsData -DotfilesDirectory $ParentDirectory

Write-Host $DotfilesDirectory

# windows settings
$global:PCName = $WindowsData.pc_name
$global:ProductKey = $WindowsData.product_key
$global:EnvironmentVariables = $WindowsData.environment_variables
$global:Shortcuts = $WindowsData.shortcuts
$global:EnabledFeatures = $WindowsData.enabled_features
$global:DisabledFeatures = $WindowsData.disabled_features
$global:FileExplorerStartFolder = $WindowsData.file_explorer_start_folder
$global:ShowFileExtensions = $WindowsData.show_file_extensions
$global:ClassicContextMenu = $WindowsData.classic_context_menu
$global:RemoveDesktopShortcuts = $WindowsData.remove_desktop_shortcuts
$global:ActivateOffice = $WindowsData.activate_office
$global:FontsDirectory = Replace-Root -Value $WindowsData.fonts_directory -RootPath $DotfilesDirectory
$global:WallpaperPath = Replace-Root -Value $WindowsData.wallpaper_path -RootPath $DotfilesDirectory
$global:LockscreenPath = Replace-Root -Value $WindowsData.lockscreen_path -RootPath $DotfilesDirectory

# packages, dotfiles
$global:Dotfiles = $WindowsData.dotfiles
$global:ChocolateyPackages = $WindowsData.chocolatey_packages
$global:WingetPackages = $WindowsData.winget_packages
$global:WSLPackages = $WindowsData.wsl_packages
$global:ScoopPackages = $WindowsData.scoop_packages
$global:WindowsPackages = $WindowsData.windows_packages
$global:PipPackages = $WindowsData.pip_packages

$global:UninstallPackages = $WindowsData.uninstall_packages
$global:PackageProviders = $WindowsData.package_providers

# power configuration
$global:DiskTimeoutAC = $WindowsData.disk_timeout_ac
$global:DiskTimeoutAC = $WindowsData.disk_timeout_ac
$global:HibernateTimeoutAC = $WindowsData.hibernate_timeout_ac
$global:HibernateTimeoutDC = $WindowsData.hibernate_timeout_ac
$global:MonitorTimeoutAC = $WindowsData.monitor_timeout_ac
$global:MonitorTimeoutDC = $WindowsData.monitor_timeout_dc
$global:StandbyTimeoutAC = $WindowsData.standby_timeout_ac
$global:StandbyTimeoutDC = $WindowsData.standby_timeout_dc
$global:LockscreenTimeoutAC = $WindowsData.lockscreen_timeout_ac
$global:LockscreenTimeoutDC = $WindowsData.lockscreen_timeout_ac

# regional format
$global:FirstDayOfWeek = $WindowsData.first_day_of_week
$global:ShortDate = $WindowsData.short_date
$global:LongDate = $WindowsData.long_date
$global:ShortTime = $WindowsData.short_time
$global:TimeFormat = $WindowsData.time_format
$global:Timezone = $WindowsData.timezone 

# git
$global:GitUserName = $WindowsData.git_username
$global:GitUserEmail = $WindowsData.git_email

# reboot
$global:Reboot = $WindowsData.reboot
$global:RebootTime = $WindowsData.reboot_time

# system env
$global:UserProfilePath = [System.Environment]::GetFolderPath('UserProfile')
$global:StartMenuPath = "$UserProfilePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
$global:ProgramFilesPath = [System.Environment]::GetFolderPath('ProgramFiles')
$global:ProgramFilesX86Path = [System.Environment]::GetFolderPath('ProgramFilesX86')