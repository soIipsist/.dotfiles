function Install-VimPlug {
    
    Invoke-WebRequest -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
        New-Item $HOME/vimfiles/autoload/plug.vim -Force
}

function VimConfig {
    # move vim plug file to vim autoload
    New-Item -Path "~\.vim"
    Copy-Item -Path ~/vimfiles -Destination ~\.vim -Recurse

    vim +PlugInstall +qall;
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
VimConfig