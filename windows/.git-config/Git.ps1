
. "../windows/Dotfiles.ps1"

function GitConfig {
    param(
        [string] $GitUserEmail,

        [string] $GitUserName
    )
    git config --global init.defaultBranch "main";
    
    if ($GitUserName) {
        Write-Host "Default username was set to: $GitUserName" -ForegroundColor Green
        git config --global user.name $GitUserName;
    }
 
    if ($GitUserEmail) {
        Write-Host "Default email was set to: $GitUserEmail" -ForegroundColor Green
        git config --global user.email $GitUserEmail;
    }
    
}

$GitPackage = [PSCustomObject]@{
    name   = "git"
    params = @("/NoAutoCrlf", "/WindowsTerminal", "/NoShellIntegration", "/SChannel")
}

$Packages = @($GitPackage, "github-desktop", "gh")

$Dotfiles = Get-Dotfiles $PSScriptRoot

Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
refreshenv;
GitConfig -GitUserEmail $GitUserEmail -GitUserName $GitUserName
Write-Host "Git was successfully configured." -ForegroundColor Green;
$DestinationDirectory="$env:USERPROFILE\temp"