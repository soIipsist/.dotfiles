import os
from pprint import PrettyPrinter
import sqlite3
from datetime import datetime
from enum import Enum
import sys
from typing import List, Optional
from urllib.parse import urlparse
from sqlite import is_valid_path
from sqlite_item import SQLiteItem, create_connection
from sqlite_conn import create_db, download_values, downloader_values
from ytdlp import download as ytdlp_download, get_options, get_urls as get_ytdlp_urls
from wget import download as wget_download

import argparse
import subprocess

script_directory = os.path.dirname(__file__)
pp = PrettyPrinter(indent=2)

database_path = os.environ.get(
    "DOWNLOADS_DB_PATH", os.path.join(script_directory, "downloads.db")
)

# environment variables
# DOWNLOADER="ytdlp"
# DOWNLOADS_PATH="$HOME/videos/downloads.txt"
# DOWNLOADS_DB_PATH="$HOME/scripts/downloads.db"
# DOWNLOADS_OUTPUT_DIR="$HOME/videos"
# YTDLP_FORMAT="ytdlp_audio"
# YTDLP_EXTRACT_INFO="1"
# YTDLP_OPTIONS_PATH="$HOME/scripts/video_options.json"
# FFMPEG_OPTS="-protocol_whitelist file,http,https,tcp,tls"
# YTDLP_UPDATE_OPTIONS="1"
# YTDLP_VIDEO_DIRECTORY="$HOME/mnt/"
# YTDLP_AUDIO_DIRECTORY="$HOME/mnt/ssd/Music"
# VENV_PATH="$HOME/venv"

# create connection and tables
db_exists = os.path.exists(database_path)
db = create_connection(database_path)
create_db(database_path)


class DownloadStatus(str, Enum):
    STARTED = "started"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Downloader(SQLiteItem):
    _name: str = None
    _downloader_type: str = None
    _downloader_path: str = None

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, name):
        self._name = name

    @property
    def downloader_type(self):
        return self._downloader_type

    @downloader_type.setter
    def downloader_type(self, downloader_type):
        self._downloader_type = downloader_type

    @property
    def downloader_path(self):
        return self._downloader_path

    @downloader_path.setter
    def downloader_path(self, downloader_path):
        self._downloader_path = (
            os.path.abspath(downloader_path)
            if downloader_path is not None
            else downloader_path
        )

    def __init__(
        self,
        name: str = None,
        downloader_type: str = None,
        downloader_path: str = None,
    ):
        column_names = [
            "name",
            "downloader_type",
            "downloader_path",
        ]

        super().__init__(downloader_values, column_names, db_path=database_path)
        self.name = name
        self.downloader_type = downloader_type
        self.downloader_path = downloader_path
        self.conjunction_type = "OR"
        self.filter_condition = f"name = {self._name}"
        self.table_name = "downloaders"

    def __repr__(self):
        return f"{self.name}"

    def __str__(self):
        return f"{self.name}"


default_downloaders = [
    Downloader(
        "ytdlp", "ytdlp_video", os.path.join(script_directory, "video_options.json")
    ),
    Downloader(
        "ytdlp_audio",
        "ytdlp_audio",
        os.path.join(script_directory, "audio_options.json"),
    ),
    Downloader("wget", "wget", os.path.join(script_directory, "wget_options.json")),
]

if not db_exists:
    Downloader.insert_all(default_downloaders)
    print("Successfully generated default downloaders.")


