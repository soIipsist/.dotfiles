# Include files

$ParentDirectory = $PSScriptRoot
$HelpersPath = Join-Path -Path $ParentDirectory -ChildPath "Helpers.ps1"
$RegistryPath = Join-Path -Path $ParentDirectory -ChildPath "Registry.ps1"
$DotfilesPath = Join-Path -Path $ParentDirectory -ChildPath "Dotfiles.ps1"
$VariablesPath = Join-Path -Path $ParentDirectory -ChildPath "Variables.ps1"
$SetupPath = Join-Path -Path $ParentDirectory -ChildPath "Windows-Setup.ps1"
$ProvidersPath = Join-Path -Path $ParentDirectory -ChildPath "Package-Providers.ps1"
$PackagesPath = Join-Path -Path $ParentDirectory -ChildPath "Packages.ps1"

. $HelpersPath
. $RegistryPath
. $DotfilesPath
. $VariablesPath
. $SetupPath
. $ProvidersPath
. $PackagesPath
 
if ($args.Count -gt 0){
    $Dotfiles = $args
}

Install-Dotfiles $Dotfiles