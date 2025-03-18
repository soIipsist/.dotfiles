
function Get-Dotfile-Directories {
    param(
        [array]$Dotfiles = @()
    )

    $FolderPaths = Get-All-Files-In-Paths $PSScriptRoot -Filter ".*" -Directory $true -File $false
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
        [array]$Dotfiles = @(),

        [array] $ExcludedScripts = @("WSLRestart.ps1"),

        [string] $DotfilesDirectory = [System.Environment]::GetFolderPath('UserProfile')
    )

    if (-not ($Dotfiles)){
        return
    }

    if (-not $DotfilesDirectory){
        $DotfilesDirectory=[System.Environment]::GetFolderPath('UserProfile')
    }

    $DotfileDirectories = Get-Dotfile-Directories -Dotfiles $Dotfiles
    $global:DestinationDirectory = $DotfilesDirectory

    foreach ($Directory in $DotfileDirectories) {

        # reset destination directory
        $global:DestinationDirectory = $DotfilesDirectory
        $Scripts = Get-Dotfile-Scripts $Directory

        # execute dotfile scripts
        foreach ($Script in $Scripts) {
            $ScriptName = $Script.FullName

            if ($Script.Name -in $ExcludedScripts) {
                Write-Host "Script was excluded: '$ScriptName'"
            }
            else {
                Write-Host "Executing $ScriptName..." -ForegroundColor Yellow
                Invoke-Expression "& $ScriptName"
            }
        }

        $Dotfiles = Get-Dotfiles $Directory
        Move-Dotfiles -Dotfiles $Dotfiles -DestinationDirectory  $global:DestinationDirectory # if dest is null or empty, it doesn't move the files
        $global:DestinationDirectory = $null
    }

}

function Move-Dotfiles {
    param(
        [array]
        $Dotfiles,

        [string]
        $DestinationDirectory
 
    )

    if ($DestinationDirectory -eq "$null"){
        return
    }

    if ( -not (Test-Path -Path $DestinationDirectory)) {
        Write-Host "Destination path '$DestinationDirectory' does not exist."
        
        Write-Host "Would you like to copy the item anyway? (y/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -ne 'y') {
            return
        }
        New-Item -Path $DestinationDirectory -ItemType "directory"
    }

    foreach ($Dotfile in $Dotfiles) {
        if ($Dotfile.GetType().Name -eq "FileInfo") {
            $Dotfile = $Dotfile.FullName
        }

        if (Test-Path -Path $Dotfile) {
            # Get just the file name (without path)
            $fileName = [System.IO.Path]::GetFileName($Dotfile)
            $destinationPath = Join-Path -Path $DestinationDirectory -ChildPath $fileName

            Copy-Item -Path $Dotfile -Destination $destinationPath
            Write-Host "Copied $Dotfile to $destinationPath" -ForegroundColor DarkBlue
        }
    }
}
