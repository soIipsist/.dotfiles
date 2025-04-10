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


class DownloadStatus(str, Enum):
    STARTED = "started"
    IN_PROGRESS = "in progress"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


class Download:
    downloader = Downloader.YTDLP
    status = DownloadStatus.STARTED
    format = None

    link: str = None

    def __init__(
        self, link: str, downloader=Downloader.YTDLP, status=DownloadStatus.STARTED
    ):
        pass


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


def download_link(db: sqlite3.Connection, link: str):
    link = link.split(" ")  # split link into spaces

    link_str = link[0]
    downloader = link[1] if len(link) > 1 else Downloader.YTDLP.value
    download_status = DownloadStatus.STARTED.value
    start_date = str(datetime.datetime.now())

    if downloader == Downloader.YTDLP.value:
        format = get_format_from_path(link_str)
        print(format)
        # options = get_options()
        # download()
    execute_query(
        db,
        f"""INSERT INTO downloads (link, downloader, download_status, start_date) VALUES (?,?,?,?) """,
        (link_str, downloader, download_status, start_date),
    )


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
        link = line.strip()
        if not link:
            continue

        # download_link(db, link)
