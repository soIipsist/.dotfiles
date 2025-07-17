# Scripts

## Python

### set_env.py - set environment variables

This script allows you to modify existing environment variables or add new ones. It automatically updates the appropriate dotfiles for your chosen shell (e.g., Bash, Zsh, etc.).

The `-a` or `--append` flag allows you to add a new value to an existing environment variable without overwriting its current contents. This is particularly useful for updating variables like PATH, where multiple values need to coexist.

```python
python set_env.py key=value, key2=value2 -s "bash" -a 1
```

You need to source files after for the changes to reflect:

```bash
source ~/.bashrc
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

### chrome_inspect.py

Returns html content of currently active Chrome tab.

``` python
python chrome_inspect.py
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

## Shell

### organize_files.sh

Automatically organizes files (such as photos or videos) into folders by their year of creation.

```shell
./organize_files.sh <source_directory> [destination_directory]
```
