. "..\windows\Helpers.ps1"


function Get-Dotfile-Directories {
    param(
        [array]$Dotfiles = "all"
    )

    if ($null -eq $Dotfiles) {
        $Dotfiles = "all"
    }

    $LocationPath = Join-Path -Path (Split-Path -Path (Get-Location)) -ChildPath "\windows"
    $FolderPaths = Get-All-Files-In-Paths $LocationPath -Filter ".*" -Directory $true -File $false
    $DotfileFolderPaths = @()
    
    
    if ($Dotfiles -eq 'all') {
        $DotfileFolderPaths = $FolderPaths | ForEach-Object { $_.FullName }
    }
    else {
        foreach ($Path in $FolderPaths) {
            if ($Path.Name -in $Dotfiles) {
                $DotfileFolderPaths += $Path.FullName
            }
        }
    }

    return $DotfileFolderPaths
}


function Get-Dotfile-Scripts {
    param (
        [string] $DotfileFolderPath
    )
    $DotfileScripts = Get-All-Files-In-Paths $DotfileFolderPath -File $true -Directory $false -Filter "*.ps1"
    return  $DotfileScripts
}


function Get-Dotfiles {
    param (
        [string] $DotfileFolderPath
    )

    $Dotfiles = Get-All-Files-In-Paths $DotfileFolderPath -File $true -Directory $false  | Where-Object { $_.FullName -notlike "*.ps1" }    
    return   $Dotfiles

}


function Install-Dotfiles {
    param(
        [array]$Dotfiles = "all"
    )
    $DotfileDirectories = Get-Dotfile-Directories -Dotfiles $Dotfiles

    Write-Host "Executing dotfile scripts..." -ForegroundColor Yellow
    foreach ($Directory in $DotfileDirectories) {

        $Scripts = Get-Dotfile-Scripts $Directory
    
        foreach ($Script in $Scripts) {
            $ScriptName = $Script.FullName
            Invoke-Expression "& $ScriptName"
        }
    }


}

function Move-Dotfiles {
    param(
        [array]
        $Dotfiles,

        [string]
        $DestinationDirectory = $UserProfilePath
    )
    
    if ( -not (Test-Path -Path $DestinationDirectory)) {
        Write-Host "Destination path '$DestinationDirectory' does not exist."
        
        Write-Host "Would you like to copy the item anyway? (y/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -ne 'y') {
            return
        }

    }



    foreach ($Dotfile in $Dotfiles) {
        if ($Dotfile.GetType().Name -eq "FileInfo") {
            $Dotfile = $Dotfile.FullName
        } 

      
        if (Test-Path -Path $Dotfile) {
            Copy-Item -Path $Dotfile -Destination $DestinationDirectory
            Write-Host "Copied $Dotfile to $DestinationDirectory" -ForegroundColor DarkBlue
        }
    }

    

}