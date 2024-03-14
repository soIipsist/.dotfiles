# Include files
. "..\windows\Helpers.ps1"
. "..\windows\Registry.ps1"
. "..\windows\Dotfiles.ps1"
. "..\windows\Variables.ps1"
. "..\windows\Windows-Setup.ps1"

. "..\windows\Package-Providers.ps1"
. "..\windows\Packages.ps1"

# Register-VBox-VM
# Remove-VBox-VM


function Get-System-Dotfiles {
    param (
        [string]
        $Path = "~"
    )
    # $Keywords = @(".git", ".gitconfig", ".bash", ".bashrc", ".vimrc", ".zshrc")
    $Keywords = @(".gitconfig")


    $SystemDotfiles = Get-ChildItem -Path $Path -Recurse | Where-Object { $_.Name -in $Keywords }
    return $SystemDotfiles

}

# $SystemDotfiles = Get-System-Dotfiles

# foreach($Dotfile in $SystemDotfiles){
#     Write-Host $Dotfile.FullName
# }
# Move-Dotfiles -Dotfiles $SystemDotfiles -DestinationDirectory $PSScriptRoot

# if($TimeZone){
#     Set-TimeZone -Id $TimeZone
# }else{
#     Write-Host 'ggg'
# }
# Install-Fonts -FontsDirectory $FontsDirectory

# Set-Classic-ContextMenu -ClassicContextMenu $ClassicContextMenu
# Install-Dotfiles $Dotfiles
# Set-Lockscreen -LockscreenPath $LockscreenPath
# Reboot -Reboot $Reboot -RebootTime $RebootTime

