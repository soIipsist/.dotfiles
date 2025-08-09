from scripts.tests.test_base import TestBase, run_test_methods
from scripts.organize_files import *
import os

videos_directory = os.path.join(os.getcwd(), "videos")
photos_directory = os.path.join(os.getcwd(), "photos")


class TestOrganize(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_get_exif_year(self):
        get_exif_year()

    def test_get_modification_year(self):
        pass

    def test_organize_by_pattern(self):
        pass

    def test_organize_by_year(self):
        pass


if __name__ == "__main__":
    test_methods = [
        TestOrganize.test_get_exif_year,
        TestOrganize.test_get_modification_year,
        # TestOrganize.test_organize_by_pattern,
        # TestOrganize.test_organize_by_year,
    ]
    run_test_methods(test_methods)
