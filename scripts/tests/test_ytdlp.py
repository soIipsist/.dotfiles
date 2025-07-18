from pathlib import Path
import os
from urllib.parse import parse_qs, urlparse

import yt_dlp

from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import (
    download,
    get_options,
    get_urls,
    read_json_file,
    get_video_format,
    get_ytdlp_format,
    get_outtmpl,
    get_entry_filename,
    get_entry_url,
)

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


# global vars
options_path = video_options_1
update_options = False
output_directory = os.path.join(os.getcwd(), "videos")
ytdlp_format = "ytdlp_video"


class TestYtdlp(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def print_results(self, results: list):
        for idx, result in enumerate(results):
            entry_url = result.get("entry_url")
            original_url = result.get("original_url")
            error = result.get("error")
            print("ENTRY URL", entry_url)
            print("ORIGINAL URL", original_url)
            print("ERROR", error)

            self.assertIsNotNone(entry_url, f"entry at index: {idx}!")
            self.assertIsNotNone(original_url, f"entry at index: {idx}!")
            self.assertIsNone(error, f"entry at index: {idx}!")

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
        # urls = playlist_urls[0]
        urls = playlist_urls

        results = download(
            urls=urls,
            options_path=options_path,
            update_options=update_options,
            output_directory=output_directory,
        )
        self.print_results(results)

    def test_download_regular_urls(self):
        output_directory = os.path.join(os.getcwd(), "videos")
        urls = video_urls
        results = download(
            urls=urls,
            options_path=options_path,
            update_options=update_options,
            output_directory=output_directory,
        )
        self.print_results(results)
        self.assertTrue(len(results) == len(urls))

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

    def test_get_video_format(self):
        options = get_options(video_options_blank)  # "format" may or may not be in here
        ytdlp_format = "ytdlp_audio"
        custom_format = None

        video_format = get_video_format(options, ytdlp_format, custom_format)

        expected_format = custom_format or (
            "bestaudio/best"
            if ytdlp_format == "ytdlp_audio" and not options.get("format")
            else (
                "bestvideo+bestaudio"
                if ytdlp_format == "ytdlp_video" and not options.get("format")
                else options.get("format")
            )
        )

        self.assertEqual(video_format, expected_format)
        print("VIDEO FORMAT:", video_format)

    def test_get_ytdlp_format(self):

        ytdlp_format = "~/Users/p/Desktop/music.txt"
        output = get_ytdlp_format(ytdlp_format)

        file_formats = {
            "music": "ytdlp_audio",
            "mp3": "ytdlp_audio",
        }
        valid_formats = ["ytdlp_video", "ytdlp_audio"]

        if ytdlp_format.endswith(".txt"):
            ytdlp_format = os.path.basename(ytdlp_format.removesuffix(".txt"))

        if ytdlp_format in file_formats:
            self.assertTrue(output == file_formats.get(ytdlp_format))
        elif ytdlp_format in valid_formats:
            self.assertTrue(output == ytdlp_format)
        else:
            self.assertTrue(output == "ytdlp_video")
        print("YTDLP FORMAT", output)

    def test_get_outtmpl(self):
        options = get_options(options_path)
        prefix = "yolo - "
        output_directory = os.getcwd()
        output_filename = None
        outtmpl = get_outtmpl(
            options, ytdlp_format, prefix, output_directory, output_filename
        )

        expected = options.get("outtmpl", "%(title)s.%(ext)s")

        if prefix:
            expected = (
                os.path.join(output_directory, prefix) if output_directory else prefix
            )
            self.assertTrue(outtmpl.startswith(expected))
        else:
            if output_directory:
                expected = os.path.join(output_directory, expected)
            self.assertEqual(outtmpl, expected)

        print(outtmpl)

    def test_get_entry_filename(self):
        url = video_urls[0]
        options = read_json_file(options_path)

        filename = None
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                info = ytdl.extract_info(url, download=False)

                filename = get_entry_filename(info)
                title = info.get("title")
                ext = info.get("ext", "mp4")
                if title:
                    self.assertIsNotNone(filename)
                    self.assertTrue(f"{title}.{ext}" == filename)

        except Exception as e:
            print(e)

        print("FILENAME:", filename)

    def test_get_entry_url(self):
        url = video_urls[0]
        options = read_json_file(options_path)

        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                info = ytdl.extract_info(url, download=False)
                is_playlist = info.get("entries") is not None
                entries = info.get("entries") if is_playlist else [info]

                for entry in entries:
                    entry_url = get_entry_url(url, info, is_playlist)

                    if not is_playlist:
                        print("NOT PLAYLIST")
                        self.assertTrue(entry_url == url)
                    else:
                        print("PLAYLIST")

        except Exception as e:
            print(e)


if __name__ == "__main__":
    test_methods = [
        # TestYtdlp.test_get_options,
        # TestYtdlp.test_download_playlist_urls,
        # TestYtdlp.test_download_regular_urls,
        # TestYtdlp.test_get_urls,
        # TestYtdlp.test_get_video_format,
        # TestYtdlp.test_get_ytdlp_format,
        # TestYtdlp.test_get_outtmpl,
        # TestYtdlp.test_get_entry_filename,
        TestYtdlp.test_get_entry_url,
    ]
    run_test_methods(test_methods)
