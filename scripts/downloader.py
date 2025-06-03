import os
from pprint import PrettyPrinter
import sqlite3
import datetime
from enum import Enum
import sys
from typing import List, Optional
from sqlite_item import SQLiteItem, create_connection
from sqlite import execute_query
from sqlite_conn import download_values, downloader_values
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

# create downloads table
db = create_connection(database_path)


class DownloadStatus(str, Enum):
    STARTED = "started"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Downloader(SQLiteItem):
    _name: str = None
    _format: str = None
    _downloader_path: str = None

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def format(self):
        return self._format

    @format.setter
    def format(self, format):
        self._format = format

    @property
    def downloader_path(self):
        return self._downloader_path

    @downloader_path.setter
    def downloader_path(self, downloader_path):
        self._downloader_path = downloader_path

    def __init__(
        self,
        name,
        format,
        downloader_path,
    ):
        column_names = (
            [
                "name",
                "format",
                "downloader_path",
            ],
        )
        super().__init__(downloader_values, column_names, db_path=database_path)
        self.name = name
        self.format = format
        self.downloader_path = downloader_path
        self.filter_condition = f"name = {self._name}"


# fetch all downloaders
downloaders = Downloader().select_all()


class Download(SQLiteItem):
    _downloader = None
    _download_status = DownloadStatus.STARTED
    _start_date = str(datetime.datetime.now())
    _url: str = None
    _download_str: str = None
    _downloads_path: str = None
    _db: sqlite3.Connection = None
    _output_directory: str = None

    # def __init__(
    #     self,
    #     download_str: str = None,
    #     downloader: Downloader = None,
    #     downloads_path: Optional[str] = None,
    #     output_directory: Optional[str] = None,
    # ):
    #     self.downloader = downloader
    #     self.downloads_path = downloads_path
    #     self.output_directory = output_directory
    #     self.download_str = download_str

    def __init__(
        self,
        download_str: str = None,
        downloader: Downloader = None,
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
        self.downloader = downloader
        self.downloads_path = downloads_path
        self.output_directory = output_directory
        self.download_str = download_str

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
        self._start_date = start_date

    @property
    def db(self):
        if not self._db:
            self._db = create_connection(database_path)
        return self._db

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
    def download_str(self):
        return self._download_str

    @download_str.setter
    def download_str(self, download_str: str):
        self.parse_url(download_str)

    @property
    def downloader(self):
        return self._downloader

    @downloader.setter
    def downloader(self, downloader: Downloader):
        self._downloader = downloader

    def parse_url(self, download_str: str):
        self._download_str = download_str

        if self.download_str is None:
            return self.download_str

        download_str = download_str.split(" ")  # split download_str into spaces

        # string can be of this format
        # {some_url} -> stored in a music.txt, will use default audio downloader
        # or
        # {some_url} {downloader} -> stored in a downloads.txt, will use default video downloader

        self.url = download_str[0]

        if not self.downloader:
            self.downloader = Downloader.YTDLP.value

        if not self.downloads_path:
            return

        self.downloader = download_str[1] if len(download_str) > 1 else self.downloader
        self.download_status = DownloadStatus.STARTED.value
        self.start_date = str(datetime.datetime.now())

    def start_download_query(self):
        execute_query(
            self.db,
            f"""INSERT INTO downloads (url, downloader, download_status, start_date) VALUES (?,?,?,?) """,
            (self.url, self.downloader, self.download_status, self.start_date),
        )

    def set_download_status_query(self, status: DownloadStatus):
        self.download_status = status
        execute_query(
            self.db,
            f"""UPDATE downloads SET download_status = ? WHERE url = ?""",
            (self.download_status, self.url),
        )

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
            default_video_downloader = os.environ.get(
                "VIDEO_DOWNLOADER", Downloader.YTDLP_VIDEO_1
            )

            default_audio_downloader = os.environ.get(
                "YTDLP_DOWNLOADER", Downloader.YTDLP_AUDIO_1
            )

            # set downloader again, if format was found
            self.downloader = (
                default_video_downloader
                if format == "video"
                else default_audio_downloader
            )
        else:
            format = self.downloader.format
        return format

    def fetch_downloads(self):
        query = "SELECT * FROM downloads WHERE download_status = ? OR start_date = ? OR downloader = ?"
        params = [self.download_status, self.start_date, self.downloader]

        results = execute_query(self.db, query, params)

        return results

    def __repr__(self):
        return f"{self.downloader}, {self.url}"


def get_downloads(
    url: str,
    downloader_type: Downloader = Downloader.YTDLP,
    downloads_path: str = None,
    output_directory: str = None,
) -> List[Download]:

    downloads = []

    if not url and not downloads_path:
        raise ValueError("Either url or downloads path must be defined.")

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

    if not url:
        with open(downloads_path, "r") as file:
            for line in file:
                download_str = line.strip()
                if not download_str:
                    continue
                download = Download(
                    download_str, downloader_type, downloads_path, output_directory
                )
                downloads.append(download)
    else:
        download = Download(url, downloader_type, downloads_path, output_directory)
        downloads.append(download)
    return downloads


def main(
    url: str = None,
    downloader_type=Downloader.YTDLP,
    downloads_path: str = None,
    output_directory: str = None,
):
    downloads = get_downloads(url, downloader_type, downloads_path, output_directory)

    for download in downloads:
        download: Download
        download.start_download()


def fetch_downloads(
    download_status: DownloadStatus = None, downloader: Downloader = Downloader.YTDLP
):

    print("Fetching downloads")
    download = Download(downloader=downloader)
    download.download_status = download_status
    download.downloader = downloader
    results = download.fetch_downloads()
    pp.pprint(results)


if __name__ == "__main__":
    # Check if the user skipped the subcommand, and inject 'download'
    if len(sys.argv) > 1 and sys.argv[1] not in ["download", "list", "-h", "--help"]:
        sys.argv.insert(1, "download")

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    download_cmd = subparsers.add_parser("download", help="Download a URL")
    download_cmd.add_argument("url", type=str)
    download_cmd.add_argument(
        "-t", "--downloader_type", default=None, type=str, choices=[]
    )
    download_cmd.add_argument(
        "-d", "--downloads_path", default=os.environ.get("DOWNLOADS_PATH"), type=str
    )
    download_cmd.add_argument(
        "-o",
        "--output_directory",
        default=os.environ.get("DOWNLOADS_OUTPUT_DIR"),
        type=str,
    )
    download_cmd.set_defaults(func=main)

    list_cmd = subparsers.add_parser("list", help="List downloads")
    list_cmd.add_argument("--download_status", type=str, default=None)
    list_cmd.set_defaults(func=fetch_downloads)

    args = vars(parser.parse_args())
    func = args.get("func")
    args.pop("command")
    args.pop("func")

    print(args)
    func(**args)


# tests

# 1) with downloads path (e.g downloads.txt)
# python downloader.py "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/ChessSet.jpg/640px-ChessSet.jpg" -d "downloads.txt"
# python downloader.py -d "downloads.txt" -o ~/temp

# 2) with specific downloader type
# python downloader.py -t ytdlp_audio -d "downloads.txt" (type should precede everything unless explicitly defined inside the .txt)
# python downloader.py -t ytdlp_audio -d "downloads.txt" -o ~/temp
