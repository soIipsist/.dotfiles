function Set-PC-Name {
    param(
        [string]$PCName
    )

    if (!$PCName) {
        return
    }
    
    Write-Host "Renaming PC ($env:COMPUTERNAME -> $PCName)" -ForegroundColor Green;
    
    if ($env:COMPUTERNAME -ne $PCName) {
        Rename-Computer -NewName $PCName -Force;
        Write-Host "PC renamed, restart it to see the changes." -ForegroundColor Green;
    }
}


function Set-Product-Key {
    param (
        [string] $ProductKey
    )
   
    if ($ProductKey) {
        $OriginalProductKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        Write-Host "Setting Windows product key ($OriginalProductKey -> $ProductKey)" -ForegroundColor Green
        slmgr /ipk $ProductKey
    }
}

function Set-Environment-Variables {
    param (
        $EnvironmentVariables
    )

    if ($null -eq $EnvironmentVariables) {
        return
    }

    $ht = @{}
    $EnvironmentVariables.psobject.properties | ForEach-Object { $ht[$_.Name] = $_.Value }
    $EnvironmentVariables = $ht

    # Enable delayed expansion in the script
    $env:EnableDelayedExpansion = $true

    Write-Host "Setting environment variables..." - -ForegroundColor Yellow
    
    if ($EnvironmentVariables -and $EnvironmentVariables.Count -gt 0) {
        
        foreach ($key in $EnvironmentVariables.Keys) {
            $values = $EnvironmentVariables[$key]
            
            $values
            if ($values -and $values.Count -gt 0) {
                $pathString = $values -join ';'

                Write-Output "Setting $key : $pathString"

                # Set the environment variable
                try {
                    [System.Environment]::SetEnvironmentVariable($key, $pathString, [System.EnvironmentVariableTarget]::Machine)
    
                }
                catch {
                    Write-Host "Error setting environment variable!" -ForegroundColor Red
                }
            }
        }
    }
   
}

function Set-Windows-Shortcuts {
    param(
        [array] $Shortcuts
    )

    if ( $Shortcuts.Count -gt 0) {
        $shell = New-Object -comobject wscript.shell
    }
   

    foreach ($shortcut in $Shortcuts) {
        $TargetPath = $shortcut.target_path
        $Hotkey = $shortcut.hotkey
        $Description = $shortcut.description

        if (!$TargetPath -or -not (Test-Path -Path $TargetPath)) {
            Write-Host "Invalid target path."
            return
        }

        $ApplicationName = $TargetPath -replace '.*/([^/]+)\.exe$', '$1'
        $ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$ApplicationName.lnk"
        
        if (!$Description) {
            $Description = "Launch $ApplicationName"
        }

        $CreatedShortcut = $shell.CreateShortCut($ShortcutPath)
        $CreatedShortcut.Description = $Description
        $CreatedShortcut.TargetPath = $TargetPath
        $CreatedShortcut.HotKey = $Hotkey
        $CreatedShortcut.Save()

    }
    
}


function Get-Feature-State {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Feature 
    )

    $state = (Get-WindowsOptionalFeature -FeatureName $Feature -Online).State
    Write-Host "$Feature" -ForegroundColor Green
    return $state
}


function Set-Windows-Features {
   
    param (
        [bool]
        $Enable,

        [array]
        $Features
    )

    foreach ($Feature in $Features) {
        $state = Get-Feature-State -Feature $Feature

        if ($Enable -and $state -ne "Enabled") {
            Write-Host "Enabling $Feature..." -ForegroundColor Green
            Enable-WindowsOptionalFeature -FeatureName $Feature -Online -All -NoRestart
        }
        elseif (-not $Enable -and $state -eq "Enabled") {
            Write-Host "Disabling $Feature..." -ForegroundColor Red
            Disable-WindowsOptionalFeature -FeatureName $Feature -Online -NoRestart
        }
        else {
            $featureStatus = if ($Enable) { 'enabled' } else { 'disabled' }
            Write-Host "$Feature is already $featureStatus." -ForegroundColor Green
        }
        
    }
}


function Set-FileExplorer-StartFolder {
    param(
        [int]
        $FileExplorerStartFolder
    )

    if (!$FileExplorerStartFolder) {
        return;
    }
    Write-Host "Start folder of Windows File Explorer value: $FileExplorerStartFolder" -ForegroundColor Green;

    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";

    Set-ItemProperty -Path $RegPath -Name "LaunchTo" -Value $FileExplorerStartFolder; # [This PC: 1], [Quick access: 2], [Downloads: 3]
}


