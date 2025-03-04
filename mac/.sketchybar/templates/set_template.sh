templates=("$@")

# Print array elements
for template in "${templates[@]}"; do
    echo "TEMPL: $template"
done

if [ -z "$dotfiles_directory" ]; then
    dotfiles_directory="$HOME"
fi

sketchybar_folders=("$dotfiles_directory/.config/sketchybar" "$dotfiles_directory/.config/bottombar" "$dotfiles_directory/.config/leftbar" "$dotfiles_directory/.config/rightbar")
templates_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_directory="$(dirname $templates_directory)"
plugins_folder="$source_directory/plugins"

# kill all processes
pkill bottombar
pkill leftbar
pkill rightbar

COUNTER=0

# for template in "${templates_arr[@]}"; do

#     sketchybar_folder="${sketchybar_folders[$COUNTER]}"
#     sketchybarrc_path="$sketchybar_folder/sketchybarrc"
#     sketchybar_plugins_folder="$sketchybar_folder/plugins"
#     bar_name=$(basename $sketchybar_folder)

#     sketchybar_template_path="$templates_directory/$template"

#     # check if sketchybar folder exists
#     if [ ! -d "$sketchybar_folder" ]; then
#         mkdir -p "$sketchybar_folder"
#     fi

#     if [ ! -d "$sketchybar_plugins_folder" ]; then
#         mkdir -p "$sketchybar_plugins_folder"
#     fi

#     # create symbolic links for the bars
#     ln -sf $(which sketchybar) $(dirname $(which sketchybar))/$bar_name

#     # copy all plugins
#     if [ $COPY_PLUGINS -eq 1 ]; then
#         echo "$COPY_PLUGINS"

#         for file in "$plugins_folder"/*; do
#             original_name=$(basename $file)

#             if [ ! "$bar_name" == "sketchybar" ]; then
#                 # Create a temporary file with 'sketchybar' replaced with 'bottombar'
#                 temp_file=$(mktemp)
#                 sed "s/sketchybar/$bar_name/g" "$file" >"$temp_file"
#                 file="$temp_file"
#             fi

#             cp -f "$file" "$sketchybar_plugins_folder/$original_name"
#             echo "Successfully copied $file to $sketchybar_plugins_folder/$original_name."

#             chmod +x "$sketchybar_plugins_folder/$original_name"

#             if [ -f "$temp_file" ]; then
#                 rm -f "$temp_file"
#             fi
#         done
#     fi
#     copy template to home sketchybarrc
#     cp -f "$sketchybar_template_path" "$sketchybarrc_path"
#     COUNTER=$((COUNTER + 1))

# done
