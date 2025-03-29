function Install-VimPlug {
    Write-Host "Installing Vim Plug..." -ForegroundColor Yellow
    Invoke-WebRequest -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
}

$VimPackage = [PSCustomObject]@{
    Name   = 'vim'
    Params = @("/NoDesktopShortcuts", "/NoContextmenu" , "/InstallDir:${env:ProgramFiles}")
}
$Packages = @($VimPackage)

Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
refreshenv;

if ($UninstallPackages){
    $global:DestinationDirectory="$null"
    return
}

Install-VimPlug
vim +PlugInstall +qall;