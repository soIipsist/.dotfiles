import inspect
from pathlib import Path
import os
import shlex
import shutil
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
wget_urls = [
    "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/ChessSet.jpg/640px-ChessSet.jpg"
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
# downloads_path = "downloads.txt"
downloads_path = None
downloader_type = "ytdlp_audio"
module = "ytdlp"
func = "download"
downloader_args = "url, downloader_path, update_options=False"
output_directory = os.path.join(os.getcwd(), "videos")
# output_directory = None
output_filename = "yolo"


class TestDownloader(TestBase):
    def setUp(self) -> None:
        super().setUp()
        if os.path.exists(output_directory):
            shutil.rmtree(output_directory)
        # os.remove(os.path.dirname(os.getcwd(), "downloads.db"))

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
        downloader_args = "url, downloads_path, output_directory=red, ytdlp_format=ytdl, update_options=url"
        downloader = Downloader(
            downloader_type, downloader_path, module, func, downloader_args
        )
        download = Download(
            url=playlist_urls[0], downloader=downloader, downloads_path=video_options_1
        )
        output_downloader_args = downloader.get_downloader_args(
            download, ytdlp_download
        )
        func_params = inspect.signature(ytdlp_download).parameters
        downloader_args = downloader_args.split(",")

        for arg in downloader_args:
            arg = arg.strip()
            if "=" in arg:
                k, v = arg.split("=")
                self.assertTrue(k in func_params)
                print(k, output_downloader_args.get(k), v)
                value = getattr(download, v, v)
                self.assertTrue(output_downloader_args.get(k) == value)
            else:
                # positional arg
                value = getattr(download, arg, arg)

    def test_start_downloads(self):
        downloads = [
            # Download(
            #     playlist_urls[1], "ytdlp_video", output_directory=output_directory
            # ),
            Download(wget_urls[0], "wget", output_directory=output_directory),
            # Download(
            #     wget_urls[0],
            #     "urllib",
            #     output_directory=output_directory,
            #     output_filename=output_filename,
            # ),
        ]
        download_results = Downloader.start_downloads(downloads)

        print("DOWNLOAD RESULTS")
        print(len(download_results))
        # pp.pprint(download_results)


if __name__ == "__main__":
    test_methods = [
        # TestDownloader.test_parse_download_string,
        # TestDownloader.test_get_downloader_func,
        # TestDownloader.test_get_downloader_args,
        TestDownloader.test_start_downloads,
    ]
    run_test_methods(test_methods)
