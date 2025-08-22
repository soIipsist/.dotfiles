from argparse import ArgumentParser
import os
import subprocess

bool_choices = [0, 1, "true", "false", True, False, None]


def str_to_bool(string: str):
    return string in ["1", "true", True]


def get_default_shell_path(path: str):
    if not os.path.exists(path):
        home_directory = os.path.expanduser("~")

        if path == "bash":
            return os.path.join(home_directory, ".bashrc")
        elif path == "zsh":
            return os.path.join(home_directory, ".zshrc")
        elif path == "fish":
            return os.path.join(home_directory, ".config", "fish", "config.fish")
        else:
            raise EnvironmentError(f"Unsupported shell: {shell_path}")

    return path


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

    if value:  # set

        try:
            if os.name == "nt":
                subprocess.run(["setx", key, value], check=True)
            else:
                # Modify shell configuration files for macOS or Linux

                with open(shell_path, "a") as f:
                    f.write(f'\nexport {key}="{value}"\n')

            os.environ[key] = f"{value}"
            print(f"Setting environment variable {key}: {value}")
            print(f"Added '{value}' as an environment variable.")

        except Exception as e:
            print(f"An error occurred while setting the environment variable: {e}")
    else:
        try:
            if os.name == "nt":
                subprocess.run(["setx", key, ""], check=True)
            else:
                with open(shell_path, "r") as f:
                    lines = f.readlines()

                with open(shell_path, "w") as f:
                    for line in lines:
                        if line.strip().startswith(f"export {key}="):
                            f.write("\n")  # replace with blank line
                        else:
                            f.write(line)

            # Remove from current process
            os.environ.pop(key, None)
            print(f"[-] Unset environment variable {key}")

        except Exception as e:
            print(f"[!] Error unsetting environment variable: {e}")


def set_environment_variables(
    environment_variables: list, shell_path: str, action: str
):
    """Sets environment variables based on default shell path."""

    shell_path = get_default_shell_path(shell_path)

    for var in environment_variables:
        var: str

        key, value = var.split("=", 1)
        value = get_value(key, value, action)
        set_environment_variable(key, value, shell_path)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("environment_variables", nargs="+")
    parser.add_argument("-s", "--shell_path", default="bash", type=str)
    parser.add_argument(
        "-a",
        "--action",
        default="set",
        choices=["append", "unset", "set"],
    )
    args = vars(parser.parse_args())

    environment_variables = args.get("environment_variables")
    shell_path = args.get("shell_path")
    action = args.get("action")

    set_environment_variables(environment_variables, shell_path, action)
