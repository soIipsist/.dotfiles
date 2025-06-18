from pathlib import Path
import os

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download, get_options, read_json_file
from downloader import (
    Downloader,
    Download,
    download_all_cmd,
    downloaders_cmd,
    default_downloaders,
)

# playlist_urls = [
#     "https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ"
# ]
playlist_urls = [
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJV8C2TTbgguSByrLXKB_0WY"
]
video_urls = [
    "https://youtu.be/MvsAesQ-4zA?si=gDyPQcdb6sTLWipY"
    "https://youtu.be/OlEqHXRrcpc?si=4JAYOOH2B0A6MBvF"
]

downloader = default_downloaders[0]
scripts_dir = os.path.dirname(os.getcwd())
options_path = os.path.join(scripts_dir, "video_options.json")
print(options_path)
pp = PrettyPrinter(indent=2)


class TestDownloader(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_downloader(self):
        pass

    def test_parse_download_string(self):
        pass

    def test_get_downloader_func(self):
        downloader_path = os.path.join(scripts_dir, "video_options.json")
        downloader = Downloader("ytdlp_video", downloader_path, "")

        self.assertTrue(downloader.get_function("") == downloader.func)


if __name__ == "__main__":
    test_methods = [
        TestDownloader.test_downloader,
        TestDownloader.test_parse_download_string,
        # TestYtdlp.test_download_playlist_urls_no_options,
        # TestYtdlp.test_download_regular_urls,
    ]
    run_test_methods(test_methods)
