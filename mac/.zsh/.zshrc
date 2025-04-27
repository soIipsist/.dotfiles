plugins=(
    zsh-autosuggestions
)

if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi

source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$dotfiles_directory/.config/themes/theme.sh"

function repeat-last-command() {
    BUFFER=$(fc -ln -1)
    zle accept-line
}

function copy-line-to-keyboard() {
    echo -n "$BUFFER" | pbcopy
}

function cap() { tee /tmp/capture.out; }

function ret() { cat /tmp/capture.out; }

function sesh-sessions() {
    {
        exec </dev/tty
        exec <&1
        local session
        session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
        zle reset-prompt >/dev/null 2>&1 || true
        [[ -z "$session" ]] && return
        sesh connect $session
    }
}

function get_codec() {
    if [ ! -f "$1" ]; then
        echo "File not found: $1" >&2
        return 1
    fi
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$1")
    echo "$codec"
}

# PATH variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/platform-tools/:$PATH"

# useful paths
export GIT_HOME="$HOME/repos/soIipsist"

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE="2000"
export SAVEHIST="2000"
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt PROMPT_SUBST

# iterm2
export CLICOLOR=1
export TERM=xterm-256color

# tmux
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/"

# enable zsh's autocompletion system
autoload -U compinit
compinit

# initialize zoxide
if which zoxide &>/dev/null; then
    source <(zoxide init zsh)
fi

# zsh completion settings
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu select=2

if [ -f ~/.zsh_ytdlp_aliases ]; then
    . ~/.zsh_ytdlp_aliases
fi

if [ -f ~/.zsh_download_aliases ]; then
    . ~/.zsh_download_aliases
fi

# VSCode variables
export VSCODE_WORKSPACE_DIRECTORY="$GIT_HOME/vscode-workspaces/.workspaces"
export VSCODE_PROJECT_DIRECTORY="$GIT_HOME"
export OLLAMA_MODEL="deepseek-r1:14b"

# aliases
alias python="python3"
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

zle -N repeat-last-command
zle -N copy-line-to-keyboard
zle -N copy-last-command-output
zle -N sesh-sessions

bindkey '^a' sesh-sessions          # Ctrl + A
bindkey '^Xr' repeat-last-command   # Ctrl + X followed by R
bindkey '^Xc' copy-line-to-keyboard # Ctrl + X followed by C
bindkey -s '^Xo' "cpout\n"          # Ctrl + X followed by O
bindkey -s ^f "tmux-sessionizer\n"  # Ctrl + F

# zsh suggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff"

# tmux aliases
alias t='tmux attach || tmux new-session'
alias ta='tmux attach -t'
alias tn='tmux new-session'
alias tl='tmux list-sessions'
alias tk='tmux kill-server'
