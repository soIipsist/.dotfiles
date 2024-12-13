from argparse import ArgumentParser
import os


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
            raise FileNotFoundError(f"Invalid path or unsupported shell: {path}")

    return path


def set_environment_variables(
    environment_variables: list, default_shell_path: str = None
):
    print(default_shell_path, environment_variables)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("environment_variables", nargs="+")
    parser.add_argument(
        "-s", "--default_shell_path", default="bash", type=is_valid_shell_path
    )

    args = vars(parser.parse_args())

    environment_variables = args.get("environment_variables")
    shell = args.get("shell")
    set_environment_variables(environment_variables, shell)
