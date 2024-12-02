plugins=(
    zsh-autosuggestions
)
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/Users/p/platform-tools/:$PATH"
export YTDLP_PATH="~/ytdlp/yt-dlp_macos"
export FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"

# aliases
alias python="python3"
alias clera="clear"
alias clearclear="clear"
