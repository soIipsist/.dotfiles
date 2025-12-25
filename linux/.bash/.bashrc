# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
# export HISTTIMEFORMAT="%F %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
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
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

run_venv_script() {
    local USE_SUDO=0

    if [ "$1" = "--sudo" ]; then
        USE_SUDO=1
        shift
    fi

    local SCRIPT_PATH="$1"
    shift

    if [ ! -f "$SCRIPT_PATH" ]; then # script is only a name
        if [ -z "$SCRIPTS_DIRECTORY" ]; then
            if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then
                GIT_DOTFILES_DIRECTORY="$HOME"
            fi
            SCRIPTS_DIRECTORY="$GIT_DOTFILES_DIRECTORY/scripts"
        fi
        SCRIPT_PATH="$SCRIPTS_DIRECTORY/$SCRIPT_PATH"
    fi

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Could not find script: $SCRIPT_PATH"
        return 1
    fi

    if [ -n "$VENV_PATH" ]; then
        source "$VENV_PATH/bin/activate"
    fi

    if [ "$USE_SUDO" -eq 1 ]; then
        sudo -E python3 "$SCRIPT_PATH" "$@"
    else
        python3 "$SCRIPT_PATH" "$@"
    fi

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

export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/python@3.13/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="/usr/local/ffmpeg/bin:/usr/local/ffmpeg/lib:$PATH"
export PATH="$HOME/.local/bin:$HOME/.local/lib/python3.13/site-packages:$PATH"
export PATH="/usr/games:/usr/local/go/bin:$GOBIN:$PATH"
export GOBIN=$(go env GOPATH)/bin
export LD_LIBRARY_PATH="/usr/local/ffmpeg/lib:$LD_LIBRARY_PATH"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# aliases

if [ -f ~/.rsync_aliases ]; then
    . ~/.rsync_aliases
fi

if [ -f ~/.fzf_aliases ]; then
    . ~/.fzf_aliases
fi

if [ -f ~/.ytdlp_aliases ]; then
    . ~/.ytdlp_aliases
fi

if [ -f ~/.llm_aliases ]; then
    . ~/.llm_aliases
fi

if [ -f ~/.torrents_aliases ]; then
    . ~/.torrents_aliases
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.vm_aliases ]; then
    . ~/.vm_aliases
fi

if [ -f ~/.network_aliases ]; then
    . ~/.network_aliases
fi

# if [ -f ~/.ufw_aliases ]; then
#     . ~/.ufw_aliases
# fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(zoxide init bash)"

if [ -n "$ZSH_VERSION" ]; then
    source <(fzf --zsh)
else
    eval "$(fzf --bash)"
fi

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# fzf bindings
bind -x '"\C-h":fzfh'
bind -x '"\C-f":fzfe'
bind -x '"\C-p":fzfc'
bind -x '"\C-g":fzfg'
