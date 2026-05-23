install_udown() {
    oldpwd="$PWD"

    cd "$GIT_HOME" || return

    git clone https://github.com/soIipsist/udown.git

    cd udown || {
        cd "$oldpwd"
        return
    }

    python3 -m venv venv

    ./venv/bin/pip install -e ".[all]"

    mkdir -p "$HOME/.local/bin"
    ln -sf "$PWD/venv/bin/udown" "$HOME/.local/bin/udown"
    cd "$oldpwd" || return
}

GIT_HOME="${GIT_HOME:-$HOME}"

install_udown
