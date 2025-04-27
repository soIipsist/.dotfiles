# ~/.bashrc — executed for non-login interactive shells on macOS

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Don't store duplicate lines or lines starting with space in history
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend # Append to history file instead of overwriting
HISTSIZE=1000
HISTFILESIZE=2000

# Resize terminal automatically
shopt -s checkwinsize

# Customize prompt with color (if supported)
if command -v tput &>/dev/null && tput setaf 1 &>/dev/null; then
    color_prompt=yes
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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

# YTDLP environment variables
export YTDLP_PATH="$HOME/ytdlp/yt-yt-dlp_macos"
export YTDLP_FORMAT="audio"
export YTDLP_EXTRACT_INFO="1"
export YTDLP_OPTIONS_PATH=""
export FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"
export VENV_PATH="$HOME/venv"

# downloader options
export DOWNLOADS_PATH="$HOME/downloads/music.txt"
export DOWNLOADS_OUTPUT_DIR="$HOME/downloads"

# Load aliases if available
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# Bash completion (Homebrew location on macOS)
if [ -f /opt/homebrew/etc/bash_completion ]; then
    source /opt/homebrew/etc/bash_completion
fi

# Add Homebrew and custom tools to PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/platform-tools:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

eval "$(zoxide init bash)"

# Improve tab completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
