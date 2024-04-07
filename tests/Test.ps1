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
Install-Dotfiles $Dotfiles
# Set-Lockscreen -LockscreenPath $LockscreenPath
# Reboot -Reboot $Reboot -RebootTime $RebootTime


# $TaskName = "WSLConfigOnRestart"
# $ScriptPath = "D:\soIipsis\dotfiles\tests\WSLRestart.ps1" 

# Unregister-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
# $PSPath = (Get-Command powershell.exe).Definition
# $FunctionName = "SampleFunction"
# $Action = New-ScheduledTaskAction -Execute $PSPath -Argument "-NonInteractive -NoProfile -NoLogo -NoProfile -NoExit -Command `"& { Import-Module PSWorkflow ; . '$ScriptPath'; $FunctionName }`""
# $Option = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -WakeToRun
# $Trigger = New-JobTrigger -AtLogOn -RandomDelay (New-TimeSpan -Seconds 10)
# Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Option -RunLevel Highest
Reboot -Reboot $true