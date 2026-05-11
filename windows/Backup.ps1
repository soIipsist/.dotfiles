function Start-WindowsBackup {
    param(
        [string]$BackupPath
    )

    if (-not ($BackupPath)){
        return
    }

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

    # Define source (Windows system drive)
    $source = "$env:SystemDrive\"

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $destination = Join-Path $BackupPath "WindowsBackup_$timestamp"

    New-Item -ItemType Directory -Path $destination -Force | Out-Null

    Write-Host "Starting backup from $source to $destination"

    # Use Robocopy for reliability
    $logFile = Join-Path $destination "backup_log.txt"

    $args = @(
        $source,
        $destination,
        "/MIR",
        "/Z",
        "/R:3",
        "/W:5",
        "/XJ",
        "/COPY:DAT",
        "/DCOPY:T",
        "/TEE",
        "/LOG:$logFile"
    )

    # Start Robocopy process
    $process = Start-Process robocopy -ArgumentList $args -NoNewWindow -PassThru

    # Display indeterminate progress while Robocopy runs
    while (-not $process.HasExited) {
        Write-Progress -Activity "Backing up Windows files" -Status "Copying files..." -PercentComplete 50
        Start-Sleep -Seconds 1
    }

    Write-Progress -Activity "Backing up Windows files" -Completed

    $exitCode = $LASTEXITCODE

    if ($exitCode -le 7) {
        Write-Host "Backup completed successfully with exit code $exitCode"
    } else {
        Write-Warning "Backup completed with errors. Exit code: $exitCode (see log: $logFile)"
    }

    return $destination
}
