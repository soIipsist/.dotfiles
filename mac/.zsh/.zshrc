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

function run_venv_script() {
    local SCRIPT_NAME="$1"
    shift

    if [ -z "$SCRIPTS_DIRECTORY" ]; then
        if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
            GIT_DOTFILES_DIRECTORY="$HOME"
        fi
        SCRIPTS_DIRECTORY="$GIT_DOTFILES_DIRECTORY/scripts"
    fi
    local SCRIPT_PATH="$SCRIPTS_DIRECTORY/$SCRIPT_NAME"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Could not find script: $SCRIPT_PATH"
        return 1
    fi

    if [ -n "$VENV_PATH" ]; then
        source "$VENV_PATH/bin/activate"
    fi

    python3 "$SCRIPT_PATH" "$@"

    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

#   export RSYNC_REMOTE="user@host"
#   export RSYNC_REMOTE_DIR="/remote/dir"

function rsync_push() {
    local file="$1"
    local server_alias="${2:-$RSYNC_REMOTE}"
    local remote_dir="${3:-$RSYNC_REMOTE_DIR}"

    if [[ -z $file || -z $server_alias || -z $remote_dir ]]; then
        echo "Usage: rsync_push <file|dir> [server_alias] [/remote/dir]"
        return 1
    fi

    rsync -avz --progress "$file" "${server_alias}:${remote_dir}/"
}

function rsync_pull() {
    local file="$1"
    local server_alias="${2:-$RSYNC_REMOTE}"
    local remote_dir="${3:-$RSYNC_REMOTE_DIR}"
    local local_dir="${4:-.}"

    if [[ -z $file || -z $server_alias || -z $remote_dir ]]; then
        echo "Usage: rsync_pull <file|dir> [server_alias] [/remote/dir] [local_dir]"
        return 1
    fi

    rsync -avz --progress \
        "${server_alias}:${remote_dir}/${file}" \
        "${local_dir}/"
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

if [ -f ~/.ytdlp_aliases ]; then
    . ~/.ytdlp_aliases
fi

if [ -f ~/.download_aliases ]; then
    . ~/.download_aliases
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

bindkey '^[c' c1apitalize-word # Alt + C
bindkey '^[d' down-case-word   # Alt + D
bindkey '^[u' up-case-word     # Alt + U

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
