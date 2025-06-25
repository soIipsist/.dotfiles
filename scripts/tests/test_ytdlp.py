from pathlib import Path
import os
from urllib.parse import parse_qs, urlparse

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download, get_options, get_urls, read_json_file

# playlist_urls = [
#     "https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ"
# ]
playlist_urls = [
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJV8C2TTbgguSByrLXKB_0WY",
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJWpbDV-SbyGUVIql65KlEhl",
]

video_urls = [
    "https://www.youtube.com/watch?v=j17yEgxPwkk",
    "https://youtu.be/j17yEgxPwkk?si=mV_z1hW6oZRkvzvh",
    "https://youtu.be/tPEE9ZwTmy0?si=CvPXvCucN4ST-fcN",
]

scripts_dir = os.path.dirname(os.getcwd())
video_options_1 = os.path.join(scripts_dir, "video_options.json")
video_options_2 = os.path.join(scripts_dir, "video_options_2.json")
video_options_3 = os.path.join(scripts_dir, "video_options_3.json")
video_options_blank = os.path.join(scripts_dir, "video_options_blank.json")
pp = PrettyPrinter(indent=2)


class TestYtdlp(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def print_results(self, results: list):
        for result in results:
            entry_url = result.get("entry_url")
            original_url = result.get("original_url")
            print("ENTRY URL", entry_url)
            print("ORIGINAL URL", original_url)

    def test_get_options(self):
        # update options is false
        options = get_options(video_options_blank, update_options=False)
        options_data = read_json_file(video_options_blank)
        self.assertTrue(options == options_data)

        # update options is True
        options = get_options(video_options_blank, update_options=True)
        options_data = read_json_file(video_options_blank)
        self.assertTrue(options != options_data)
        pp.pprint(options)
        pp.pprint(options_data)

    def test_download_playlist_urls(self):
        results = download(urls=playlist_urls[0])
        self.print_results(results)

    def test_download_regular_urls(self):
        results = download(urls=video_urls[0])
        self.print_results(results)

    def test_get_urls(self):
        urls = [
            "https://www.youtube.com/watch?v=j17yEgxPwkk",
            "https://www.youtube.com/playlist?list=PL4-sEuX-6HJWpbDV-SbyGUVIql65KlEhl",
        ]
        removed_args = ["list"]

        new_urls = get_urls(urls, removed_args)

        for url in new_urls:
            print(url)
            parsed = urlparse(url)
            query_params = parse_qs(parsed.query)

            for arg in removed_args:
                self.assertNotIn(arg, query_params, f"{arg} was found in {url}")


if __name__ == "__main__":
    test_methods = [
        # TestYtdlp.test_get_options,
        # TestYtdlp.test_download_playlist_urls,
        # TestYtdlp.test_download_regular_urls,
        TestYtdlp.test_get_urls
    ]
    run_test_methods(test_methods)