function Set-Show-File-Extensions {
    param(
        $ShowFileExtensions = $true
    )

    if ($null -eq $ShowFileExtensions) {
        return
    }
    
    
    $Value = !$ShowFileExtensions
    $Value = [int]($Value)

    Write-Host "Show file extensions: $ShowFileExtensions" -ForegroundColor Green;

    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced";
    Set-ItemProperty -Path $RegPath -Name "HideFileExt" -Value $Value;
}

function Set-Classic-ContextMenu {
    param(
        $ClassicContextMenu = $false
    )
    
    if ($null -eq $ClassicContextMenu) {
        return
    }

    $RegPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32";
    $RegKey = "(Default)";

    $Status = if ($ClassicContextMenu) { 'activated' } else { 'deactivated' }

    if ($ClassicContextMenu) {
        reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
        New-ItemProperty -Path $RegPath -Name $RegKey -PropertyType String;
        Set-ItemProperty -Path $RegPath -Name $RegKey -Value "";
    }
    else {
        reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
    }
  
    Write-Host "Classic Context Menu successfully $Status." -ForegroundColor Green;
}


function Remove-Desktop-Shortcuts {
    param(
        $RemoveDesktopShortcuts = $false
    )
     
    if (!$RemoveDesktopShortcuts) {
        return
    }
    
    $UserDesktopPath = [Environment]::GetFolderPath("Desktop");
    $PublicDesktopPath = "${env:Public}\Desktop";

    Get-ChildItem -Path "${UserDesktopPath}\*" -Include "*.lnk", "*.url" -Recurse | Remove-Item;
    Get-ChildItem -Path "${PublicDesktopPath}\*" -Include "*.lnk", "*.url" -Recurse | Remove-Item;

    Write-Host "Shorcuts in desktop successfully deleted." -ForegroundColor Green;
}


function Enable-Microsoft-Office {

    param(
        $ActivateOffice = $false
    )

    if (!$ActivateOffice) {
        return;
    }


    Write-Host "Activating Microsoft Office..." -ForegroundColor Green
    Set-Location -Path "$env:ProgramFiles\Microsoft Office\Office16"

    $licenseFiles = Get-ChildItem -Path "..\root\Licenses16" -Filter "proplusvl_kms*.xrm-ms" -File
    foreach ($licenseFile in $licenseFiles) {
        & cscript ospp.vbs /inslic:"..\root\Licenses16\$licenseFile"
    }

    cscript ospp.vbs /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99
    cscript ospp.vbs /unpkey:BTDRB >nul
    cscript ospp.vbs /unpkey:KHGM9 >nul
    cscript ospp.vbs /unpkey:CPQVG >nul
    cscript ospp.vbs /sethst:kms8.msguides.com
    cscript ospp.vbs /setprt:1688
    cscript ospp.vbs /act
}

function Set-Wallpaper {
    param(
        [string] $WallpaperPath
    )

    if (!$WallpaperPath -or !(Test-Path -Path $WallpaperPath)) {
        Write-Host "Path does not exist." -ForegroundColor Red
        return;
    }

    Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -Name WallPaper -Value $WallpaperPath
    Write-Host "Successfully set wallpaper to $WallpaperPath." -ForegroundColor Green

}

