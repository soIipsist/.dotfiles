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
        return "$RootPath$Value"
    }

    return $Value
}

