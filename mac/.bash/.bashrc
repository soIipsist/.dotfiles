# ~/.bashrc — executed for non-login interactive shells on macOS

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Don't store duplicate lines or lines starting with space in history
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend # Append to history file instead of overwriting
HISTSIZE=1000
HISTFILESIZE=2000
export HISTTIMEFORMAT="%F %T "

# Resize terminal automatically
shopt -s checkwinsize

# Customize prompt with color (if supported)
if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
    color_prompt=yes
fi

# Colors
ORANGE='\[\e[38;5;208m\]' # Bright orange
BLUE='\[\e[38;5;69m\]'    # Royal blue
GREEN='\[\e[38;5;10m\]'   # Light green (ANSI 10)
RESET='\[\e[0m\]'

parse_git_branch() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        echo "($branch)"
    fi
}

if [ "$color_prompt" = yes ]; then
    if id -nG "$USER" | grep -Eq '\bsudo\b|\badmin\b'; then
        PS1="${BLUE}\u@\h ${ORANGE}\W ${GREEN}\$(parse_git_branch)${RESET} \$ "
    else
        PS1="${ORANGE}\u@\h ${BLUE}\W ${GREEN}\$(parse_git_branch)${RESET} \$ "
    fi
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Set terminal title in supported terminals
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# Enable color support for ls, grep, etc.
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
    alias ls='ls --color=auto'
else
    alias ls='ls -G' # macOS fallback (uses built-in color)
fi

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

run_venv_script() {
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

run_in_tmux_session() {
    local cmd="$1"
    local tmux_session_name="${2:-downloads}"

    cmd+="; exec \$SHELL"

    if tmux has-session -t "$tmux_session_name" 2>/dev/null; then
        tmux new-window -t "$tmux_session_name" -n "$tmux_session_name-$(date +%s)" "$SHELL" -c "$cmd"
    else
        echo "Starting detached tmux session."
        tmux new-session -d -s "$tmux_session_name" -n "$tmux_session_name-$(date +%s)" "$SHELL" -c "$cmd"
    fi
}

# Add Homebrew and custom tools to PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/platform-tools:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

# aliases
if [ -f ~/.ytdlp_aliases ]; then
    . ~/.ytdlp_aliases
fi

if [ -f ~/.rsync_aliases ]; then
    . ~/.rsync_aliases
fi

if [ -f ~/.fzf_aliases ]; then
    . ~/.fzf_aliases
fi

if [ -f ~/.download_aliases ]; then
    . ~/.download_aliases
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Bash completion (Homebrew location on macOS)
if [ -f /opt/homebrew/etc/bash_completion ]; then
    source /opt/homebrew/etc/bash_completion
fi

eval "$(zoxide init bash)"

if [ -n "$ZSH_VERSION" ]; then
    source <(fzf --zsh)
else
    eval "$(fzf --bash)"
fi

# Improve tab completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
