function Set-PC-Name {
    param(
        [string]$PCName
    )

    if (-not $PCName) {
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

    Write-Host "Setting environment variables..." -ForegroundColor Yellow
    
    if ($EnvironmentVariables -and $EnvironmentVariables.Count -gt 0) {
        
        foreach ($key in $EnvironmentVariables.Keys) {
            $pathString = $EnvironmentVariables[$key]

            if ($pathString -and $pathString.Count -gt 0 -and $pathString -is [string]) {
                $match = [regex]::Matches($pathString, "%$key%")
                
               if ($match.Count -gt 0) {
                    $existingValue = [System.Environment]::GetEnvironmentVariable($key, [System.EnvironmentVariableTarget]::Machine)
                    
                    
                    if ($existingValue) {
                        Write-Host "EXISTING VALUE: $($match.Value)" -ForegroundColor Green
                        $pathString = $pathString.Replace($match.Value, $existingValue)                    
                    }
                }

                Write-Host "Setting $key : $pathString" -ForegroundColor Green
                
                try {
                    [System.Environment]::SetEnvironmentVariable($key, $pathString, [System.EnvironmentVariableTarget]::Machine)
    
                }
                catch {
                    Write-Host "Error setting environment variable!" -ForegroundColor Red
                }
                
            }else{
                Write-Host "Invalid format for path string: $pathString."
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

        try{
            
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
            Write-Host "$Hotkey was set for $TargetPath." -ForegroundColor Green
        }
        catch {
            Write-Host "Could not set shortcut key $Hotkey to $TargetPath." -ForegroundColor Red
        } 
     
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

    if (-not $FileExplorerStartFolder) {
        return
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
     
    if (-not $RemoveDesktopShortcuts) {
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

    if (-not $ActivateOffice) {
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

    if (-not $WallpaperPath){
        return 
    }

    if (-not (Test-Path -Path $WallpaperPath)) {
        Write-Host "Wallpaper path $WallpaperPath does not exist." -ForegroundColor Red
        return
    }

    Set-ItemProperty -Path "HKCU:Control Panel\Desktop" -Name WallPaper -Value $WallpaperPath
    Write-Host "Successfully set wallpaper to $WallpaperPath." -ForegroundColor Green

}

function Set-Lockscreen {

    param(
        [string] $LockscreenPath
    )
    
    if (-not $LockscreenPath){
        return 
    }

    if (-not (Test-Path -Path $LockscreenPath)) {
        Write-Host "Lockscreen path $LockscreenPath does not exist." -ForegroundColor Red
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
    
    Write-Host "Successfully set lockscreen to $LockscreenPath." -ForegroundColor Green
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
function Install-Fonts {
    param(
        [string] $FontsDirectory
    )
    
    if (-not $FontsDirectory) {
        return
    }

    if (-not (Test-Path $FontsDirectory)){
        Write-Host "Fonts directory $FontsDirectory does not exist." -ForegroundColor Red
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
        }else{
            Write-Host "$FontFamily already installed" -ForegroundColor Green
        }
        
    }

}

function Set-Power-Configuration {
    param(       
        $DiskTimeoutAC ,
        $DiskTimeoutDC ,
        $HibernateTimeoutAC ,
        $HibernateTimeoutDC ,
        $StandbyTimeoutAC ,
        $StandbyTimeoutDC ,
        $MonitorTimeoutAC ,
        $MonitorTimeoutDC ,
        $LockscreenTimeoutAC ,
        $LockscreenTimeoutDC 
    )

    # AC: Alternating Current (Wall socket).
    # DC: Direct Current (Battery).

    # Set turn off disk timeout (in minutes / 0: never)
    if ($DiskTimeoutAC){
        powercfg -change "disk-timeout-ac" $DiskTimeoutAC;
        Write-Host "DiskTimeoutAC was set to $DiskTimeoutAC." -ForegroundColor Green;
    }
    
    if ($DiskTimeoutDC){
        powercfg -change "disk-timeout-dc" $DiskTimeoutDC;
        Write-Host "DiskTimeoutDC was set to $DiskTimeoutDC." -ForegroundColor Green;
    }

    # Set hibernate timeout (in minutes / 0: never)
    if ($HibernateTimeoutAC){
        powercfg -change "hibernate-timeout-ac" $HibernateTimeoutAC;
        Write-Host "HibernateTimeoutAC was set to $HibernateTimeoutAC." -ForegroundColor Green;
    }

    if ($HibernateTimeoutDC){
        powercfg -change "hibernate-timeout-dc" $HibernateTimeoutDC;
        Write-Host "HibernateTimeoutDC was set to $HibernateTimeoutDC." -ForegroundColor Green;
    }
    
    # Set sleep timeout (in minutes / 0: never)
    if ($StandbyTimeoutAC){
        powercfg -change "standby-timeout-ac" $StandbyTimeoutAC;
        Write-Host "StandbyTimeoutAC was set to $StandbyTimeoutAC." -ForegroundColor Green;
    }

    if ($StandbyTimeoutDC){
        powercfg -change "standby-timeout-dc" $StandbyTimeoutDC;
        Write-Host "StandbyTimeoutDC was set to $StandbyTimeoutDC." -ForegroundColor Green;
    }
    
    # Set turn off screen timeout (in minutes / 0: never)
    if ($MonitorTimeoutAC){
        powercfg -change "monitor-timeout-ac" $MonitorTimeoutAC;
        Write-Host "MonitorTimeoutAC was set to $MonitorTimeoutAC." -ForegroundColor Green;
    }

    if ($MonitorTimeoutDC){
        powercfg -change "monitor-timeout-dc" $MonitorTimeoutDC;
        Write-Host "MonitorTimeoutDC was set to $MonitorTimeoutDC." -ForegroundColor Green;
    }
   
    # Set turn off screen timeout on lock screen (in seconds / 0: never)
    if ($LockscreenTimeoutAC){
        powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $LockscreenTimeoutAC;
        Write-Host "LockscreenTimeoutAC was set to $LockscreenTimeoutAC." -ForegroundColor Green;
    }
    
    if ($LockscreenTimeoutDC){
        powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $LockscreenTimeoutDC;
        Write-Host "LockscreenTimeoutDC was set to $LockscreenTimeoutDC." -ForegroundColor Green;
    }
    
    powercfg /SETACTIVE SCHEME_CURRENT;
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
            Write-Host "Successfully set registry value '$RegValue' to '$Var'" -ForegroundColor Green
            Set-ItemProperty -Path $RegPath -Name $RegValue -Value $Var;
        }
    }
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


function Set-Windows-Timezone {
    param (
        [string] $Timezone = $null
    )

    if (-not $Timezone){
        return
    }

    Write-Host "Setting timezone to $Timezone."
    Set-TimeZone $Timezone
    Get-TimeZone
}

function Remove-Windows-Watermark{
    param(
        $RemoveWindowsWatermark = $false
    )

    if (-not $RemoveWindowsWatermark){
        return
    }
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\svsvc" -Name Start -Value 4 -Force;
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name VLActivationInterval -Value 0x0000a8c0 -Force;
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name NoActivationUX -Value 0x00000001 -Force;

    Write-Host "Setting HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\svsvc\Start value to 4." -ForegroundColor Yellow
    Write-Host "Setting HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\VLActivationInterval value to 0x0000a8c0." -ForegroundColor Yellow
    Write-Host "Setting HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\svsvc\NoActivationUX value to 0x00000001." -ForegroundColor Yellow

    Write-Host "Sucessfully removed windows watermark. Restart your machine to see changes." -ForegroundColor Green
}   