# useful environment variables
export GIT_HOME="$HOME/repos/soIipsist"
export DEFAULT_EDITOR="vscode"

# VSCode variables
export VSCODE_WORKSPACE_DIRECTORY="$GIT_HOME/vscode-workspaces/.workspaces"
export VSCODE_PROJECT_DIRECTORY="$GIT_HOME"

# sqlite variables
export SQLITE_DB="downloads.db"
export SQLITE_TABLE="downloads"

# organize files variables
export BACKUP_DIRECTORY="/tmp/backup"
export DRY_RUN=0
export MOVE_FILES=0

alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

git_pull_all() {
    local base_dir="${GIT_HOME:-.}"

    echo "Running git pull in each subdirectory of: $base_dir"

    find "$base_dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
        if [ -d "$dir/.git" ]; then
            echo ">>> Pulling in $dir"
            git -C "$dir" pull
        else
            echo "Skipping $dir — not a git repository."
        fi
    done
}

# venv scripts
sqliteq() {
    run_venv_script "sqlite.py" "$@"
}

organize_files() {
    if [ "$1" = "--sudo" ]; then
        shift
        run_venv_script --sudo "organize_files.py" "$@"
    else
        run_venv_script "organize_files.py" "$@"
    fi
}

vscode() {
    run_venv_script "vscode_workspaces.py" "$@"
}
