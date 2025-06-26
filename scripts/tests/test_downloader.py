import inspect
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


class TestDownloader(TestBase):
    def setUp(self) -> None:
        super().setUp()

    def test_parse_download_string(self):
        downloads_path = "downloads.txt"
        self.assertTrue(os.path.exists(downloads_path))

        with open(downloads_path, "r") as file:
            for line in file:
                print(line)
                download = Download.parse_download_string(line)

                if not download:
                    continue

                self.assertTrue(download.url in line)  # check url
                self.assertTrue(download.output_directory is not None)

                if download.output_filename:
                    self.assertTrue(
                        download.output_path
                        == os.path.join(
                            download.output_directory, download.output_filename
                        )
                    )

    def test_get_downloader_func(self):
        downloader = Downloader("ytdlp_video", video_options_1, "ytdlp", "download")

        func = downloader.get_function()
        self.assertTrue(download == func)
        print(func, download)

    def test_get_downloader_args_with_no_values(self):
        downloader = Downloader("ytdlp_video", video_options_1, "ytdlp", "download")
        d = Download(url=playlist_urls[0], downloader=downloader)
        downloader_args = downloader.get_downloader_args(d, download)

        print(downloader_args)

    def test_get_downloader_args(self):
        downloader_type = "ytdlp_video"
        downloader_path = video_options_1
        module = "ytdlp"
        func = "download"
        downloader_args = "url, downloads_path"
        downloader = Downloader(
            downloader_type, downloader_path, module, func, downloader_args
        )
        d = Download(
            url=playlist_urls[0], downloader=downloader, downloads_path=video_options_1
        )
        downloader_args = downloader.get_downloader_args(
            d,
            download,
        )

        self.assertTrue(
            len(downloader_args) == len(inspect.signature(download).parameters)
        )

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
        TestDownloader.test_parse_download_string,
        # TestDownloader.test_get_downloader_func,
        # TestDownloader.test_get_downloader_args,
        # TestDownloader.test_download_all_cmd,
        # TestDownloader.test_downloaders_cmd_list,
        # TestDownloader.test_downloaders_cmd_add,
        # TestDownloader.test_get_downloader_args_with_no_values,
    ]
    run_test_methods(test_methods)
