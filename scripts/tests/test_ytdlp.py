from pathlib import Path
import os

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download, get_options, read_json_file

# playlist_urls = [
#     "https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ"
# ]
playlist_urls = [
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJV8C2TTbgguSByrLXKB_0WY"
]
options_path = os.path.join(os.path.dirname(os.getcwd()), "video_options.json")
print(options_path)
pp = PrettyPrinter(indent=2)


class TestYtdlp(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_get_options(self):
        # update options is false
        options = get_options(options_path, update_options=False)
        options_data = read_json_file(options_path)
        self.assertTrue(options == options_data)

        # update options is True
        options = get_options(options_path, update_options=True)
        options_data = read_json_file(options_path)
        self.assertTrue(options != options_data)
        print(options)
        print(options_data)

    def test_download_playlist_urls_no_options(self):
        # single url
        all_entries, error_entries = download(urls=playlist_urls)
        self.assertTrue(error_entries == [])

        for entry in all_entries:
            print(entry.get("webpage_url"))
            self.assertTrue(entry is not None)
        # self.assertTrue()

    def test_download_playlist_urls_with_base_options(self):
        options = get_options(options_path=options_path)
        print(options)
        all_entries, error_entries = download(playlist_urls, options)

    def test_download_regular_urls(self):
        pass


if __name__ == "__main__":
    test_methods = [
        TestYtdlp.test_get_options,
        # TestYtdlp.test_download_playlist_urls_no_options,
        # TestYtdlp.test_download_regular_urls,
    ]
    run_test_methods(test_methods)
