from sqlite import create_connection, create_table


download_values = [
    "url text NOT NULL",
    "downloader text NOT NULL",
    "download_status text NOT NULL",
    "start_date DATE",
    "end_date DATE",
    "time_elapsed text",
    "output_path text",
    "source_url text",
    "PRIMARY KEY (url, downloader)",
]

downloader_values = [
    "downloader_type text NOT NULL",
    "downloader_path text NOT NULL",
    "func text NOT NULL",
    "module text NOT NULL",
    "downloader_args text",
    "PRIMARY KEY (downloader_type, downloader_path)",
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
