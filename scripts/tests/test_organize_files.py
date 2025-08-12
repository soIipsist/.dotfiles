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


def get_directory_as_path_test(self, directory: str):
    if isinstance(directory, str):
        directory = Path(directory)

    return directory


videos_directory = os.path.join(os.getcwd(), "videos")
photos_directory = os.path.join(os.getcwd(), "photos")

source_directory = photos_directory
destination_directory = os.path.join(
    "~",
)
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
        backup_directory = "/Users/p/Desktop"
        backup_path = create_backup(source_directory, backup_directory)

        if backup_directory is None:
            self.assertTrue(backup_path is None)
        else:
            self.assertIsNotNone(backup_path)

    def test_organize_by_pattern(self):

        organize_by_pattern()

    def test_organize_by_year(self):
        pass


if __name__ == "__main__":
    test_methods = [
        # TestOrganize.test_get_exif_year,
        # TestOrganize.test_get_modification_year,
        TestOrganize.test_create_backup,
        # TestOrganize.test_organize_by_pattern,
        # TestOrganize.test_organize_by_year,
    ]
    run_test_methods(test_methods)
