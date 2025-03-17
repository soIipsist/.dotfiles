
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
    # Check if Git is installed
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "git was not found on your system, please install and try again." -ForegroundColor Red
        return
    }
    
    # Check if Scoop is already installed
    if (-not(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Scoop is not installed. Installing Scoop in non-elevated PowerShell..." -ForegroundColor Green
        try {
            # Start a new non-elevated PowerShell process to install Scoop
            $script = {
                # Install Scoop in the current user profile (non-elevated)
                Invoke-Expression $(Invoke-RestMethod 'https://get.scoop.sh')
                Write-Host "Scoop installation command was issued successfully." -ForegroundColor Green
                 
                $buckets = @('main', 'extras', 'versions', 'nirsoft', 'sysinternals', 'php', 'nerd-fonts', 'nonportable', 'java', 'games')

                foreach ($bucket in $buckets) {
                    if (-not (scoop bucket list | Select-String -Pattern $bucket)) {
                        Write-Host "Adding $bucket bucket..." -ForegroundColor Green
                        scoop bucket add $bucket
                    } else {
                        Write-Host "$bucket bucket is already added." -ForegroundColor Green
                    }
                }
            }

            # Convert the script block to a string to be passed as an argument
            $scriptString = $script.ToString()

            $apppath = "powershell.exe"
            $taskname = "Launch Scoop Installation"

            # Check if the task already exists and delete it to avoid duplication
            if (Get-ScheduledTask -TaskName $taskname -ErrorAction SilentlyContinue) {
                Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
            }

            # Create the scheduled task action with the script to execute
            $action = New-ScheduledTaskAction -Execute $apppath -Argument "-NoProfile -NoExit -ExecutionPolicy Bypass -Command $scriptString"
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname | Out-Null
            Start-ScheduledTask -TaskName $taskname
            Start-Sleep -s 1
            Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
            Install-Scoop-Buckets

        } catch {
            Write-Host "An error occurred while installing Scoop. Ensure you have permission to install software." -ForegroundColor Red
            return
        }
    } else {
        Write-Host "Scoop is already installed." -ForegroundColor Green
    }

    Write-Host "Scoop and buckets were successfully installed and configured." -ForegroundColor Green
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