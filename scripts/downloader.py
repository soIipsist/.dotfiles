import os
from pprint import PrettyPrinter
import sqlite3
import datetime
from enum import Enum
import sys
from typing import List, Optional
from sqlite import is_valid_path
from sqlite_item import SQLiteItem, create_connection
from sqlite_conn import create_db, download_values, downloader_values
from ytdlp import download as ytdlp_download, get_options, get_urls as get_ytdlp_urls
from wget import download as wget_download

import argparse
import subprocess

valid_formats = ["audio", "video"]
specific_format = None
script_directory = os.path.dirname(__file__)
pp = PrettyPrinter(indent=2)

database_path = os.environ.get(
    "DOWNLOADS_DB_PATH", os.path.join(script_directory, "downloads.db")
)

# create connection and tables
db = create_connection(database_path)
db_exists = os.path.exists(database_path)
create_db(database_path)


class DownloadStatus(str, Enum):
    STARTED = "started"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Downloader(SQLiteItem):
    _name: str = None
    _downloader_format: str = None
    _downloader_path: str = None

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def downloader_format(self):
        return self._downloader_format

    @downloader_format.setter
    def downloader_format(self, downloader_format):
        self._downloader_format = downloader_format

    @property
    def downloader_path(self):
        return self._downloader_path

    @downloader_path.setter
    def downloader_path(self, downloader_path):
        self._downloader_path = downloader_path

    def __init__(
        self,
        name: str = None,
        downloader_format: str = None,
        downloader_path: str = None,
    ):
        column_names = [
            "name",
            "downloader_format",
            "downloader_path",
        ]

        super().__init__(downloader_values, column_names, db_path=database_path)
        self.name = name
        self.downloader_format = downloader_format
        self.downloader_path = downloader_path
        self.conjunction_type = "OR"
        self.filter_condition = f"name = {self._name}"
        self.table_name = "downloaders"

    def __repr__(self):
        return f"<Downloader({self.name}, {self.downloader_format}, {self.downloader_path})>"

    def __str__(self):
        return f"<Downloader({self.name}, {self.downloader_format}, {self.downloader_path})>"


default_downloaders = [
    Downloader("ytdlp", "video", os.path.join(script_directory, "video_options.json")),
    Downloader(
        "ytdlp_audio", "audio", os.path.join(script_directory, "audio_options.json")
    ),
    Downloader("wget", "wget", os.path.join(script_directory, "wget_options.json")),
]

if not db_exists:
    Downloader.insert_all(default_downloaders)


