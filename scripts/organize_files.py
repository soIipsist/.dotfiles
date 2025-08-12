import os
import re
import sys
import shutil
import subprocess
from pathlib import Path
from datetime import datetime
from argparse import ArgumentParser
import mimetypes


def get_exif_year(file_path: Path) -> str | None:
    mime_type, _ = mimetypes.guess_type(file_path)
    if mime_type is None:
        return None

    if mime_type.startswith("video"):
        tags = ["MediaCreateDate", "TrackCreateDate", "CreateDate"]
    elif mime_type.startswith("image"):
        tags = ["DateTimeOriginal", "CreateDate"]
    else:
        return None

    for tag in tags:
        try:
            result = subprocess.run(
                ["exiftool", "-s3", f"-{tag}", "-d", "%Y", str(file_path)],
                capture_output=True,
                text=True,
            )
            year = result.stdout.strip()
            if year and year.isdigit() and len(year) == 4:
                return year
        except Exception:
            continue

    return None


def get_modification_year(file_path):
    try:
        timestamp = os.path.getmtime(file_path)
        return datetime.fromtimestamp(timestamp).strftime("%Y")
    except Exception:
        return None


def copy_file_path(
    file_path: Path, dest_path: Path, move: bool, source_directory: Path
):

    if move:
        # shutil.move(file_path, dest_path)
        print(f"Moved '{file_path}' -> '{dest_path}'")

    else:
        # shutil.copy2(file_path, dest_path)
        print(f"Copied '{file_path}' -> '{dest_path}'")


def organize_by_pattern(
    source_directory: Path,
    destination_directory: Path,
    pattern: str = None,
    replacement: str = None,
    move: bool = None,
):
    if isinstance(source_directory, str):
        pass

    for file_path in source_directory.iterdir():
        if file_path.is_file():
            new_file_path = re.sub(pattern, replacement, file_path)
            print(new_file_path)

            # copy_file_path(file_path)


def create_backup(move: bool, source_directory: Path, backup_directory: Path):

    if not move:
        return

    prompt = input("Moving files, would you like to create a backup? (y/n)")

    if prompt.lower() == "y":
        shutil.copy(source_directory, backup_directory)


def organize_by_year(
    source_directory: Path, destination_directory: Path, move: bool = None
):

    for file_path in source_directory.iterdir():
        if file_path.is_file():
            year = get_exif_year(file_path)
            if not year:
                year = get_modification_year(file_path)

            if not year:
                print(f"Warning: Could not determine year for '{file_path}'")
                continue

            target_dir = destination_directory / year
            target_dir.mkdir(parents=True, exist_ok=True)
            print(f"Created year directory {target_dir}.")

            copy_file_path(file_path, target_dir, move, source_directory)


def get_directory_as_path(self, directory: str):
    if isinstance(directory, str):
        directory = Path(directory)

    if not directory.is_dir():
        print(f"Error: '{directory}' is not a directory.")
        sys.exit(1)

    return directory


def organize_files(
    source_directory: str,
    destination_directory: str = None,
    action: str = None,
    pattern: str = None,
    repl: str = None,
    move: bool = False,
    backup_directory: str = None,
):

    if not destination_directory:
        destination_directory = source_directory

    source_directory = get_directory_as_path(source_directory)
    destination_directory = get_directory_as_path(destination_directory)

    # print(
    #     source_directory,
    #     destination_directory,
    #     move,
    #     backup_directory,
    #     action,
    #     pattern,
    #     repl,
    # )

    create_backup(move, source_directory, backup_directory)

    if action == "year":
        organize_by_year(source_directory, destination_directory, move)
    else:
        organize_by_pattern(
            source_directory, destination_directory, pattern, repl, move
        )


def str_to_bool(string: str):
    return string in ["1", "true", True]


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("source_directory", type=str)
    parser.add_argument("destination_directory", default=None, nargs="?")
    parser.add_argument(
        "-a", "--action", type=str, default="pattern", choices=["pattern", "year"]
    )
    parser.add_argument("-p", "--pattern", type=str)
    parser.add_argument("-r", "--repl", type=str)
    parser.add_argument("-m", "--move", type=str_to_bool, default=False)
    parser.add_argument("-b", "--backup_directory", type=str, default="/tmp")

    args = vars(parser.parse_args())
    organize_files(**args)
