import inspect
from pathlib import Path
import os
import shlex
from test_base import *

current_file = Path(__file__).resolve()
parent_directory = current_file.parents[2]
os.sys.path.insert(0, str(parent_directory))

from ytdlp import download as ytdlp_download, get_options, read_json_file
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
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJV8C2TTbgguSByrLXKB_0WY",
    "https://www.youtube.com/playlist?list=PL4-sEuX-6HJWpbDV-SbyGUVIql65KlEhl",
]

video_urls = [
    "https://www.youtube.com/watch?v=j17yEgxPwkk",
    "https://youtu.be/j17yEgxPwkk?si=mV_z1hW6oZRkvzvh",
    "https://youtu.be/tPEE9ZwTmy0?si=CvPXvCucN4ST-fcN",
]

downloader = default_downloaders[0]
scripts_dir = os.path.dirname(os.getcwd())

video_options_1 = os.path.join(scripts_dir, "video_options.json")
video_options_2 = os.path.join(scripts_dir, "video_options_2.json")
video_options_3 = os.path.join(scripts_dir, "video_options_3.json")
wget_options = os.path.join(scripts_dir, "wget_options.json")

pp = PrettyPrinter(indent=2)

# global vars
downloader_path = video_options_1
downloader_type = "ytdlp_audio"
module = "ytdlp"
func = "download"
downloader_args = "url, downloader_path, update_options=False"


class TestDownloader(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_parse_download_string(self):
        downloads_path = "downloads.txt"
        self.assertTrue(os.path.exists(downloads_path), "Missing downloads.txt file")

        with open(downloads_path, "r") as file:
            for line in file:
                line = line.strip()
                if not line:
                    continue

                download = Download.parse_download_string(line)

                self.assertIsNotNone(download, f"Failed to parse line: {line}")
                self.assertIsNotNone(download.url, f"No URL found in line: {line}")
                self.assertIn(
                    download.url,
                    line,
                    f"Parsed URL not in original line: {download.url}",
                )
                print("URL:", download.url)
                # Extract expected downloader directly from the line
                expected_downloader = None
                for part in shlex.split(line):
                    part.strip()
                    if not part.startswith(
                        ("http://", "https://")
                    ) and not part.startswith('"'):
                        expected_downloader = part
                        break

                if download.downloader:
                    print(download.downloader)
                    self.assertTrue(
                        str(download.downloader).strip() == expected_downloader.strip(),
                        f"Expected downloader '{expected_downloader}', got '{download.downloader}' from line: {line}",
                    )

                self.assertIsNotNone(
                    download.output_directory,
                    f"Output directory should not be None for: {line}",
                )

                if download.output_filename:
                    expected_path = os.path.join(
                        download.output_directory, download.output_filename
                    )
                    self.assertEqual(
                        download.output_path,
                        expected_path,
                        f"Expected output path {expected_path}, got {download.output_path}",
                    )

    def test_get_downloader_func(self):
        downloader = Downloader("ytdlp_video", video_options_1, "ytdlp", "download")
        func = downloader.get_function()
        self.assertTrue(ytdlp_download == func)
        print(func, ytdlp_download)

    def test_get_downloader_args(self):
        downloader_args = (
            "url, downloads_path, output_directory=red, ytdlp_format=ytdl, yolo"
        )
        downloader = Downloader(
            downloader_type, downloader_path, module, func, downloader_args
        )
        download = Download(
            url=playlist_urls[0], downloader=downloader, downloads_path=video_options_1
        )
        downloader_args = downloader.get_downloader_args(download, ytdlp_download)

        print(downloader_args)

    def test_downloaders_cmd_list(self):
        downloaders = downloaders_cmd(
            action="list", downloader_type="ytdlp_video", downloader_path=""
        )  # returns all downloaders of type

        for downloader in downloaders:
            print(downloader.downloader_type, downloader.downloader_path)
            self.assertTrue(downloader.downloader_type == "ytdlp_video")

        downloaders = downloaders_cmd(action="list")  # this selects all of them
        all_downloaders = Downloader().select_all()

        for d, a in zip(downloaders, all_downloaders):
            # print(d, a)
            self.assertTrue(isinstance(d, Downloader))
            self.assertTrue(isinstance(a, Downloader))
            self.assertTrue(d.downloader_path == a.downloader_path)

        # self.assertCountEqual(downloaders, all_downloaders)

    def test_downloaders_cmd_add(self):
        # downloaders = downloaders_cmd(action="add", downloader_type="ytdlp_video")
        downloaders = downloaders_cmd(
            action="add",
            downloader_type="ytdlp_video",
            downloader_path=video_options_2,
            module="ytdlp",
            func="download",
            downloader_args="",
        )

    def test_download_all_cmd(self):
        urls = playlist_urls
        downloader_type = "ytdlp_video"
        downloads_path = "downloads.txt"
        output_directory = None
        output_filename = None

        downloads = download_all_cmd(
            urls, downloader_type, downloads_path, output_directory, output_filename
        )

        for download in downloads:
            download: Download
            self.assertTrue(isinstance(download, Download))

        if downloads_path is None:
            self.assertTrue(len(downloads) == len(urls))


if __name__ == "__main__":
    test_methods = [
        # TestDownloader.test_parse_download_string,
        # TestDownloader.test_get_downloader_func,
        TestDownloader.test_get_downloader_args,
        # TestDownloader.test_download_all_cmd,
        # TestDownloader.test_downloaders_cmd_list,
        # TestDownloader.test_downloaders_cmd_add,
    ]
    run_test_methods(test_methods)
