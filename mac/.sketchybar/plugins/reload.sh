if [ ! -z "$color_scheme" ]; then
    source "$dotfiles_directory/.config/colors/set_colors.sh" "$color_scheme"
fi

sketchybar --reload
aerospace reload-config
brew services restart borders

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0

# for copying colors from .colors to $HOME/.config/colors

# if [ -z "$GIT_DOTFILES_DIRECTORY" ]; then # REPLACE DEFAULT GIT_DOTFILES_DIRECTORY
#     GIT_DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
# fi

# if [ -z "$dotfiles_directory" ]; then
#     dotfiles_directory="$HOME"
# fi

# for file in "$GIT_DOTFILES_DIRECTORY/mac/.colors"/*.json; do
#     cp -f $file $dotfiles_directory/.config/colors
# done
