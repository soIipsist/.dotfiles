plugins=(
    zsh-autosuggestions
)
source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# PATH variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/platform-tools/:$PATH"

# YTDLP options
export YTDLP_PATH="$HOME/ytdlp/yt-dlp_macos"
export YTDLP_VIDEO_DIRECTORY="$HOME/Desktop/videos"
export YTDLP_AUDIO_DIRECTORY="$HOME/Desktop/music"
export YTDLP_AUDIO_EXT="mp3"
export YTDLP_VIDEO_EXT="mp4"
export YTDLP_VIDEO_SOUND_EXT="m4a"
export YTDLP_FORMAT="audio"
export YTDLP_EXTRACT_INFO="1"
export FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"

# useful paths
export DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
export GIT_HOME="$HOME/repos/soIipsist"

# VSCode variables
export VSCODE_WORKSPACE_DIRECTORY="$GIT_HOME/vscode-workspaces/.workspaces"
export VSCODE_PROJECT_DIRECTORY="$GIT_HOME"

# aliases
alias python="python3"
alias ytdlp="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py"
alias ytdlp_mp3="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f audio -a mp3"
alias ytdlp_mp4="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f video -v mp4"
alias yabais="yabai --start-service"
alias yabaik="yabai --stop-service"
alias skhds="skhd --start-service"
alias skhdk="skhd --stop-service"
alias vlc="/Applications/VLC.app/Contents/MacOS/VLC"
alias ios_backup="python3 $GIT_HOME/ios-backup-extractor/extract.py"
alias adb_transfer="python3 $GIT_HOME/adb-wrapper/examples/transfer.py"
alias adb_root="python3 $GIT_HOME/adb-wrapper/examples/root.py"
alias vscode="python3 $GIT_HOME/vscode-workspaces/workspaces.py"
alias cdf='cd "$(find . -type d | fzf)"'

# key bindings
bindkey '^[[1;2D' backward-word # Shift + Left Arrow
bindkey '^[[1;2C' forward-word  # Shift + Right Arrow

bindkey '^[[1;5W' backward-kill-word # Ctrl + W
bindkey '^[[1;5K' kill-line          # Ctrl + K
bindkey '^[[1;5U' backward-kill-line # Ctrl + U
bindkey '^[[1;5D' kill-word          # Ctrl + D

# Insert and overwrite toggle
bindkey '^[[1;5Q' overwrite-mode     # Ctrl + Q
bindkey '^[[1;5F' autosuggest-accept # Ctrl + F

bindkey '^[c' capitalize-word # Alt + C

# Lowercase word
bindkey '^[d' down-case-word # Alt + D

# Uppercase word
bindkey '^[u' up-case-word # Alt + U
