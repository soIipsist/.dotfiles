from pathlib import Path
import os

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download, get_options, read_json_file
from downloader import download_all_cmd

# playlist_urls = [
#     "https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ"
# ]
playlist_urls = [
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJV8C2TTbgguSByrLXKB_0WY"
]
options_path = os.path.join(os.path.dirname(os.getcwd()), "video_options.json")
print(options_path)
pp = PrettyPrinter(indent=2)


class TestDownloader(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_downloader(self):
        pass


if __name__ == "__main__":
    test_methods = [
        TestDownloader.test_get_options,
        # TestYtdlp.test_download_playlist_urls_no_options,
        # TestYtdlp.test_download_regular_urls,
    ]
    run_test_methods(test_methods)