class Download(SQLiteItem):
    _downloader = None
    _download_status = DownloadStatus.STARTED
    _start_date = str(datetime.datetime.now())
    _url: str = None
    _download_str: str = None
    _downloads_path: str = None
    _db: sqlite3.Connection = None
    _output_directory: str = None

    def __init__(
        self,
        url: str = None,
        downloader: Downloader = None,
        download_status: DownloadStatus = DownloadStatus.STARTED,
        start_date: str = None,
        downloads_path: Optional[str] = None,
        output_directory: Optional[str] = None,
    ):
        column_names = [
            "url",
            "downloader",
            "download_status",
            "start_date",
        ]
        super().__init__(download_values, column_names, db_path=database_path)
        self.url = url
        self.downloader = downloader
        self.download_status = download_status
        self.downloads_path = downloads_path
        self.output_directory = output_directory
        self.start_date = start_date

        self.table_name = "downloads"
        self.conjunction_type = "OR"
        self.filter_condition = f"url = {self.url}"

    @property
    def download_status(self):
        return self._download_status

    @download_status.setter
    def download_status(self, download_status):
        self._download_status = download_status

    @property
    def output_directory(self):
        return self._output_directory

    @output_directory.setter
    def output_directory(self, output_directory):
        self._output_directory = output_directory

    @property
    def start_date(self):
        return self._start_date

    @start_date.setter
    def start_date(self, start_date):
        if start_date is None:
            start_date = str(datetime.datetime.now())
        self._start_date = start_date

    @property
    def ytdlp_options_path(self):
        return self._get_ytdlp_options_path()

    @property
    def downloads_path(self):
        return self._downloads_path

    @downloads_path.setter
    def downloads_path(self, downloads_path: str):
        self._downloads_path = downloads_path

    @property
    def url(self):
        return self._url

    @url.setter
    def url(self, url: str):
        self._url = url

    @property
    def downloader(self):
        return self._downloader

    @downloader.setter
    def downloader(self, downloader: Downloader):
        self._downloader = downloader

    def start_download_query(self):
        self.insert()

    def set_download_status_query(self, status: DownloadStatus):
        self.download_status = status
        self.update()

    def start_download(self):

        if self.output_directory:
            os.makedirs(self.output_directory, exist_ok=True)

        self.start_ytldp_download()
        self.start_wget_download()

    def start_wget_download(self):
        if not self.downloader == "wget":
            return

        self.start_download_query()
        status_code = wget_download(self.url, self.output_directory)

        if status_code == 1:
            self.set_download_status_query(DownloadStatus.INTERRUPTED)
        else:
            self.set_download_status_query(DownloadStatus.COMPLETED)

    def start_ytldp_download(self):
        downloaders = Downloader().select_all()

        if not self.downloader in downloaders:
            return

        print("Downloading with ytdlp...")

        status_code = 0
        ytdlp_format = self._get_ytdlp_format()
        ytdlp_options = get_options(
            ytdlp_format,
            output_directory=self.output_directory,
            options_path=self.ytdlp_options_path,
        )

        try:
            self.start_download_query()
            urls = get_ytdlp_urls([self.url], removed_args=None)
            ytdlp_download(urls, ytdlp_options)
        except KeyboardInterrupt:
            print("\nDownload interrupted by user.")
            status_code = 1

        except subprocess.CalledProcessError as e:
            print(f"\nDownload failed: {e}")
            status_code = 1

        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            status_code = 1

        if status_code == 1:
            self.set_download_status_query(DownloadStatus.INTERRUPTED)
        else:
            self.set_download_status_query(DownloadStatus.COMPLETED)

    def _get_ytdlp_options_path(self):
        options = self.downloader.downloader_path
        options_path = os.path.join(script_directory, options)
        return options_path

    def _get_ytdlp_format(self):

        # choose different format based on path name
        if not self.downloads_path:
            return "video"

        path_name = os.path.basename(self.downloads_path).removesuffix(".txt")
        formats = {"music": "audio", "mp3": "audio", "videos": "video"}
        format = formats.get(path_name)

        if format:
            default_video_downloader = os.environ.get("VIDEO_DOWNLOADER", "ytdlp")
            default_audio_downloader = os.environ.get("YTDLP_DOWNLOADER", "ytdlp_audio")

            # set downloader again, if format was found
            self.downloader = (
                default_video_downloader
                if format == "video"
                else default_audio_downloader
            )
        else:
            format = self.downloader.downloader_format
        return format

    def fetch_downloads(self):
        return self.select_all()

    def __repr__(self):
        return f"{self.downloader}, {self.url}"

    def __str__(self):
        return f"{self.downloader}, {self.url}"

    @classmethod
    def parse_download_string(cls, downloads_path: str):
        pass


