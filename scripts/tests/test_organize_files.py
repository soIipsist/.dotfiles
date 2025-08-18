import inspect
from pathlib import Path
import os
import random
import shlex
import shutil
from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from scripts.tests.test_base import TestBase, run_test_methods
from scripts.organize_files import *
import os


def get_directory_as_path_test(directory: str):
    if isinstance(directory, str):
        directory = Path(directory)

    return directory


def delete_dir_contents(directory: Path):
    if isinstance(directory, str):
        directory = Path(directory)

    for item in directory.iterdir():
        if item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()


def copy_dir_contents(src: Path, dst: Path):
    if isinstance(src, str):
        src = Path(src)
    if isinstance(dst, str):
        dst = Path(dst)

    if not src.is_dir():
        raise NotADirectoryError(f"Source is not a directory: {src}")
    dst.mkdir(parents=True, exist_ok=True)

    for item in src.iterdir():
        target = dst / item.name
        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
        else:
            shutil.copy2(item, target)


videos_directory = os.path.join(os.getcwd(), "videos")
photos_directory = os.path.join(os.getcwd(), "photos")
out_directory = os.path.join(photos_directory, "out")

source_directory = photos_directory
destination_directory = out_directory

if not destination_directory:
    destination_directory = source_directory

source_directory = get_directory_as_path_test(source_directory)
destination_directory = get_directory_as_path_test(destination_directory)
backup_directory = os.path.join(photos_directory, "backup")
move = True
dry_run = True
pattern = r"^(.*)$"
repl = r"\1"


class TestOrganize(TestBase):
    def setUp(self) -> None:
        super().setUp()
        # empty output directory
        delete_dir_contents(out_directory)

        # move the files from backup to photo dir
        copy_dir_contents(backup_directory, photos_directory)

    def get_random_path(self, directory: str = photos_directory):
        all_paths = []

        for root, dirs, files in os.walk(directory):
            for name in files:
                all_paths.append(os.path.join(root, name))

        if not all_paths:
            return None  # No files or dirs found

        return random.choice(all_paths)

    def test_get_exif_year(self):
        file_path = self.get_random_path()
        print(file_path)
        year = get_exif_year(file_path)
        print(year)
        self.assertTrue(len(year) == 4)

    def test_get_modification_year(self):
        file_path = self.get_random_path()
        print(file_path)
        year = get_modification_year(file_path)
        print(year)
        self.assertTrue(len(year) == 4)

    def test_create_backup(self):

        source_directory = photos_directory
        backup_directory = "/tmp/photos"
        backup_path = create_backup(source_directory, backup_directory, dry_run)

        if backup_directory is None:
            self.assertTrue(backup_path is None)
        else:
            if not dry_run:
                self.assertTrue(os.path.exists(backup_path))

    def test_move_files(self):
        old_files, new_files = organize_by_pattern(
            source_directory, destination_directory, pattern, repl
        )
        old_files, new_files = move_files(old_files, new_files, move, dry_run)

        for old_file, new_file in zip(old_files, new_files):

            if dry_run:
                self.assertTrue(os.path.exists(old_file))
            else:
                if move:
                    self.assertFalse(os.path.exists(old_file))
                else:
                    self.assertTrue(os.path.exists(old_file))
                    self.assertTrue(os.path.exists(new_file))

    def test_organize_files(self):
        action = "prefix"
        # action = "pattern"
        # action = "year"
        # action = "episodes"
        prefix = None
        pattern = None
        repl = None

        # try custom pattern
        if action == "pattern":
            pattern = r"^(.*)$"
            prefix = "Linkin Park -"
            repl = f"{prefix} \\1"

        old_files, new_files = organize_files(
            source_directory,
            destination_directory,
            action,
            pattern,
            repl,
            move,
            backup_directory,
            dry_run,
        )

        self.assertTrue(os.path.exists(source_directory))
        self.assertTrue(os.path.exists(destination_directory))
        self.assertTrue(len(old_files) == len(new_files))

        for old_file, new_file in zip(old_files, new_files):

            if isinstance(new_file, Path):
                new_file = str(new_file)

            self.assertTrue(os.path.exists(new_file))

            if (action == "prefix" or action == "pattern") and prefix:
                print("Prefix", prefix)
                self.assertTrue(os.path.basename(new_file).startswith(prefix))

            if move:
                self.assertFalse(os.path.exists(old_file))
            else:
                self.assertTrue(os.path.exists(old_file))


if __name__ == "__main__":
    test_methods = [
        # TestOrganize.test_get_exif_year,
        # TestOrganize.test_get_modification_year,
        # TestOrganize.test_create_backup,
        # TestOrganize.test_move_files,
        TestOrganize.test_organize_files,
    ]
    run_test_methods(test_methods)
