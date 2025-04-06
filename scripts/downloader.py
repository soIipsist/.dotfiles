import sqlite3
import datetime
from enum import Enum

from ytdlp import download

database_path = "downloads.db"
links_file_path = "links.txt"


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

    execute_query(
        db,
        f"""INSERT INTO downloads (link, downloader, download_status, start_date) VALUES (?,?,?,?) """,
        (link_str, downloader, download_status, start_date),
    )


class Downloader(str, Enum):
    YTDLP = "ytdlp"


class DownloadStatus(str, Enum):
    STARTED = "started"
    IN_PROGRESS = "in progress"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


try:
    db = sqlite3.connect(database_path)
except sqlite3.Error as e:
    print("Error connecting to the database:", e)
    print("Database path: ", database_path)


execute_query(
    db,
    """CREATE TABLE IF NOT EXISTS downloads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    link text NOT NULL, 
    downloader text NOT NULL, 
    download_status text NOT NULL,
    start_date DATE, 
    end_date DATE
);""",
)

# check if text file was modified
with open(links_file_path, "r") as file:
    for line in file:
        link = line.strip()
        if not link:
            continue
        download_link(db, link)
