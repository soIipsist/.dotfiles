function Install-Extensions {

    $extensionsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "extensions.json"

    if (Test-Path -Path $extensionsFilePath) {
        $extensions = (Get-Content -Path $extensionsFilePath -Raw | ConvertFrom-Json).recommendations
        foreach ($extension in $extensions) {
            # Write-Host $extension
            code --install-extension "$extension"
        }        
    }
}

$VSCodePackage = [PSCustomObject]@{
    Name   = 'vscode'
    Params = @("/NoDesktopIcon", "/NoQuicklaunchIcon", "/NoContextMenuFiles", "/NoContextMenuFolders")
}

$Packages = @($VSCodePackage)

$DestinationDirectory = Join-Path -Path $env:APPDATA -ChildPath "Code" | Join-Path -ChildPath "User";

Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
refreshenv;
Install-Extensions
Write-Host "VSCode was successfully configured." -ForegroundColor Green;