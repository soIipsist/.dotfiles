import os
import sqlite3
import datetime
from enum import Enum
from typing import List, Optional
from ytdlp import download as ytdlp_download, get_options
import argparse


valid_formats = ["audio", "video"]
specific_format = None
script_directory = os.path.dirname(__file__)


class Downloader(str, Enum):
    YTDLP = "ytdlp"
    YTDLP_AUDIO_1 = "ytdlp_audio"
    YTDLP_VIDEO_1 = "ytdlp_video"
    YTDLP_VIDEO_2 = "ytdlp_video_2"
    YTDLP_VIDEO_3 = "ytdlp_video_3"


# each downloader has a set of different options
YTDLP_DOWNLOADERS = {
    Downloader.YTDLP: "video_options.json",
    Downloader.YTDLP_AUDIO_1: "audio_options.json",
    Downloader.YTDLP_VIDEO_1: "video_options.json",
    Downloader.YTDLP_VIDEO_2: "video_options_2.json",
    Downloader.YTDLP_VIDEO_3: "video_options_3.json",
    Downloader.YTDLP_VIDEO_3: "video_options_4.json",
}

downloader_keys = [key.value for key in YTDLP_DOWNLOADERS.keys()]


class DownloadStatus(str, Enum):
    STARTED = "started"
    IN_PROGRESS = "in progress"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Download:
    _downloader = Downloader.YTDLP
    _download_status = DownloadStatus.STARTED
    _start_date = str(datetime.datetime.now())
    _url: str = None
    _download_str: str = None
    _downloads_path: str = None

    def __init__(
        self,
        download_str: str,
        downloader: Downloader = None,
        downloads_path: Optional[str] = None,
    ):
        self.download_str = download_str
        self.downloader = downloader
        self.downloads_path = downloads_path

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
        download_str = download_str.split(" ")  # split download_str into spaces

        self.url = download_str[0]
        self.downloader = (
            download_str[1] if len(download_str) > 1 else Downloader.YTDLP.value
        )
        self.download_status = DownloadStatus.STARTED.value
        self.start_date = str(datetime.datetime.now())

    def start_download(self, db: sqlite3.Connection):

        execute_query(
            db,
            f"""INSERT INTO downloads (url, downloader, download_status, start_date) VALUES (?,?,?,?) """,
            (self.url, self.downloader, self.download_status, self.start_date),
        )

        if self.downloader in YTDLP_DOWNLOADERS.keys():
            ytdlp_options_path = self._get_ytdlp_options_path()
            ytdlp_format = self._get_ytdlp_format_from_path()
            ytdlp_options = get_options(ytdlp_format, options_path=ytdlp_options_path)

            print(ytdlp_format)
            # ytdlp_download()

    def stop_download(self, db: sqlite3.Connection):
        self.download_status = DownloadStatus.INTERRUPTED
        execute_query(
            db,
            f"""UPDATE downloads SET download_status = ? WHERE url = ?""",
            (self.download_status, self.url),
        )

    def _get_ytdlp_options_path(self):
        options = YTDLP_DOWNLOADERS.get(self.downloader)
        options_path = os.path.join(script_directory, options)

        if not os.path.exists(options_path):
            options_path = os.path.join(script_directory, "metadata", options)

        return options_path

    def _get_ytdlp_format_from_path(self):
        # choose different format based on path name
        if not self.downloads_path:
            return "video"

        path_name = os.path.basename(self.downloads_path).removesuffix(".txt")
        formats = {"music": "audio", "mp3": "audio", "videos": "video"}
        return formats.get(path_name, "video")

    def __repr__(self):
        return f"{self.downloader}, {self.url}"


def execute_query(conn: sqlite3.Connection, query: str, params: list = None):
    cursor = None
    results = []

    try:
        cursor = conn.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        results = cursor.fetchall()
        conn.commit()

    except sqlite3.Error as e:
        print("Error executing query:", e)

    return results


def get_downloads(
    url: str, downloader_type: Downloader = Downloader.YTDLP, downloads_path: str = None
) -> List[Download]:

    downloads = []

    if not downloads_path:
        with open(downloads_path, "r") as file:
            for line in file:
                download_str = line.strip()
                if not download_str:
                    continue
                download = Download(download_str, downloader_type, downloads_path)
                downloads.append(download)
    else:
        download = Download(url, downloader_type, downloads_path)
        downloads.append(download)
    return downloads


def main(url: str = None, downloader_type=Downloader.YTDLP, downloads_path: str = None):
    downloads = get_downloads(url, downloader_type, downloads_path)
    database_path = os.path.join(script_directory, "downloads.db")

    try:
        db = sqlite3.connect(database_path)
    except sqlite3.Error as e:
        print("Error connecting to the database:", e)
        print("Database path: ", database_path)

    execute_query(
        db,
        """CREATE TABLE IF NOT EXISTS downloads (
        url text PRIMARY KEY NOT NULL, 
        downloader text NOT NULL, 
        download_status text NOT NULL,
        start_date DATE, 
        end_date DATE
    );""",
    )

    for download in downloads:
        download: Download
        download.start_download(db)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("url", type=str, default=None, nargs="?")
    parser.add_argument(
        "-t",
        "--downloader_type",
        default=Downloader.YTDLP.value,
        type=str,
        choices=downloader_keys,
    )
    parser.add_argument(
        "-d", "--downloads_path", default=os.environ.get("DOWNLOADS_PATH"), type=str
    )

    args = vars(parser.parse_args())
    main(**args)
