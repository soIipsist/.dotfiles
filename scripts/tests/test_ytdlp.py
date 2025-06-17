from pathlib import Path
import os

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import extract_video_info


class TestYtdlp(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_extract_video_info(self):
        print("hi")

    def test_download_playlist_urls(self):
        pass

    def test_download_regular_urls(self):
        pass


if __name__ == "__main__":
    test_methods = [
        TestYtdlp.test_extract_video_info,
        TestYtdlp.test_download_playlist_urls,
        TestYtdlp.test_download_regular_urls,
    ]
    run_test_methods(test_methods)
