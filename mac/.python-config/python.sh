#!/bin/bash
source "../json.sh"

install_pip_packages() {
    pip_packages=$1

    for package in $pip_packages; do
        python3 -m pip install $package
    done

}

pip_packages=$(get_json_value "pip_packages")
install_pip_packages "${pip_packages[@]}"
