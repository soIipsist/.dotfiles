function Get-Default-Values-From-Json {
    param (
        [object]$WindowsData,
        [string]$DotfilesDirectory 
    )
    
    foreach ($key in $WindowsData.PSObject.Properties.Name) {
        $value = $WindowsData.$key
        
        # Check if value is a string, starts with $, and corresponds to an environment variable
        $envVarValue = Get-Environment-Variable $value
        
        if ($envVarValue) {
            $WindowsData.$key = $envVarValue
        }

    }
    
    return $WindowsData
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

    Write-Host "Setting environment variables..." -ForegroundColor Yellow

    foreach ($key in $EnvironmentVariables.Keys) {

        $pathString = $EnvironmentVariables[$key]

        if ($pathString -and $pathString -is [string]) {

            $pathString = $pathString -replace '/', '\'

            $parts = $pathString -split ';' |
                Where-Object { $_ -and $_.Trim() -ne '' }

            $seen = @{}
            $cleanParts = @()

            foreach ($p in $parts) {

                # remove trailing exe paths (bad PATH entries)
                if ($p -match '\.exe$') {
                    continue
                }

                if (-not $seen.ContainsKey($p.ToLower())) {
                    $seen[$p.ToLower()] = $true
                    $cleanParts += $p
                }
            }

            $pathString = ($cleanParts -join ';')

            Write-Host "Setting $key : $pathString" -ForegroundColor Green

            try {
                [System.Environment]::SetEnvironmentVariable(
                    $key,
                    $pathString,
                    [System.EnvironmentVariableTarget]::Machine
                )
            }
            catch {
                Write-Host "Error setting environment variable!" -ForegroundColor Red
            }

        } else {
            Write-Host "Invalid format for path string: $pathString."
        }
    }
}

function Get-Environment-Variable {
    param(
        [string]$value
    )

    $envFile =   Join-Path -Path $PSScriptRoot -ChildPath "/.env"

    if ($value -notmatch '^\$.*') {
        return
    }
    
    $value = $value.Substring(1)

    if (Test-Path $envFile) {
        $envValue = Get-Content $envFile | Where-Object { $_ -match "^$value=" } | ForEach-Object { ($_ -split '=', 2)[1] }

        if ($envValue -match ',') {
            $envArray = $envValue -split ','
            return $envArray
        }
        else {
            return $envValue
        }
    }else{
        Write-Host ".env file was not found."
    }
}


function Replace-Root {
    param (
        [string]$Value,
        [string]$RootPath
    )

    # Ensure the value starts with '/' before replacing
    if ($Value -match "^/") {
        $RootPath =  Join-Path -Path $RootPath -ChildPath "$Value"
        return "$RootPath"
    }

    if ($Value -match "^\\") {
        $RootPath =  Join-Path -Path $RootPath -ChildPath "$Value"
        return "$RootPath"
    }

    return $Value
}

