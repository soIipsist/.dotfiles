from pathlib import Path
import os

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download

playlist_urls = [
    "https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ"
]


class TestYtdlp(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_download_playlist_urls(self):
        pass

    def test_download_regular_urls(self):
        pass


if __name__ == "__main__":
    test_methods = [
        TestYtdlp.test_download_playlist_urls,
        TestYtdlp.test_download_regular_urls,
    ]
    run_test_methods(test_methods)