class Download(SQLiteItem):
    _downloader = None
    _downloader_type: str = None
    _download_status = DownloadStatus.STARTED
    _start_date = str(datetime.now())
    _end_date = None
    _time_elapsed = None
    _url: str = None
    _download_str: str = None
    _downloads_path: str = None
    _db: sqlite3.Connection = None
    _output_directory: str = None
    _output_path: str = None
    _source_url: str = None

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
            "end_date",
            "time_elapsed",
            "output_path",
            "source_url",
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
    def source_url(self):
        return self._source_url

    @source_url.setter
    def source_url(self, source_url):
        self._source_url = source_url

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
            start_date = str(datetime.now())
        self._start_date = start_date

    @property
    def end_date(self):
        return self._end_date

    @end_date.setter
    def end_date(self, end_date):
        self._end_date = end_date

    @property
    def output_path(self):
        return self._output_path

    @output_path.setter
    def output_path(self, output_path: str):
        self._output_path = output_path

    @property
    def time_elapsed(self):
        return self._time_elapsed

    @time_elapsed.setter
    def time_elapsed(self, time_elapsed):
        self._time_elapsed = time_elapsed

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
        if isinstance(downloader, str):
            downloader = Downloader(name=downloader).select_first()

        self._downloader = downloader

    def set_download_status_query(self, status: DownloadStatus):
        self.download_status = status

        if self.download_status == DownloadStatus.COMPLETED:
            self.end_date = str(datetime.now())
            fmt = "%Y-%m-%d %H:%M:%S.%f"
            start_dt = datetime.strptime(self.start_date, fmt)
            end_dt = datetime.strptime(self.end_date, fmt)

            self.time_elapsed = str(end_dt - start_dt)
            print("TIME ELAPSED: ", self.time_elapsed)

        self.update()

    def start_download(self):

        if self.output_directory:
            os.makedirs(self.output_directory, exist_ok=True)

        if self.downloader.downloader_type == "wget":
            self.start_wget_download()
        else:
            self.start_ytldp_download()

        return self.output_path

    def get_output_path(self, url: str):
        filename = os.path.basename(urlparse(url).path)

        if not self.output_directory:
            self.output_directory = os.getcwd()

        output_path = os.path.join(self.output_directory, filename)
        return output_path

    def start_wget_download(self):

        self.output_path = self.get_output_path(self.url)
        self.insert()

        status_code = wget_download(self.url, self.output_directory)

        if status_code == 1:
            self.set_download_status_query(DownloadStatus.INTERRUPTED)
        else:
            self.set_download_status_query(DownloadStatus.COMPLETED)

    def _insert_ytdlp_entries(self, entries):

        # generate a new download based on url of entry
        is_playlist = len(entries) > 1
        original_url = self.url

        if is_playlist:
            print(f"Downloading playlist {self.url}")

        for entry in entries:
            title = entry.get("title")
            self.url = entry.get("url", self.url)

            if title:
                filename = title.strip().replace("/", "_")
                self.output_path = os.path.join(
                    self.output_directory or os.getcwd(), filename
                )
            else:
                self.output_path = self.get_output_path(self.url)

            if is_playlist:
                self.source_url = original_url

            self.insert()

    def start_ytldp_download(self):

        status_code = 0
        ytdlp_format = self._get_ytdlp_format()

        ytdlp_options = get_options(
            ytdlp_format,
            output_directory=self.output_directory,
            options_path=self.ytdlp_options_path,
        )

        try:
            urls = get_ytdlp_urls([self.url], removed_args=None)
            self.insert()
            all_entries, error_entries = ytdlp_download(urls, ytdlp_options)
            self._insert_ytdlp_entries(all_entries)

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

        # choose different format based on downloader.txt base file name
        ytdlp_format = self.downloader.downloader_type

        path_name = (
            os.path.basename(self.downloads_path).removesuffix(".txt")
            if self.downloads_path is not None
            else None
        )
        file_formats = {
            "music": "ytdlp_audio",
            "mp3": "ytdlp_audio",
            "videos": "ytdlp_video",
        }

        if path_name in file_formats.keys():
            ytdlp_format = file_formats.get(path_name)

        return ytdlp_format

    def __repr__(self):
        return f"{self.downloader}, {self.url}"

    def __str__(self):
        return f"{self.downloader}, {self.url}"

    @classmethod
    def parse_download_string(
        cls,
        download_str: str,
        downloader: Optional[Downloader] = None,
        downloads_path: Optional[str] = None,
        output_directory: Optional[str] = None,
    ):
        # {some_url} -> stored in a music.txt, will use default audio downloader
        # or
        # {some_url} {downloader} -> stored in a downloads.txt, will use default video downloader

        download_str = download_str.strip()

        if not download_str:
            return

        download_str = download_str.split(" ")
        url = download_str[0]
        downloader = download_str[1] if len(download_str) > 1 else downloader
        output_directory = (
            download_str[2] if len(download_str) > 2 else output_directory
        )

        download = Download(
            url,
            downloader,
            downloads_path=downloads_path,
            output_directory=output_directory,
        )

        return download


