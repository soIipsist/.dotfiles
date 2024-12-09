plugins=(
    zsh-autosuggestions
)
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/Users/p/platform-tools/:$PATH"
export YTDLP_PATH="~/ytdlp/yt-dlp_macos"
export FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"
export DOTFILES_DIRECTORY="~/Desktop/soIipsist/.dotfiles"

# aliases
alias python="python3"
alias clera="clear"
alias clearclear="clear"
alias yt="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py"
alias workspaces="python3 $DOTFILES_DIRECTORY/scripts/workspaces.py"
