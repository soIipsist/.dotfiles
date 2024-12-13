from argparse import ArgumentParser


def set_environment_variables(shell: str, environment_variables: list):
    print(shell, environment_variables)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument(
        "-s", "--default_shell", default="bash", choices=["bash", "zsh", ""]
    )
    parser.add_argument("-e", "--environment_variables", nargs="+")
    args = vars(parser.parse_args())