def start_downloads(
    url: str = None,
    downloader_type: str = "ytdlp",
    downloads_path: str = None,
    output_directory: str = None,
    **kwargs,
):
    downloads = []

    if not url and not downloads_path:
        raise ValueError("Either url or downloads path must be defined.")

    # get downloader based on type
    downloader = Downloader(name=downloader_type).select()

    if not downloader:
        raise ValueError(f"Downloader of type '{downloader_type}' does not exist.")

    # create download string
    if not os.path.exists(downloads_path):
        prompt = (
            input(f"{downloads_path} does not exist. Create it? (y/N): ")
            .strip()
            .lower()
        )
        if prompt == "y":
            # os.makedirs(os.path.dirname(downloads_path), exist_ok=True)
            with open(downloads_path, "w") as f:
                pass  # creates an empty file
            print(f"Created file: {downloads_path}")
        else:
            print("File was not created.")

    if downloads_path is not None:
        with open(downloads_path, "r") as file:
            for line in file:
                download_str = line.strip()
                if not download_str:
                    continue

                download_str = download_str.split(" ")

                print("DOWNLOAD STR", download_str)

                url = download_str[0]

                downloader = download_str[1] if len(download_str) > 1 else downloader

                if not downloader:
                    downloader = Downloader().select_first()

                if not downloads_path:
                    return

                download = Download(
                    url,
                    downloader,
                    downloads_path=downloads_path,
                    output_directory=output_directory,
                )
                downloads.append(download)

                # string can be of this format
        # {some_url} -> stored in a music.txt, will use default audio downloader
        # or
        # {some_url} {downloader} -> stored in a downloads.txt, will use default video downloader

    for download in downloads:
        download: Download
        print(download)
        # download.start_download()


# argparse commands


def downloaders_cmd(**kwargs):
    print(kwargs)

    action = kwargs.get("action")
    kwargs.pop("action")
    d = Downloader(**kwargs)

    if action == "add":
        d.insert()
    else:  # list downloaders
        downloaders = d.filter_by(d.column_names)
        pp.pprint(downloaders)


def download_all_cmd(**kwargs):
    print(kwargs)
    downloader_type = kwargs.get("downloader_type")
    downloader = Downloader(name=downloader_type)
    d = downloader.filter_by(downloader.column_names)
    print("DOWNLOADER", d)

    kwargs.pop("downloader_type")
    download = Download(**kwargs, downloader=d)

    if kwargs.get("url") is None:
        downloads = download.filter_by(download.column_names)
        pp.pprint(downloads)
    else:
        start_downloads(**kwargs)


if __name__ == "__main__":
    # Check if the user skipped the subcommand, and inject 'download'
    if len(sys.argv) == 1 or sys.argv[1] not in [
        "download",
        "downloaders",
        "-h",
        "--help",
    ]:
        sys.argv.insert(1, "download")

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    # download cmd
    download_cmd = subparsers.add_parser("download", help="Download a URL")
    download_cmd.add_argument("url", type=str, nargs="?")
    download_cmd.add_argument(
        "-t", "--downloader_type", default=None, type=str, choices=["ytdlp"]
    )
    download_cmd.add_argument(
        "-d", "--downloads_path", default=os.environ.get("DOWNLOADS_PATH"), type=str
    )

    download_cmd.add_argument(
        "--download_status",
        type=DownloadStatus,
        default=None,
    )

    download_cmd.add_argument(
        "-o",
        "--output_directory",
        default=os.environ.get("DOWNLOADS_OUTPUT_DIR"),
        type=str,
    )
    download_cmd.set_defaults(func=download_all_cmd)

    # downloader cmd
    downloader_cmd = subparsers.add_parser("downloaders", help="List downloaders")
    downloader_cmd.add_argument(
        "action", type=str, choices=["add", "list"], default="list", nargs="?"
    )
    downloader_cmd.add_argument("-n", "--name", type=str, default=None)
    downloader_cmd.add_argument(
        "-f",
        "--downloader_format",
        type=str,
        default="video",
        choices=["video", "audio"],
    )
    downloader_cmd.add_argument(
        "-d", "--downloader_path", type=is_valid_path, default=None
    )
    downloader_cmd.set_defaults(func=downloaders_cmd)

    args = vars(parser.parse_args())
    func = args.get("func")
    args.pop("command")
    args.pop("func")

    func(**args)


# tests

# 1) with downloads path (e.g downloads.txt)
# python downloader.py "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/ChessSet.jpg/640px-ChessSet.jpg" -d "downloads.txt"
# python downloader.py -d "downloads.txt" -o ~/temp

# 2) with specific downloader type
# python downloader.py -t ytdlp_audio -d "downloads.txt" (type should precede everything unless explicitly defined inside the .txt)
# python downloader.py -t ytdlp_audio -d "downloads.txt" -o ~/temp
