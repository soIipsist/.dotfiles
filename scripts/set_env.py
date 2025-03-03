from argparse import ArgumentParser
import os
import subprocess

bool_choices = [0, 1, "true", "false", True, False, None]


def str_to_bool(string: str):
    return string in ["1", "true", True]


def is_valid_shell_path(path: str):
    if not os.path.exists(path):
        home_directory = os.path.expanduser("~")

        if path == "bash":
            return os.path.join(home_directory, ".bashrc")
        elif path == "zsh":
            return os.path.join(home_directory, ".zshrc")
        elif path == "fish":
            return os.path.join(home_directory, ".config", "fish", "config.fish")
        else:
            raise EnvironmentError(f"Unsupported shell: {default_shell_path}")

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


def set_environment_variables(
    environment_variables: list, default_shell_path: str = None, append: bool = False
):
    """Sets environment variables based on default shell path."""

    for var in environment_variables:
        var: str

        key, value = var.split("=", 1)
        value = get_appended_value(key, value) if append else value

        print(f"Setting environment variable {key}: {value}")

        try:
            if os.name == "nt":
                subprocess.run(["setx", key, value], check=True)
            else:
                # Modify shell configuration files for macOS or Linux

                with open(default_shell_path, "a") as f:
                    f.write(f'\nexport {key}="{value}"\n')

            os.environ[key] = f"{value}"

        except Exception as e:
            print(f"An error occurred while setting the environment variable: {e}")

        print(f"Added '{value}' as an environment variable.")


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("environment_variables", nargs="+")
    parser.add_argument(
        "-s", "--default_shell_path", default="bash", type=is_valid_shell_path
    )
    parser.add_argument(
        "-a", "--append", type=str_to_bool, default=False, choices=bool_choices
    )
    args = vars(parser.parse_args())

    environment_variables = args.get("environment_variables")
    default_shell_path = args.get("default_shell_path")
    append = args.get("append")

    set_environment_variables(environment_variables, default_shell_path, append)
