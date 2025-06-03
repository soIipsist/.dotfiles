from sqlite import create_connection, create_table


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

tables = ["downloads", "downloaders"]
values = [download_values, downloader_values]


def create_db(db_path: str, tables: list = tables, values: list = values):

    print("Creating database...")
    conn = create_connection(db_path)

    # create tables
    for t, v in zip(tables, values):
        create_table(conn, t, v)

    return conn
