# dotfiles

A collection of setup configuration files, tools and scripts aimed at enhancing productivity. Users can tailor their installation preferences specific to their selected operating system.

## Configuration files

For each listed operating system, there is a dedicated subdirectory that contains all the necessary files for default configuration. Each subdirectory contains a setup script, a configuration file (named after the chosen OS with the `.json` extension), and dotfiles. Dotfile directories contain specialized scripts that are executed to facilitate customization. To begin configuration, simply execute the corresponding setup script as specified in the guide below.

## Setup

Follow these steps to configure your environment:

1. Navigate to the appropriate operating system directory (`windows`, `mac`, or `linux`) and locate the configuration file specific to your OS (with a `.json` extension).

2. Open the configuration file for your operating system and adjust the configurations as needed. Refer to this [guide](https://github.com/soIipsis/dotfiles/blob/main/valid_parameters.md) for a comprehensive list of valid parameters.

3. Execute the provided setup script in the terminal or command prompt with administrator privileges:

**Windows (Powershell)**:

```
./Setup.ps1
```

**Linux**:

```bash
./setup.sh
```

**macOS**:

```bash
./setup.sh
```

## Scripts

### yt-dlp

You can download YouTube videos or videos from other sites using yt-dlp. The process is simplified by including default audio and video options in `.json` format.

```python
python ytdlp.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --format="audio"
```

### BFG repository cleaner - Remove file commit history

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
