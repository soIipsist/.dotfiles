. "..\windows\Dotfiles.ps1"
. "..\windows\Helpers.ps1"
function Install-SDK-Platform-Tools {
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -Method Get -OutFile "platform-tools.zip"
    Move-Item -Path "platform-tools.zip" -Destination "$env:ProgramFiles/Android/"
    Expand-Archive -Path "$env:ProgramFiles/Android/platform-tools.zip" -DestinationPath "$env:ProgramFiles/Android/platform-tools"
    Remove-Item -Path "$env:ProgramFiles/Android/platform-tools.zip"
}

function Import-Android-Studio-Settings {
    # Get folder path for android studio
    Write-Host "Copying Android Studio default settings..." -ForegroundColor Yellow

    $FolderPath = Get-All-Files-In-Paths -Paths @("$env:AppData/Google") -File $false -Filter "Android*"
    $FolderPath = $FolderPath.FullName
    $Items = Get-All-Files-In-Paths -Paths @("$PSScriptRoot/settings") -File $false -Directory $true

    foreach ($Item in $Items) {
        Copy-Item -Path $Item.FullName -Destination $FolderPath -Force -Recurse
    } 
}

Install-Packages -Packages "Google.AndroidStudio" -UninstallPackages $UninstallPackages -PackageProvider "winget"
Install-Packages -Packages "openjdk" -UninstallPackages $UninstallPackages
Install-SDK-Platform-Tools
Import-Android-Studio-Settings