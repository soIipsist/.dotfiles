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

```powershell
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
