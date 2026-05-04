from argparse import ArgumentParser
import os
import subprocess
from utils import str_to_bool


def get_default_shell_path(path: str) -> str:
    shell_map = {
        "/bin/bash": "bash",
        "/bin/zsh": "zsh",
        "/usr/bin/fish": "fish",
    }

    rc_files = {
        "bash": ".bashrc",
        "zsh": ".zshrc",
        "fish": os.path.join(".config", "fish", "config.fish"),
    }

    shell_path = shell_map.get(path, path)

    if not os.path.exists(shell_path) and shell_path in rc_files:
        return os.path.join(os.path.expanduser("~"), rc_files[shell_path])

    return shell_path


def get_appended_value(key: str, value: str) -> str:
    """
    Appends a new value to an existing environment variable.

    """
    if not value:
        raise ValueError("Value to append cannot be None or empty.")

    existing_value = os.environ.get(key)
    separator = ";" if os.name == "nt" else ":"

    # Split existing values, ignore empty entries
    parts = [v for v in existing_value.split(separator) if v]

    if value not in parts:
        parts.append(value)

    return separator.join(parts)


def get_environment_variable(key: str):
    value = os.environ.get(key)

    if value is None:
        print(f"{key} is not set")
    else:
        print(f"{key}={value}")


def set_environment_variable(key: str, value: str, shell_path: str):

    if value:

        try:
            if os.name == "nt":
                subprocess.run(["setx", key, value], check=True)
            else:
                lines = []
                new_line = f'export {key}="{value}"\n'
                replaced = False

                with open(shell_path, "r") as f:
                    lines = f.readlines()

                for i, line in enumerate(lines):
                    stripped = line.strip()
                    # match lines like 'export KEY=' or 'KEY='
                    if stripped.startswith(f"export {key}=") or stripped.startswith(
                        f"{key}="
                    ):
                        lines[i] = new_line
                        replaced = True
                        break

                if not replaced:
                    # append at end if not found
                    if lines and not lines[-1].endswith("\n"):
                        lines[-1] += "\n"
                    lines.append(new_line)

                with open(shell_path, "w") as f:
                    f.writelines(lines)

            os.environ[key] = f"{value}"
            print(f"Setting environment variable {key}: {value}")

        except Exception as e:
            print(f"An error occurred while setting the environment variable: {e}")
    else:
        # if value is None, it means unset the variable

        try:
            if os.name == "nt":
                subprocess.run(["setx", key, ""], check=True)
            else:
                with open(shell_path, "r") as f:
                    lines = f.readlines()

                with open(shell_path, "w") as f:
                    for line in lines:
                        stripped = line.strip()
                        if stripped.startswith(f"export {key}=") or stripped.startswith(
                            f"{key}="
                        ):
                            f.write("")  # replace with empty line
                        else:
                            f.write(line)

            # Remove from current process
            os.environ.pop(key, None)
            print(f"[-] Unset environment variable {key} in {shell_path}")

        except Exception as e:
            print(f"[!] Error unsetting environment variable: {e}")


def set_environment_variables(
    environment_variables: list,
    shell_path: str,
    action: str = None,
    skip_confirmation=None,
):
    """Sets environment variables based on default shell path."""

    if not action:
        action = "get"

    shell_path = get_default_shell_path(shell_path)

    for var in environment_variables:
        var: str

        parts = var.split("=", 1)
        key, value = (parts[0], parts[1]) if len(parts) > 1 else (parts[0], None)

        if action == "get":
            get_environment_variable(key)
            continue

        initial_action = action
        value = get_appended_value(key, value) if action == "append" else None

        if value is None:
            action = "unset"

        if not skip_confirmation:
            prompt = input(
                f"Performing {action} on {var} ({shell_path}). Are you sure? [Y/n] "
            )
            if prompt.lower() != "y":
                print(f"Cancelled {action} for {var}.")
                action = initial_action
                continue

        set_environment_variable(key, value, shell_path)
        action = initial_action


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("environment_variables", nargs="+")
    parser.add_argument(
        "-s", "--shell_path", default=os.environ.get("SHELL", "bash"), type=str
    )
    parser.add_argument(
        "-a",
        "--action",
        default=os.environ.get("ENV_DEFAULT_ACTION"),
        choices=["append", "unset", "set", "get", None, ""],
    )
    parser.add_argument(
        "-y",
        "--yes",
        nargs="?",
        const=True,
        type=str_to_bool,
        default=os.environ.get("ENV_SKIP_CONFIRM", False),
        help="Skip confirmation prompts and assume 'yes'",
    )
    args = parser.parse_args()

    set_environment_variables(
        args.environment_variables, args.shell_path, args.action, args.yes
    )