function Set-Lockscreen {

    param(
        [string] $LockscreenPath
    )

    if (!$LockscreenPath -or !(Test-Path -Path $LockscreenPath)) {
        Write-Host "Path does not exist." -ForegroundColor Red
        return;
    }

    # adding this just in case it doesn't work
    New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name LockScreenImagePath -Value $LockscreenPath -PropertyType String -Force
    New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name LockScreenImageUrl -Value $LockscreenPath -PropertyType String -Force
    New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name LockScreenImageStatus -Value "0" -PropertyType DWord -Force
    
    $RegPath = "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    $RegName = "LockScreenImage";
    $RegPath
    reg.exe add $RegPath /f
    New-ItemProperty -Path "Registry::$RegPath" -Name $RegName -Value $LockscreenPath -PropertyType String -Force
    

    Write-Host "Successfully set wallpaper to $LockscreenPath." -ForegroundColor Green
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
function Install-Fonts {
    param(
        [string] $FontsDirectory
    )
    
    if (!$FontsDirectory) {
        return
    }

    $Fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $FontCollection = New-Object System.Drawing.Text.PrivateFontCollection
    $InstalledFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families


    $FontFiles = Get-All-Files-In-Paths $FontsDirectory -Filter "*.ttf"
    
    
    foreach ($File in $FontFiles) {
        $FileName = $File.FullName
        $FontCollection.AddFontFile($FileName)
        $FontFamily = $FontCollection.Families[0].Name
        
        if ($FontFamily -notin $InstalledFonts) {
            Write-Host "Installing $FontFamily..." -ForegroundColor Green   
            Get-ChildItem $FileName | ForEach-Object { $fonts.CopyHere($_.fullname) }
        }
        
    }
    

}

function Set-Power-Configuration {
    param(       
        $DiskTimeoutAC = 0,

    
        $DiskTimeoutDC = 0,

        
        $HibernateTimeoutAC = 0,
        
    
        $HibernateTimeoutDC = 0,

    
        $StandbyTimeoutAC = 0,

    
        $StandbyTimeoutDC = 0,

        
        $MonitorTimeoutAC = 0,

        
        $MonitorTimeoutDC = 0,

        
        $LockscreenTimeoutAC = 0,

    
        $LockscreenTimeoutDC = 0
        
    )

    $variables = @(
        "DiskTimeoutAC",
        "DiskTimeoutDC",
        "HibernateTimeoutAC",
        "HibernateTimeoutDC",
        "StandbyTimeoutAC",
        "StandbyTimeoutDC",
        "MonitorTimeoutAC",
        "MonitorTimeoutDC",
        "LockscreenTimeoutAC",
        "LockscreenTimeoutDC"
    )

    foreach ($var in $variables) {
        if ($null -eq (Get-Variable -Name $var -ValueOnly)) {
            Set-Variable -Name $var -Value 0
        }
    }


    # AC: Alternating Current (Wall socket).
    # DC: Direct Current (Battery).

    # Set turn off disk timeout (in minutes / 0: never)
    powercfg -change "disk-timeout-ac" $DiskTimeoutAC;
    powercfg -change "disk-timeout-dc" $DiskTimeoutDC;

    # Set hibernate timeout (in minutes / 0: never)
    powercfg -change "hibernate-timeout-ac" $HibernateTimeoutAC;
    powercfg -change "hibernate-timeout-dc" $HibernateTimeoutDC;

    # Set sleep timeout (in minutes / 0: never)
    powercfg -change "standby-timeout-ac" $StandbyTimeoutAC;
    powercfg -change "standby-timeout-dc" $StandbyTimeoutDC;

    # Set turn off screen timeout (in minutes / 0: never)
    powercfg -change "monitor-timeout-ac" $MonitorTimeoutAC;
    powercfg -change "monitor-timeout-dc" $MonitorTimeoutDC;

    # Set turn off screen timeout on lock screen (in seconds / 0: never)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $LockscreenTimeoutAC;
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $LockscreenTimeoutDC;
    powercfg /SETACTIVE SCHEME_CURRENT;

    Write-Host "Power plan successfully updated." -ForegroundColor Green;
}


function Set-Regional-Format {

    param(
        $FirstDayOfWeek = "0",

        $ShortDate = "dd/MM/yyyy",

        $LongDate = "dddd, d MMMM, yyyy",

        $ShortTime = "HH:mm",

        $TimeFormat = "HH:mm:ss"
    )

    
    $RegPath = "HKCU:\Control Panel\International";

    $RegistryValues = @(
        "iFirstDayOfWeek",
        "sShortDate",
        "sLongDate",
        "sShortTime",
        "sTimeFormat"
    )

    $Variables = @("FirstDayOfWeek", "ShortDate", "LongDate", "ShortTime", "TimeFormat")

    for ($i = 0; $i -lt $RegistryValues.Count; $i++) {
        $Var = Get-Variable -Name $Variables[$i] -ValueOnly

        if (-not($null -eq $Var)) {
            $RegValue = $RegistryValues[$i]
            Write-Host "Successfully set registry value '$RegValue' to '$Var'"
            Set-ItemProperty -Path $RegPath -Name $RegValue -Value $Var;
        }         
    }

    Write-Host "Regional format successfully updated." -ForegroundColor Green;
}

function Reboot {
    param (
        $Reboot = $false,

        [int]
        $RebootTime = 0
    )

    if ($null -eq $Reboot) {
        $Reboot = $false
        return
    }

    if ($Reboot) {
        Write-Host "Restarting the PC in $RebootTime seconds..." -ForegroundColor Green;
        Start-Sleep -Seconds $RebootTime;
        Restart-Computer;
    }

}
