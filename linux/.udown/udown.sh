install_udown() {
    local oldpwd="$PWD"

    cd "$GIT_HOME" || return

    if [ ! -d "udown" ]; then
        git clone https://github.com/soIipsist/udown.git
    fi

    cd udown || {
        cd "$oldpwd" || return
        return
    }

    python3 -m venv venv

    ./venv/bin/pip install -e ".[all]"

    mkdir -p "$HOME/.local/bin"

    ln -sf "$PWD/venv/bin/udown" \
        "$HOME/.local/bin/udown"

    # enable argcomplete
    
    if [ -f "$PWD/venv/bin/register-python-argcomplete" ]; then

        "$PWD/venv/bin/register-python-argcomplete" udown \
            > "$HOME/.udown_argcomplete"

        # for rc in \
        #     "$HOME/.zshrc" \
        #     "$HOME/.bashrc" \
        #     "$HOME/.bash_profile"
        # do
        #     [ -f "$rc" ] || continue

        #     if ! grep -q ".udown_argcomplete" "$rc"; then
        #         echo '' >> "$rc"
        #         echo '# udown argcomplete' >> "$rc"
        #         echo '[ -f "$HOME/.udown_argcomplete" ] && source "$HOME/.udown_argcomplete"' >> "$rc"
        #     fi
        # done

        echo "Argcomplete configured."
    else
        echo "register-python-argcomplete not found."
    fi

    cd "$oldpwd" || return

    echo "udown installed successfully."
}

GIT_HOME="${GIT_HOME:-$HOME}"

install_udown
