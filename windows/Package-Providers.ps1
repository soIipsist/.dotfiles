
function Install-Winget {

    if (-not(Get-Command -Name winget -ErrorAction SilentlyContinue)) {
        Write-Host "Installing WinGet as package provider:" -ForegroundColor Green;
        Install-PackageProvider WinGet -Force;
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    }

    Write-Host "Winget was successfully installed." -ForegroundColor Yellow
}

function Install-Nuget {
    if (-not (Get-PackageProvider-Installation-Status -PackageProviderName "NuGet")) {
        Write-Host "Installing NuGet as package provider:" -ForegroundColor Green;
        Install-PackageProvider -Name "NuGet" -Force;
    }
    Write-Host "Nuget was successfully installed." -ForegroundColor Yellow
}

function  Install-Chocolatey {
    Write-Host "Installing Chocolatey:" -ForegroundColor Green;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"));
    Write-Host "Configuring Chocolatey:" -ForegroundColor Green;
    choco feature enable -n=useRememberedArgumentsForUpgrades;
    Write-Host "Loading Chocolatey helpers:" -ForegroundColor Green;
    $ChocolateyProfile = Join-Path -Path $env:ChocolateyInstall -ChildPath "helpers" | Join-Path -ChildPath "chocolateyProfile.psm1";

    if (Test-Path($ChocolateyProfile)) {
        Import-Module $ChocolateyProfile;
    };

    Write-Host "Chocolatey was successfully installed." -ForegroundColor Yellow
    refreshenv;
    
}

function Install-Scoop {

    if (-not(Get-Command scoop -ErrorAction SilentlyContinue)) {
        
        Write-Host "Installing Scoop as package provider:" -ForegroundColor Green
        Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    }


    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $GitPath = Join-Path -Path $PSScriptRoot -ChildPath "/.git-config/Git.ps1"
        Invoke-Expression "& $GitPath"
    }
    # add more buckets here
    scoop bucket add main
    scoop bucket add extras
    scoop bucket add versions
    scoop bucket add nirsoft
    scoop bucket add sysinternals
    scoop bucket add php
    scoop bucket add nerd-fonts
    scoop bucket add nonportable
    scoop bucket add java
    scoop bucket add games

    Write-Host "Scoop was successfully installed." -ForegroundColor Yellow
}


function Install-Provider {
    param(
        [string] $PackageProviderName
    )


    switch ($PackageProviderName) {
        "chocolatey" { Install-Chocolatey }
        "choco" { Install-Chocolatey }
        "winget" { Install-Winget }
        "scoop" { Install-Scoop }
        "nuget" { Install-Nuget }
        Default { "Invalid package provider name: $PackageProviderName" }
    }

}

function Install-PackageProviders {
    param(
        $PackageProviders = @()
    )
    if ($null -eq $PackageProviders) {
        $PackageProviders = 'all'
    }

    if ($PackageProviders -eq 'all') {
        $PackageProviders = @('chocolatey', 'winget', 'scoop', 'nuget') 
    }
    Write-Host "$PackageProviders"
    foreach ($Provider in $PackageProviders) {
        Install-Provider -PackageProviderName $Provider
    }

}


function Get-PackageProvider-Installation-Status {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $TRUE)]
        [string]
        $PackageProviderName
    )

    try {
        Get-PackageProvider -Name $PackageProviderName;
        return $TRUE;
    }
    catch [Exception] {
        return $FALSE;
    }
}