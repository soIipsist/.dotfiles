plugins=(
    zsh-autosuggestions
)

if [ -z "$dotfiles_directory" ]; then
    export dotfiles_directory="$HOME"
fi

source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

function repeat-last-command() {
    BUFFER=$(fc -ln -1)
    zle accept-line
}

function copy-line-to-keyboard() {
    echo -n "$BUFFER" | xclip -selection clipboard
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

# PATH variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/usr/local/ffmpeg/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

export LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:$LD_LIBRARY_PATH"

# useful paths
export GIT_HOME="$HOME/repos/soIipsist"

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE="2000"
export SAVEHIST="2000"
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

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

# prompt
autoload -Uz vcs_info
precmd() {
    vcs_info
}
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%b)'

export PROMPT="%(?.%F{211}●.%F{red}●%f) %F{211}%1~%f ${vcs_info_msg_0_} "

# aliases
alias python="python3"
alias cdf='cd "$(find . -type d | fzf)"'

if [ -f ~/.zsh_ytdlp_aliases ]; then
    . ~/.zsh_ytdlp_aliases
fi

if [ -f ~/.zsh_download_aliases ]; then
    . ~/.zsh_download_aliases
fi

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

# general service control
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias sstatus='systemctl status'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'
alias sjournal='journalctl -u'
alias sjtail='journalctl -fu'
