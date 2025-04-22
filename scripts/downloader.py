import os
import sqlite3
import datetime
from enum import Enum
from ytdlp import download, get_options

database_path = "downloads.db"
links_file_path = "downloads.txt"
valid_formats = ["audio", "video"]
specific_format = None


class Downloader(str, Enum):
    YTDLP = "ytdlp"
    YTDLP_AUDIO_1 = "ytdlp_audio"
    YTDLP_VIDEO_1 = "ytdlp_video"
    YTDLP_VIDEO_2 = "ytdlp_video_2"
    YTDLP_VIDEO_3 = "ytdlp_video_3"


class DownloadStatus(str, Enum):
    STARTED = "started"
    IN_PROGRESS = "in progress"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Download:
    _downloader = Downloader.YTDLP
    _download_status = DownloadStatus.STARTED
    _format = None
    _start_date = str(datetime.datetime.now())
    _link: str = None
    _link_str: str = None

    def __init__(self, link_str: str):
        self.link_str = link_str

    @property
    def link(self):
        return self._link

    @link.setter
    def link(self, link: str):
        self._link = link

    @property
    def link_str(self):
        return self._link_str

    @link_str.setter
    def link_str(self, link_str: str):
        self.parse_link(link_str)

    @property
    def downloader(self):
        return self._downloader

    @downloader.setter
    def downloader(self, downloader: Downloader):
        self._downloader = downloader

    def parse_link(self, link_str: str):
        self._link_str = link_str
        link_str = link_str.split(" ")  # split link_str into spaces

        self.link = link_str[0]
        self.downloader = link_str[1] if len(link_str) > 1 else Downloader.YTDLP.value
        self.download_status = DownloadStatus.STARTED.value
        self.start_date = str(datetime.datetime.now())

    def start_download(self, db: sqlite3.Connection):
        print(
            self.link, str(self.download_status), str(self.downloader), self.start_date
        )

        execute_query(
            db,
            f"""INSERT INTO downloads (link, downloader, download_status, start_date) VALUES (?,?,?,?) """,
            (self.link, self.downloader, self.download_status, self.start_date),
        )

        if self.downloader == Downloader.Y:
            pass
            # download()

    def stop_download(self, db: sqlite3.Connection):
        self.download_status = DownloadStatus.INTERRUPTED
        execute_query(
            db,
            f"""UPDATE downloads SET download_status = ? WHERE link = ?""",
            (self.download_status, self.link),
        )


def get_format_from_path(path: str):
    # choose different format based on path name
    path_name = os.path.basename(path).removesuffix(".txt")
    audio_format_names = ["mp3", "music"]

    if path_name in audio_format_names:
        format = "audio"
    else:
        format = "video"

    return format


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


try:
    db = sqlite3.connect(database_path)
except sqlite3.Error as e:
    print("Error connecting to the database:", e)
    print("Database path: ", database_path)


execute_query(
    db,
    """CREATE TABLE IF NOT EXISTS downloads (
    link text PRIMARY KEY NOT NULL, 
    downloader text NOT NULL, 
    download_status text NOT NULL,
    start_date DATE, 
    end_date DATE
);""",
)

links = []
# check if text file was modified
with open(links_file_path, "r") as file:
    for line in file:
        link_str = line.strip()
        if not link_str:
            continue
        download = Download(link_str)
        download.start_download(db)
