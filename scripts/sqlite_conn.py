download_values = [
    "url text NOT NULL",
    "downloader text NOT NULL",
    "download_status text NOT NULL",
    "start_date DATE",
    "PRIMARY KEY (url, downloader)",
]

downloader_values = [
    "name text NOT NULL PRIMARY KEY",
    "format text NOT NULL",
    "downloader_path text NOT NULL",
]
