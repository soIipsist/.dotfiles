function Get-Registry-Key-Values {
    param (
        [string] $Path
    )

    $registryItems = Get-ItemProperty -Path $Path
    return $registryItems
}


function Get-Registry-Keys-From-Path {
    param (
        [string] $Path)


    $registryKeys = Get-ChildItem -Path $Path
    return $registryKeys
}



function Add-Registry-Value {
    param (
        [string] $path,
        [psobject] $Value
    )

    $valueName = $value.name
    $valueData = $value.data
    $valueType = $value.type

    Write-Host "$path\$valueName"
    $valueExists = (Get-Item $path -EA Ignore).Property -contains $valueName

    if ($valueExists) {
        Set-ItemProperty -Path $path -Name $valueName -Value $valueData
        Write-Host "Registry value '$valueName' updated with new data in '$path'."
    }
    else {
        New-ItemProperty -Path $path -Name $valueName -Value $valueData -PropertyType $valueType
        Write-Host "Registry value '$valueName' added to '$path'."
    }
    

}