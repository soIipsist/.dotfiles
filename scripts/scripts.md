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
python downloader.py -t ytdlp_audio "https://youtu.be/OlEqHXRrcpc" # downloads the video in mp3 format
```

Download an image using `wget`:

```bash
python downloader.py -t wget "some_image_url" -f "filename.jpg" -o ~/Desktop
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

### sqlite.py - perform sqlite operations

A lightweight Python script to perform basic SQLite operations (select, insert, delete) with convenience functions for sanitization, validation, and mapping results to objects.  
It can be used both as a standalone CLI tool or imported as a utility module.

```bash
python sqlite.py --database_path mydb.sqlite --table_name downloads --action select
```

### organize_files.py - organize files

A Python utility for organizing files into structured folders based on **year**, **patterns**, or **custom rules**.  
It supports moving or copying files, automatic backups, and customizable renaming via regex patterns.

#### Organize methods

- 📂 **Organize by year**  
  - Extracts the year from EXIF metadata (for photos) or file modification date.  
  - Files are grouped into subfolders by year.  

- **Organize episodes**  
  - Detects episode numbers or `SxxExx` patterns in filenames.  
  - Renames files to clean episode-style names (e.g., `Episode 001.mp4` → `001.mp4`, `Game of Thrones S01E01.mkv` → `S01E01.mkv`).  

- **Add prefix or suffix**  
  - Adds a prefix to audio tracks (e.g., `Track 01.mp3` → `AlbumName - Track 01.mp3`).  
  - Prompts for a prefix if none is provided.  

- **Custom patterns**  
  - Provide your own regex `pattern` and `replacement` to rename files however you like.  

```bash

python organize_files.py /path/to/source /path/to/destination --action year
python organize_files.py /path/to/shows /path/to/episodes --action episodes
python organize_files.py /path/to/music /path/to/albums --action prefix --move
python organize_files.py /path/to/downloads /path/to/sorted \
    --action pattern --pattern "^(.*)$" --repl "prefix - \\1"
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