def start_downloads(
    url: str = None,
    downloader: Downloader = None,
    downloads_path: str = None,
    output_directory: str = None,
    **kwargs,
):
    downloads = []

    if not url and not downloads_path:
        raise ValueError("Either url or downloads path must be defined.")

    if url:
        downloads.append(
            Download(
                url,
                downloader,
                downloads_path=downloads_path,
                output_directory=output_directory,
            )
        )
    # create download string
    if downloads_path:
        skip_read = False
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
                skip_read = True

        if not skip_read:
            with open(downloads_path, "r") as file:
                for line in file:
                    download = Download.parse_download_string(
                        line, downloader, downloads_path, output_directory
                    )
                    if download is not None:
                        downloads.append(download)

    for download in downloads:
        download: Download
        download.start_download()


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
        for downloader in downloaders:
            downloader: Downloader
            pp.pprint(downloader.as_dict())


def download_all_cmd(**kwargs):
    print(kwargs)
    downloader_type = kwargs.get("downloader_type")
    downloader = None

    # get downloader based on type
    if downloader_type:
        downloader = Downloader(name=downloader_type).select_first()
        if not downloader:
            raise ValueError(f"Downloader of type '{downloader_type}' does not exist.")

    kwargs.pop("downloader_type")
    download = Download(**kwargs, downloader=downloader)

    url = kwargs.get("url")

    if url is None:
        downloads = download.filter_by(download.column_names)
        print(f"Total downloads ({len(downloads)}):")

        for download in downloads:
            download: Download
            pp.pprint(download.as_dict())
    else:
        start_downloads(**kwargs, downloader=downloader)


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
        "-t",
        "--downloader_type",
        default=os.environ.get("DOWNLOADER", "ytdlp"),
        type=str,
    )
    download_cmd.add_argument(
        "-d", "--downloads_path", default=os.environ.get("DOWNLOADS_PATH"), type=str
    )

    download_cmd.add_argument(
        "-s",
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

    # download_cmd.add_argument("")

    download_cmd.set_defaults(func=download_all_cmd)

    # downloader cmd
    downloader_cmd = subparsers.add_parser("downloaders", help="List downloaders")
    downloader_cmd.add_argument(
        "action", type=str, choices=["add", "list"], default="list", nargs="?"
    )
    downloader_cmd.add_argument("-n", "--name", type=str, default=None)
    downloader_cmd.add_argument(
        "-t", "--downloader_type", type=str, default="ytdlp_video"
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

# playlist urls
# https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ

# regular video urls
# https://youtu.be/MvsAesQ-4zA?si=gDyPQcdb6sTLWipY
# https://youtu.be/OlEqHXRrcpc?si=4JAYOOH2B0A6MBvF

# downloads

# python downloader.py downloads
# python downloader.py "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/ChessSet.jpg/640px-ChessSet.jpg" -d "downloads.txt"
# python downloader.py -d "downloads.txt" -o ~/temp

# python downloader.py -t ytdlp_audio -d "downloads.txt" (type should precede everything unless explicitly defined inside the .txt)
# python downloader.py -t ytdlp_audio -d "downloads.txt" -o ~/temp

# downloaders

# python downloader.py downloaders
# python downloader.py downloaders -t ytdlp_audio
# python downloader.py downloaders add -n ytdlp_2 -t ytdlp_video -d downloader_path.json
