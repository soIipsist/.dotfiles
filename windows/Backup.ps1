function Start-WindowsBackup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BackupPath
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
    winget export -o $wingetExport --accept-source-agreements | Out-Null

    # Folders to back up
    $folders = @(
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\.ssh",
        "$env:USERPROFILE\.gitconfig",
        "$env:APPDATA\Code",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"
    )

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

 