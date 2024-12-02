import os
import argparse
import subprocess
from shlex import split
from pathlib import Path

parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0, parentdir)

from utils.path_utils import is_valid_dir, is_valid_path


def is_git_repository(git_repository: str):
    try:
        subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=git_repository,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True,
        )
        return git_repository
    except subprocess.CalledProcessError:
        raise ValueError(f"'{git_repository}' is not a git repository.")


def find_bfg_path(bfg_directory: str):
    dir_path = Path(bfg_directory)
    matching_paths = [file for file in dir_path.glob(f"bfg*.jar") if file.is_file()]

    if matching_paths:
        return matching_paths[0].as_posix()


def install_bfg_cleaner(bfg_directory: str, bfg_version):

    try:
        bfg_path = os.path.normpath(f"{bfg_directory}/bfg.jar")
        url = f"https://repo1.maven.org/maven2/com/madgag/bfg/{bfg_version}/bfg-{bfg_version}.jar"
        subprocess.run(["curl", "-o", bfg_path, url], cwd=bfg_directory)
        print(f"File downloaded successfully to {bfg_directory}")

    except subprocess.CalledProcessError as e:
        raise ValueError(f"Error downloading file: {e}")

    return bfg_path


def clean_file_history(bfg_path: str, git_repository: str, file_path: str):

    file_path_dir = os.path.dirname(file_path)
    file_path = os.path.basename(file_path)

    # first, delete file in question
    subprocess.run(["rm", f"{file_path}"], cwd=file_path_dir)

    # commit changes
    subprocess.run(["git", "add", "."], cwd=git_repository)
    subprocess.run(["git", "commit", "-m", f"removed {file_path}"], cwd=git_repository)

    # bfg delete_files command

    subprocess.run(
        ["java", "-jar", bfg_path, "--delete-files", f"{file_path}"], cwd=git_repository
    )

    # git reflog
    subprocess.run(
        split(
            "git reflog expire --expire=now --all && git gc --prune=now --aggressive"
        ),
        cwd=git_repository,
    )

    # force push changes
    subprocess.run(split("git push --force"), cwd=git_repository)


if __name__ == "__main__":
    formatter_class = lambda prog: argparse.HelpFormatter(prog, max_help_position=100)
    parser = argparse.ArgumentParser(formatter_class=formatter_class)

    parser.add_argument(
        "git_repository",
        type=is_git_repository,
        help="Git repository from which to erase file history.",
    )
    parser.add_argument(
        "-f", "--file_path", type=is_valid_path, help="File path in git repository."
    )
    parser.add_argument(
        "-b",
        "--bfg_directory",
        default=os.getcwd(),
        type=is_valid_dir,
        help="bfg.jar path. If not specified, base directory will be used by default.",
    )
    parser.add_argument(
        "-v",
        "--bfg_version",
        default="1.14.0",
        help="Downloads the specified version of bfg if the relevant bfg.jar file is not already present.",
    )

    args = vars(parser.parse_args())

    git_repository = args.get("git_repository")
    file_path = args.get("file_path")
    bfg_directory = args.get("bfg_directory")
    bfg_version = args.get("bfg_version")

    bfg_path = find_bfg_path(bfg_directory)

    if not bfg_path:
        print("Installing bfg.jar file...")
        bfg_path = install_bfg_cleaner(bfg_directory, bfg_version)

    if file_path:
        print("Removing commit history for file: ", file_path)
        clean_file_history(bfg_path, git_repository, file_path)
