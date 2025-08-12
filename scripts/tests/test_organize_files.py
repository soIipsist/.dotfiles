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


videos_directory = os.path.join(os.getcwd(), "videos")
photos_directory = os.path.join(os.getcwd(), "photos")
out_directory = os.path.join(photos_directory, "out")

source_directory = photos_directory
destination_directory = out_directory

if not destination_directory:
    destination_directory = source_directory

source_directory = get_directory_as_path_test(source_directory)
destination_directory = get_directory_as_path_test(destination_directory)
move = False
backup_directory = "/tmp"


class TestOrganize(TestBase):
    def setUp(self) -> None:
        super().setUp()

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
        backup_path = create_backup(source_directory, backup_directory)

        if backup_directory is None:
            self.assertTrue(backup_path is None)
        else:
            self.assertIsNotNone(backup_path)

    def test_organize_by_year(self):
        organize_by_year(source_directory, destination_directory)

    def test_organize_by_pattern(self):

        action = "pattern"

        # pattern for music
        pattern = r"^(.*)$"
        repl = r"Linkin Park - \1"

        new_files = organize_files(
            source_directory, destination_directory, action, pattern, repl, move
        )

    def test_organize_episodes(self):
        action = "episodes"

    def test_organize_music(self):
        action = "music"


if __name__ == "__main__":
    test_methods = [
        # TestOrganize.test_get_exif_year,
        # TestOrganize.test_get_modification_year,
        # TestOrganize.test_create_backup,
        TestOrganize.test_organize_by_pattern,
        # TestOrganize.test_organize_by_year,
    ]
    run_test_methods(test_methods)
