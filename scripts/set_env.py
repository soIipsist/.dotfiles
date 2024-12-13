from argparse import ArgumentParser
import os
import subprocess

bool_choices = [0, 1, "true", "false", True, False, None]


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
            raise EnvironmentError(f"Unsupported shell: {shell}")

    return path


def set_environment_variables(
    environment_variables: list, default_shell_path: str = None
):
    """Sets sdk path as a PATH environment variable."""

    for var in environment_variables:
        var: str

        key, value = var.split("=", 1) if "=" in var else (var, None)
        print(key, value)
        try:
            if os.name == "nt":
                current_path = os.environ.get("PATH", "")
                updated_path = f"{current_path};{value}"
                subprocess.run(["setx", "PATH", updated_path], check=True)
            else:
                # Modify shell configuration files for macOS or Linux
                home_dir = os.path.expanduser("~")

                with open(default_shell_path, "a") as f:
                    f.write(f'\nexport {key}="{value}"\n')

                prompt = input(
                    f"Environment variable was updated in {default_shell_path}. Would you like to execute it? (y/n)"
                )

                if prompt == "y":
                    subprocess.run(
                        f"source {default_shell_path}",
                        shell=True,
                        check=True,
                        cwd=home_dir,
                    )
                    print("Sourced config file successfully.")

                else:
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
    parser.add_argument("-p", "--is_path", default=False, choices=bool_choices)

    args = vars(parser.parse_args())

    environment_variables = args.get("environment_variables")
    shell = args.get("shell")
    set_environment_variables(environment_variables, shell)
