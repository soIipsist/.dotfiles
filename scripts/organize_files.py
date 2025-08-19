import os
import re
import sys
import shutil
import subprocess
from pathlib import Path
from datetime import datetime
from argparse import ArgumentParser
import mimetypes
from logger import setup_logger

logger = setup_logger("organize")


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


def create_backup(
    source_directory: Path, backup_directory: str = None, dry_run: bool = False
):

    dest = None

    if not backup_directory:
        return

    try:
        logger.info(f"Creating backup at {backup_directory}")

        if not dry_run:
            dest = shutil.copytree(
                source_directory, backup_directory, dirs_exist_ok=True
            )
            logger.info(f"Successfully created backup {dest}.")

    except Exception as e:
        logger.error(f"Exception: {e}")

    return dest


def get_directory_as_path(directory: str):
    if isinstance(directory, str):
        directory = Path(directory)

    if not directory.is_dir():
        logger.error(f"Error: '{directory}' is not a directory.")
        sys.exit(1)

    return directory


def move_files(old_files: list, new_files: list, move: bool, dry_run: bool):

    for old_file, new_file in zip(old_files, new_files):
        action = "Moving" if move else "Copying"

        logger.info(f"{action} '{old_file}' -> '{new_file}'")

        if not dry_run:  # move only if dry run is false
            new_file.parent.mkdir(parents=True, exist_ok=True)  # ensure folder exists

            if move:
                shutil.move(old_file, new_file)
            else:
                shutil.copy2(old_file, new_file)

    return old_files, new_files


def organize_by_year(
    source_directory: Path, destination_directory: Path, dry_run: bool
):

    old_files = []
    new_files = []

    for file_path in source_directory.iterdir():
        if file_path.is_file():
            year = get_exif_year(file_path)
            if not year:
                year = get_modification_year(file_path)

            if not year:
                logger.error(f"Warning: Could not determine year for '{file_path}'")
                continue

            target_dir = destination_directory / year

            if not target_dir.exists() and not dry_run:
                logger.info(f"Created year directory {target_dir}.")
                target_dir.mkdir(parents=True, exist_ok=True)

            dest_path = target_dir / file_path.name
            old_files.append(file_path)
            new_files.append(dest_path)

    return old_files, new_files


def organize_by_pattern(
    source_directory: Path, destination_directory: Path, pattern: str, repl: str
):
    old_files = []
    new_files = []

    for file_path in source_directory.iterdir():
        if file_path.is_file():
            new_stem = re.sub(pattern, repl, file_path.stem, flags=re.IGNORECASE)
            new_name = f"{new_stem}{file_path.suffix}"
            dest_path = destination_directory / new_name

            old_files.append(file_path)
            new_files.append(dest_path)

    return old_files, new_files


def organize_files(
    source_directory: str,
    destination_directory: str = None,
    action: str = None,
    pattern: str = None,
    repl: str = None,
    move: bool = False,
    backup_directory: str = None,
    dry_run: bool = False,
):

    if not destination_directory:
        destination_directory = source_directory

    source_directory = get_directory_as_path(source_directory)
    destination_directory = get_directory_as_path(destination_directory)

    create_backup(source_directory, backup_directory, dry_run)

    new_files = []
    old_files = []

    if action == "year":
        old_files, new_files = organize_by_year(
            source_directory, destination_directory, dry_run
        )
    elif action == "episodes":
        pattern = r".*?(S\d{2}E\d{2}|\d{1,5}).*"  # pattern for episodes
        repl = r"\1"
        old_files, new_files = organize_by_pattern(
            source_directory, destination_directory, pattern, repl
        )
    elif action == "prefix":
        pattern = r"^(.*)$"

        if not repl:
            prefix = input("Prefix: ")
            if prefix:
                repl = f"{prefix}\\1"
            else:
                repl = r"\1"

        old_files, new_files = organize_by_pattern(
            source_directory, destination_directory, pattern, repl
        )
    elif action == "suffix":
        pattern = r"^(.*?)(\.[^.]+)?$"

        if not repl:
            suffix = input("Suffix: ")
            if suffix:
                repl = r"\1" + suffix + r"\2"
            else:
                repl = r"\1\2"

        old_files, new_files = organize_by_pattern(
            source_directory, destination_directory, pattern, repl
        )
    else:
        old_files, new_files = organize_by_pattern(
            source_directory, destination_directory, pattern, repl
        )

    move_files(old_files, new_files, move, dry_run)
    return old_files, new_files


def str_to_bool(string: str):
    return string in ["1", "true", True]


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("source_directory", type=str, default=os.getcwd(), nargs="?")
    parser.add_argument("destination_directory", default=None, nargs="?")
    parser.add_argument(
        "-a",
        "--action",
        type=str,
        default="episodes",
        choices=["pattern", "episodes", "prefix", "suffix", "year"],
    )
    parser.add_argument("-p", "--pattern", type=str, default=None)
    parser.add_argument("-r", "--repl", type=str, default=None)
    parser.add_argument(
        "-m", "--move", type=str_to_bool, default=os.environ.get("MOVE_FILES", False)
    )
    parser.add_argument(
        "-b", "--backup_directory", type=str, default=os.environ.get("BACKUP_DIRECTORY")
    )
    parser.add_argument(
        "-n", "--dry_run", type=str_to_bool, default=os.environ.get("DRY_RUN")
    )

    args = vars(parser.parse_args())
    organize_files(**args)

# python organize_files.py (uses cwd)
# python organize_files.py tests/photos/backup -a year
# python organize_files.py tests/photos/backup tests/photos/out -a year
# python organize_files.py tests/photos/backup tests/photos/out -a year -m 1
