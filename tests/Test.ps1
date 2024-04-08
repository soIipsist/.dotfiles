# Include files
$ParentDirectory = Split-Path -Path $PSScriptRoot -Parent
$DotfilesDirectory = Join-Path -Path $ParentDirectory -ChildPath "windows/Dotfiles"
$PackagesDirectory = Join-Path -Path $ParentDirectory -ChildPath "windows/Packages"
$HelpersDirectory = Join-Path -Path $ParentDirectory -ChildPath "windows/Helpers"
$SetupDirectory = Join-Path -Path $ParentDirectory -ChildPath "windows/Windows-Setup"

. $DotfilesDirectory
. $PackagesDirectory
. $HelpersDirectory
. $SetupDirectory

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

function FunctionName {
    Write-Host "hello"
    
}



$TaskName = "FunctionName"
$ScriptPath = "D:\soIipsis\dotfiles\tests\Test.ps1" 

Set-ScheduledTask -TaskName $TaskName -ScriptPath $ScriptPath -DelayInSeconds 10
# Reboot -Reboot $true