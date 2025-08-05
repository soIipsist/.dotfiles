import os
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


def organize_by_pattern(
    source_directory: str,
    destination_directory: str = None,
    pattern: str = None,
    **args,
):
    pass


def organize_by_year(source_directory: str, destination_directory: str = None, **args):

    for file_path in source_directory.iterdir():
        if file_path.is_file():
            year = get_exif_year(file_path)
            if not year:
                year = get_modification_year(file_path)

            print("FILE PATH", file_path)
            print("YEAR", year)

            if not year:
                print(f"Warning: Could not determine year for '{file_path}'")
                continue

            target_dir = destination_directory / year
            target_dir.mkdir(parents=True, exist_ok=True)

            shutil.copy2(file_path, target_dir)
            print(f"Copied '{file_path}' -> '{target_dir}/'")


def copy_file_path(move: bool = False):
    pass


def organize_files(
    source_directory: str,
    destination_directory: str = None,
    action: str = None,
    pattern: str = None,
):

    source_path = Path(source_directory)
    dest_path = (
        Path(destination_directory) if destination_directory else source_path
    )  # moves photos to source_directory if not defined

    if not source_path.is_dir():
        print(f"Error: Source directory '{source_path}' is not a directory.")
        sys.exit(1)

    if not dest_path.is_dir():
        print(f"Error: Destination directory '{dest_path}' is not a directory.")
        sys.exit(1)

    if action == "year":
        organize_by_year(source_path, dest_path)
    else:
        organize_by_pattern(source_path, dest_path)


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
    parser.add_argument("-m", "--move", type=str_to_bool, default=False)
    args = vars(parser.parse_args())
    organize_files(**args)
