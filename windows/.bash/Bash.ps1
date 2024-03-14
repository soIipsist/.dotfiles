. "../windows/Dotfiles.ps1"


$Dotfiles = Get-Dotfiles $PSScriptRoot
$DestinationDirectory = $UserProfilePath
Move-Dotfiles -Dotfiles $Dotfiles -DestinationDirectory $DestinationDirectory
