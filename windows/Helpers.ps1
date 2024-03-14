function Test-PathRegistryKey {
    [CmdletBinding()]
    param (
        [Parameter( Position = 0, Mandatory = $TRUE)]
        [String]
        $Path,

        [Parameter( Position = 1, Mandatory = $TRUE)]
        [String]
        $Name
    )

    try {
        Get-ItemPropertyValue -Path $Path -Name $Name;
        Return $TRUE;
    }
    catch {
        Return $FALSE;
    }
}

function Get-Workspace-Disk {
    $ValidDisks = Get-PSDrive -PSProvider "FileSystem" | Select-Object -ExpandProperty "Root";
    do {
        Write-Host "Choose the location of your development workspace:" -ForegroundColor Green;
        Write-Host $ValidDisks -ForegroundColor Green;
        $WorkspaceDisk = Read-Host -Prompt "Please choose one of the available disks";
    }while (-not ($ValidDisks -Contains $WorkspaceDisk));

    Return $WorkspaceDisk
}

 

function Get-All-Files-In-Paths {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [array]
        $Paths,

       
        $Filter = "$null",

        [bool]
        $Recurse = $false,

        [bool]
        $File = $true,

        [bool]
        $Directory = $false
    )

    $itemsList = @()

    $flags = @()
    

    if ($Filter) {
        $flags += "-Filter"
        $flags += $Filter
    }

    if ($Recurse) {
        $flags += '-Recurse'
    }

    if ($File) {
        $flags += '-File'
    }

    if ($Directory) {
        $flags += '-Directory'
    }


    $flags += '-ErrorAction SilentlyContinue'

    foreach ($Path in $Paths) {
        $expression = "Get-ChildItem -Path $Path $flags"
        $items = Invoke-Expression $expression
        $itemsList += $items
    }
 
  
    return $itemsList
}




