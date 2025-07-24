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


def main(source_directory: str, destination_directory: str = None):
    source_path = Path(source_directory)
    dest_path = Path(destination_directory) if destination_directory else source_path

    if not source_path.is_dir():
        print(f"Error: Source directory '{source_path}' is not a directory.")
        sys.exit(1)

    for file_path in source_path.iterdir():
        if file_path.is_file():
            year = get_exif_year(file_path)
            if not year:
                year = get_modification_year(file_path)

            print("FILE PATH", file_path)
            print("YEAR", year)

            if not year:
                print(f"Warning: Could not determine year for '{file_path}'")
                continue

            target_dir = dest_path / year
            target_dir.mkdir(parents=True, exist_ok=True)

            shutil.copy2(file_path, target_dir)
            print(f"Copied '{file_path}' -> '{target_dir}/'")


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("source_directory", type=str)
    parser.add_argument("destination_directory", default=None, nargs="?")

    args = parser.parse_args()

    main(args.source_directory, args.destination_directory)
