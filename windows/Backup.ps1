function Start-WindowsBackup {
    param(
        [string]$BackupPath,

        [string]$OS = "Ubuntu",

        [string]$OS_User = $env:USERNAME,

        [array]$BackupFolders = @()
    )

    # Validate backup path
    if (-not (Test-Path -Path $BackupPath)) {
        try {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            Write-Host "Created backup directory: $BackupPath"
        } catch {
            Write-Warning "Backup path is invalid and could not be created: $BackupPath"
            return
        }
    }

    if (-not (Test-Path -Path $BackupPath)) {
        Write-Warning "Backup path does not exist or is not accessible: $BackupPath"
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $destination = Join-Path $BackupPath "UserBackup_$timestamp"

    New-Item -ItemType Directory -Path $destination -Force | Out-Null

    # Export installed applications list
    $wingetExport = Join-Path $destination "apps.json"

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget export -o $wingetExport --accept-source-agreements | Out-Null
        Write-Host "Exported installed applications."
    } else {
        Write-Warning "winget not found. Skipping app export."
    }

    $DefaultFolders = @(       

        # Common user folders
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\scoop",

        # SSH / Git
        "$env:USERPROFILE\.ssh",
        "$env:USERPROFILE\.gpg",
        "$env:USERPROFILE\.gitconfig",

        # VSCode
        "$env:APPDATA\Code",

        # Windows Terminal
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe",

        # Program Files
        "$env:ProgramFiles",

        # Program Files x86
        "${env:ProgramFiles(x86)}",

        # WSL distributions
        "$env:LOCALAPPDATA\Packages"
    )

    if ($OS_User) {
        $wslSsh = "\\wsl$\$OS\$OS_User\.ssh"
        $wslGpg = "\\wsl$\$OS\$OS_User\.gnupg"

        if (Test-Path $wslSsh) { $DefaultFolders += $wslSsh }
        if (Test-Path $wslGpg) { $DefaultFolders += $wslGpg }
    }

   
    $folders = if ($BackupFolders.Count -gt 0) {
        $BackupFolders
    } else {
        $DefaultFolders
    }

    Write-Host "Using folders: $folders"

    $total = $folders.Count
    $current = 0

    foreach ($folder in $folders) {
        $current++

        if (-not (Test-Path $folder)) {
            continue
        }

        $name = Split-Path $folder -Leaf
        $target = Join-Path $destination $name

        Write-Progress -Activity "Backing up user files" `
            -Status "Copying $name" `
            -PercentComplete (($current / $total) * 100)

        if ((Get-Item $folder) -is [System.IO.DirectoryInfo]) {
            robocopy $folder $target /E /Z /R:3 /W:5 /XJ /COPY:DAT /DCOPY:T | Out-Null
        } else {
            Copy-Item $folder $target -Force
        }
    }

    Write-Progress -Activity "Backing up user files" -Completed

    Write-Host "Backup completed: $destination"

    return $destination
}

 