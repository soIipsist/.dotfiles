
. "../windows/Dotfiles.ps1"

function Remove-VBox-VM {
    param(
        [string]
        $MachineName = "Windows"
    )
    
    vboxmanage unregistervm $MachineName --delete

}


function Register-VBox-VM {

    param(
        [string]
        $MachineName = "Windows",
        
        [string]
        $ISOPath = "D:\Win11_22H2_English_x64v2.iso",

        [int]
        $Memory = 2048,

        [int]
        $VRAM = 128,

        [string]
        $GraphicsController = 'vboxvga'
    )
    
    vboxmanage createvm --name $MachineName --ostype "Windows11_64" --register

    vboxmanage modifyvm $MachineName --memory $Memory --vram $VRAM
    vboxmanage modifyvm $MachineName --nic1 nat
    
    vboxmanage storagectl $MachineName --name "SATA Controller" --add sata --controller IntelAhci
    vboxmanage storageattach $MachineName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $ISOPath

    vboxmanage modifyvm $MachineName --graphicscontroller $GraphicsController
    
}


function Test-VM {
    param(
        [string]
        $MachineName = "Windows",
        
        [string]
        $Type = "gui"
    )

    vboxmanage startvm $MachineName --type $Type  
}

$Packages = @("virtualbox")
Install-Packages -Packages $Packages -UninstallPackages $UninstallPackages
