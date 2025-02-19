sketchybar --reload
aerospace reload-config
brew services restart borders

sketchybar --animate sin 7 --set reload icon.color.alpha=0.5 icon.color.alpha=1.0

# for copying colors from .colors to $HOME/.config/colors

if [ -z "$DOTFILES_DIRECTORY" ]; then # REPLACE DEFAULT DOTFILES_DIRECTORY
    DOTFILES_DIRECTORY="$HOME/repos/soIipsist/.dotfiles"
fi

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

for file in "$DOTFILES_DIRECTORY/mac/.colors"/*.json; do
    cp -f $file $dotfiles_directory/.config/colors
done
