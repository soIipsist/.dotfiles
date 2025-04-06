import sqlite3
import datetime
import enum

database_path = "links.db"
links_file_path = "/mnt/links.txt"


class Downloader(enum):
    YTDLP = "ytdlp"


class DownloadStatus(enum):
    STARTED = "started"
    IN_PROGRESS = "in progress"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


try:
    db = sqlite3.connect(database_path)
    db.execute(
        """CREATE TABLE IF NOT EXISTS links (
    link text PRIMARY KEY NOT NULL, 
    download_status text NOT NULL,
    downloader text NOT NULL, 
    begin_date DATE, 
    end_date DATE
);"""
    )
except Exception as e:
    print(e)

# check if text file was modified
with open(links_file_path, "r") as file:
    links = file.readlines()

    for link in links:
        print(link)
