# useful environment variables
export GIT_HOME="$HOME/repos/soIipsist"
export DEFAULT_EDITOR="vscode"

# VSCode variables
export VSCODE_WORKSPACE_DIRECTORY="$GIT_HOME/.workspaces"
export VSCODE_PROJECT_DIRECTORY="$GIT_HOME"

# sqlite variables
export SQLITE_DB="$SCRIPTS_DIRECTORY/downloads.db"
export SQLITE_TABLE="downloads"

# set_env variables
export ENV_SKIP_CONFIRM=0
export ENV_DEFAULT_ACTION="set"

# organize files variables
export BACKUP_DIRECTORY="/tmp/backup"
export DRY_RUN=0
export MOVE_FILES=0

alias python='python3'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ps='ps aux --sort=-%mem | head'

# tmux aliases
alias t='tmux attach || tmux new-session'
alias ta='tmux attach -t'
alias tn='tmux new-session'
alias tl='tmux list-sessions'
alias tk='tmux kill-server'

# docker aliases
alias dpl="docker pull"
alias dlc="docker container ls"
alias dlca="docker container ls -a"
alias dli="docker images"
alias dsc="docker container stop"
alias drc="docker container rm"
alias dri="docker image rm"

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

set_env() {
    run_venv_script "set_env.py" "$@"
}

sudoe() {
    if (($# == 0)); then
        echo "Usage: sudoe <command> [args...]"
        return 1
    fi

    local cmd=$1
    shift

    local quoted_args=()
    for arg in "$@"; do
        quoted_args+=("$(printf '%q' "$arg")")
    done
    local joined_args="${quoted_args[*]}"

    if [[ $(type "$cmd") == *function* ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            command sudo -E zsh -ic "source /home/$USER/.zshrc; $cmd $joined_args"
        else
            command sudo -E bash -ic "source /home/$USER/.bashrc; $cmd $joined_args"
        fi
    elif [[ $(type "$cmd") == *alias* ]]; then
        if [[ -n $ZSH_VERSION ]]; then
            command sudo -E zsh -ic "source /home/$USER/.zshrc; $cmd $joined_args"
        else
            command sudo -E bash -ic "source /home/$USER/.bashrc; $cmd $joined_args"
        fi
    else
        command sudo "$cmd" "$@"
    fi
}
