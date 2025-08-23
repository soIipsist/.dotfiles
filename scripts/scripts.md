# Scripts

## Python

### set_env.py - set environment variables

This script allows you to modify existing environment variables or add new ones. It automatically updates the appropriate dotfiles for your chosen shell (e.g., Bash, Zsh, etc.).

#### Actions

- **Set**: Add or replace environment variables.  
- **Unset**: Remove environment variables (line replaced with a blank line to preserve structure).  
- **Append**: Add new values to an existing variable without overwriting (useful for `PATH`).  

#### Usage

```bash
python set_env.py KEY=VALUE, KEY2=VALUE2 -s SHELL -a ACTION

```

You need to source files after for the changes to reflect:

```bash
source ~/.bashrc
```

### downloader.py

`downloader.py` is a flexible, modular download manager for fetching content from various URLs using configurable "downloaders." Each downloader is defined using a JSON metadata file and can call a custom Python function to handle the download. The system supports tracking of downloads in a SQLite database, logging with color-coded output, and optional integration with tools like `yt-dlp`, `wget`, or `urllib`.

#### Features

- Pluggable downloader system (`yt-dlp`, `wget`, `urllib`, or custom)
- JSON-based metadata configuration per downloader
- SQLite database logging of downloads (status, timestamps, output path)
- Command-line interface for managing downloads and downloaders
- Batch downloads via input text files
- Environment-variable-driven configuration
- Color-coded logging to both file and console

#### Quick Start

Download a single YouTube video using `yt-dlp`:

```bash
python downloader.py -t ytdlp_video "https://youtu.be/OlEqHXRrcpc"
```

### ytdlp.py - download youtube videos

You can download YouTube videos or videos from other sites using yt-dlp. The process is simplified by including default audio and video options in `.json` format.

```python
python ytdlp.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --ytdlp_format="audio"
```

**_NOTE:_ In order for this to work, you need to set up [ytdlp](https://github.com/yt-dlp/yt-dlp/wiki/Installation) and [ffmpeg](https://ffmpeg.org/download.html)**

### bfg_cleaner.py - remove a file's commit history

Using [bfg repo cleaner](https://rtyley.github.io/bfg-repo-cleaner/), you can remove a file's commit history from a repository without a trace.

```python
usage: bfg_clean_file.py [-h] [-f FILE_PATH] [-b BFG_DIRECTORY] [-v BFG_VERSION] git_repository

positional arguments:
  git_repository                                   Git repository from which to erase file history.

options:
  -h, --help                                       show this help message and exit
  -f FILE_PATH, --file_path FILE_PATH              File path in git repository.
  -b BFG_DIRECTORY, --bfg_directory BFG_DIRECTORY  bfg.jar path. If not specified, base directory will be used by default.
  -v BFG_VERSION, --bfg_version BFG_VERSION        Downloads the specified version of bfg if the relevant bfg.jar file is not already present.
```

## Powershell

### Get-OEM-Key.ps1 - retrieve original OEM key

Echoes the original product key shipped with Windows.

```powershell
./Get-OEM-Key.ps1
```

### Get-Product-Key.ps1 - retrieve DigitalProductId from the registry

Echoes `DigitalProductId` from the registry.

```powershell
./Get-Product-Key.ps1
```
