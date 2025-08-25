from argparse import ArgumentParser
import os
import subprocess

bool_choices = [0, 1, "true", "false", True, False, None]


def str_to_bool(string: str):
    return string in ["1", "true", True]


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

    if existing_value:
        if value not in existing_value.split(separator):
            return f"{existing_value.rstrip(separator)}{separator}{value}"
        return existing_value
    return value


def get_value(key: str, value: str, action: str):
    if action == "append":
        value = get_appended_value(key, value)
    elif action == "unset":
        value = None

    return value


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
    environment_variables: list, shell_path: str, action: str, skip_confirmation=None
):
    """Sets environment variables based on default shell path."""

    shell_path = get_default_shell_path(shell_path)

    for var in environment_variables:
        var: str

        parts = var.split("=", 1)
        key, value = (parts[0], parts[1]) if len(parts) > 1 else (parts[0], None)
        value = get_value(key, value, action)

        initial_action = action
        if value is None:
            action = "unset"

        if not skip_confirmation:
            prompt = input(
                f"Performing {action} on {var} ({shell_path}). Are you sure? (Y/y)"
            )
            if prompt.lower() == "y":
                set_environment_variable(key, value, shell_path)
            else:
                print(f"Cancelled {action} for {var}.")
        else:
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
        default="set",
        choices=["append", "unset", "set"],
    )
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Skip confirmation prompts and assume 'yes'",
    )
    args = vars(parser.parse_args())

    environment_variables = args.get("environment_variables")
    shell_path = args.get("shell_path")
    action = args.get("action")
    skip_confirmation = args.get("yes")

    set_environment_variables(
        environment_variables, shell_path, action, skip_confirmation
    )
