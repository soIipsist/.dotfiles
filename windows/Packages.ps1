function Install-Packages {
    param (
        [array]
        $Packages = @(),

        [string]
        $PackageProvider = "chocolatey",

        [array] 
        $Params = @(),

        $UninstallPackages = $null

    )

    if ($null -eq $UninstallPackages) {
        $UninstallPackages = $false
    }

    $Action = if ($UninstallPackages) { "uninstall" } else { "install" }

    foreach ($Package in $Packages) {
        $Command = ""
        $PackageParams = @()

    
        # if package is in dictionary format, grab params
        if ($Package.GetType().Name -eq "PSCustomObject") {
            $PackageParams = $Package.params
            $Package = $Package.name 
        }
        
        # check package provider
        switch ($PackageProvider) {
            { $_ -in "choco", "chocolatey" } { 
                $Action = if ($UninstallPackages) { "uninstall" } else { "upgrade" } 
                $Command = "choco $Action -y $Package" 
            }
            { $_ -in "wsl", "apt" } { 
                $Action = if ($UninstallPackages) { "remove" } else { "install" } 
                $Command = "wsl sudo apt --yes --no-install-recommends $Action $Package" 
            }
            "winget" { $Command = "winget $Action $Package" }
            "scoop" { $Command = "scoop $Action $Package" }
            "pip" { $Command = "python -m pip $Action $Package" }
            "windows" {
                if ($UninstallPackages) {
                    Uninstall-AppPackage $Package
                }
                else {
                    Install-AppPackage $Package
                }
                continue

            }
            Default { 
                Write-Host "Invalid package provider: $PackageProvider" -ForegroundColor Green
                return
            }
        }

        if ($Params) {
            $PackageParams = $Params
        }
        
        if ($PackageParams) {
            $ParamsCommand = Get-Params-Command -PackageProvider $PackageProvider -Params $PackageParams
            $Command += "$ParamsCommand"
        }
    
        if ($Command) {
            try {
                Invoke-Expression $Command
            }
            catch {
                Write-Host "Error installing $Package." -ForegroundColor Red
            }
            
        }
    
    }
}

function Get-Params-Command {
    param(
        [string]
        $PackageProvider = "chocolatey",

        [array] 
        $Params = @()
    )
    $Command = ""

    $ParamsCommand = ""
    $Wrap = $false

    switch ($PackageProvider) {
        { $_ -in "choco", "chocolatey" } { 
            $Command += " --params"
            $Wrap = $true
        }
        
        Default { 
        
        }
    }
    $ParamsCommand = $Params -join " "

    if ($Wrap) {
        $Command += " '$ParamsCommand'"
    }
    else {
        $Command += " $ParamsCommand"
    }     

    return $Command

}


function Uninstall-AppPackage {
    param (
        [string]$Package
    )

    try {
        Get-AppxPackage $Package -AllUsers | Remove-AppxPackage;
        Get-AppXProvisionedPackage -Online | Where-Object DisplayName -like $Package | Remove-AppxProvisionedPackage -Online;    
        Write-Host "Application uninstalled successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Could not uninstall application package." -ForegroundColor Red
    } 
}

function Install-AppPackage {
    param (
        [string]$PackagePath
    )
    try {
        Add-AppxPackage -Path $PackagePath -ErrorAction Stop
        Write-Host "Application package installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Could not install application package." -ForegroundColor Red
        Write-Host $_.Exception.Message
    } 
}

