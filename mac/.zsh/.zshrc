plugins=(
    zsh-autosuggestions
)
source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# PATH variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/platform-tools/:$PATH"

# tmux
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"

# zoxide
eval "$(zoxide init zsh)"

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
export OLLAMA_MODEL="deepseek-r1:14b"

# aliases
alias python="python3"
alias ytdlp="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py"
alias ytdlp_mp3="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f audio -a mp3"
alias ytdlp_mp4="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f video -v mp4"
alias yabais="yabai --start-service"
alias yabaik="yabai --stop-service"
alias yabair="yabai --restart-service"
alias skhds="skhd --start-service"
alias skhdk="skhd --stop-service"
alias skhdr="skhd --restart-service"
alias vlc="/Applications/VLC.app/Contents/MacOS/VLC"
alias ios_backup="python3 $GIT_HOME/ios-backup-extractor/extract.py"
alias adb_transfer="python3 $GIT_HOME/adb-wrapper/examples/transfer.py"
alias adb_root="python3 $GIT_HOME/adb-wrapper/examples/root.py"
alias vscode="python3 $GIT_HOME/vscode-workspaces/workspaces.py"
alias cdf='cd "$(find . -type d | fzf)"'
alias dots="(cd $DOTFILES_DIRECTORY/mac && bash mac.sh)"
alias llm="ollama run $OLLAMA_MODEL"

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
bindkey '^[d' down-case-word  # Alt + D
bindkey '^[u' up-case-word    # Alt + U

bindkey -s ^f "tmux-sessionizer\n" # Ctrl + F

# zle functions
function repeat-last-command() {
    BUFFER=$(fc -ln -1)
    zle accept-line
}

function copy-line-to-keyboard() {
    echo -n "$BUFFER" | pbcopy
}

function copy-last-command-output() {
    last_cmd=$(fc -ln -1 | tail -n 1 | tr -d '\n' | tr -cd '[:print:]')
    output=$(eval "$last_cmd")
    trimmed_output=$(printf "%s" "$output")
    echo "$trimmed_output" | pbcopy
    echo "Last command's output copied to clipboard."
    zle accept-line
}

function cap() { tee /tmp/capture.out; }

function ret() { cat /tmp/capture.out; }

zle -N repeat-last-command
zle -N copy-line-to-keyboard
zle -N copy-last-command-output

bindkey '^Xr' repeat-last-command      # Ctrl + X followed by R
bindkey '^Xc' copy-line-to-keyboard    # Ctrl + X followed by C
bindkey '^Xo' copy-last-command-output # Ctrl + X followed by O
