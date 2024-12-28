plugins=(
    zsh-autosuggestions
)
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# PATH variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/Users/p/platform-tools/:$PATH"

# YTDLP options
export YTDLP_PATH="~/ytdlp/yt-dlp_macos"
export YTDLP_VIDEO_DIRECTORY="/Users/p/Desktop/videos"
export YTDLP_AUDIO_DIRECTORY="/Users/p/Desktop/music"
export YTDLP_AUDIO_EXT="mp3"
export YTDLP_VIDEO_EXT="mp4"
export YTDLP_VIDEO_SOUND_EXT="m4a"
export YTDLP_FORMAT="audio"
export YTDLP_EXTRACT_INFO="1"
export FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"
export DOTFILES_DIRECTORY="~/repos/soIipsist/.dotfiles"

# aliases
alias python="python3"
alias clera="clear"
alias clearclear="clear"
alias ytdlp="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py"
alias ytdlp_mp3="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f audio -a mp3"
alias ytdlp_mp4="python3 $DOTFILES_DIRECTORY/scripts/ytdlp.py -f video -v mp4"
alias workspaces="python3 $DOTFILES_DIRECTORY/scripts/workspaces.py"
alias yabaistop="yabai --stop-service"
alias yabaistart="yabai --start-service"
alias skhdstart="skhd --start-service"
alias skhdstop="skhd --stop-service"
alias vlc="/Applications/VLC.app/Contents/MacOS/VLC"
