from importlib import import_module
import os
from pprint import PrettyPrinter
import shlex
import sqlite3
from datetime import datetime
from enum import Enum
import sys
from typing import List, Optional
from urllib.parse import urlparse
from sqlite import is_valid_path
from sqlite_item import SQLiteItem, create_connection
from sqlite_conn import create_db, download_values, downloader_values
import logging
import argparse
import inspect

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

LOG_COLORS = {
    "DEBUG": "\033[36m",  # Cyan
    "INFO": "\033[32m",  # Green
    "WARNING": "\033[33m",  # Yellow
    "ERROR": "\033[31m",  # Red
    "CRITICAL": "\033[41m",  # Red background
    "RESET": "\033[0m",  # Reset to default
}


class ColoredFormatter(logging.Formatter):
    def format(self, record):
        levelname = record.levelname
        color = LOG_COLORS.get(levelname, "")
        reset = LOG_COLORS["RESET"]
        record.levelname = f"{color}{levelname}{reset}"
        return super().format(record)


def setup_logger(name="downloader", log_dir="/tmp", level=logging.INFO):
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    log_file = os.path.join(
        log_dir, f"{name}_{datetime.now().strftime('%Y-%m-%d')}.log"
    )

    logger = logging.getLogger(name)
    logger.setLevel(level)

    if not logger.handlers:
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setLevel(level)

        console_handler = logging.StreamHandler()
        console_handler.setLevel(level)

        formatter = logging.Formatter(
            "[%(asctime)s] [%(levelname)s] %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
        )

        file_handler.setFormatter(formatter)

        color_formatter = ColoredFormatter(
            "[%(asctime)s] [%(levelname)s] %(message)s", datefmt="%Y-%m-%d %H:%M:%S"
        )
        console_handler.setFormatter(color_formatter)

        logger.addHandler(file_handler)
        logger.addHandler(console_handler)

    return logger


class DownloadStatus(str, Enum):
    STARTED = "started"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"


logger = setup_logger(name="download")
logger.disabled = True


class Download(SQLiteItem):
    _downloader = None
    _download_status = DownloadStatus.STARTED
    _start_date = str(datetime.now())
    _end_date = None
    _time_elapsed = None
    _url: str = None
    _download_str: str = None
    _downloads_path: str = None
    _db: sqlite3.Connection = None
    _output_directory: str = None
    _output_filename: str = None
    _source_url: str = None

    @property
    def downloader_path(self):
        return getattr(self.downloader, "downloader_path") if self.downloader else None

    def __init__(
        self,
        url: str = None,
        downloader=None,
        download_status: DownloadStatus = DownloadStatus.STARTED,
        start_date: str = None,
        downloads_path: Optional[str] = None,
        output_directory: Optional[str] = None,
        output_filename: Optional[str] = None,
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
        self.output_filename = output_filename
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
        if self._output_directory is None:
            return os.getcwd()
        return self._output_directory

    @output_directory.setter
    def output_directory(self, output_directory):
        self._output_directory = output_directory

    @property
    def output_filename(self):
        return self._output_filename

    @output_filename.setter
    def output_filename(self, output_filename: str):
        self._output_filename = output_filename

    @property
    def output_path(self):
        return self.get_output_path()

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
    def time_elapsed(self):
        return self._time_elapsed

    @time_elapsed.setter
    def time_elapsed(self, time_elapsed):
        self._time_elapsed = time_elapsed

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
        if isinstance(self._downloader, str):
            return Downloader(downloader_type=self._downloader).select_first()
        return self._downloader

    @downloader.setter
    def downloader(self, downloader):
        self._downloader = downloader

    def set_download_status_query(self, status: DownloadStatus):
        self.download_status = status
        logger.info(f"Setting download status: {str(status)}")

        if self.download_status == DownloadStatus.COMPLETED:
            self.end_date = str(datetime.now())
            fmt = "%Y-%m-%d %H:%M:%S.%f"
            start_dt = datetime.strptime(self.start_date, fmt)
            end_dt = datetime.strptime(self.end_date, fmt)

            self.time_elapsed = str(end_dt - start_dt)
            log_message = f"Time elapsed: {self.time_elapsed}"
            logger.info(log_message)
        else:
            data = self.as_dict()
            logger.error(f"An unexpected error has occured! \n{pp.pformat(data)} ")
        self.update()

    def get_output_path(self):
        filename = (
            self.output_filename
            if self.output_filename
            else os.path.basename(urlparse(self.url).path)
        )

        output_path = os.path.join(self.output_directory, filename)
        return output_path

    def __repr__(self):
        return f"{self.downloader}, {self.url}"

    def __str__(self):
        return f"{self.downloader}, {self.url}"

    @classmethod
    def parse_download_string(cls, download_str: str):

        download_str = download_str.strip()

        if not download_str:
            return

        lexer = shlex.shlex(download_str, posix=False)
        lexer.whitespace_split = True
        lexer.commenters = ""
        parts = list(lexer)
        url = None
        downloader = None
        filename = None

        for part in parts:
            if part.startswith(("http://", "https://")):
                url = part
            elif part.startswith('"') and part.endswith('"'):
                filename = part
            else:
                downloader = part

        parsed_info = {
            "URL": url,
            "Downloader": downloader,
            "Output filename": filename,
        }

        logger.info(
            f"Parsed download string {download_str}:\n{pp.pformat(parsed_info)}"
        )
        return Download(url, downloader, output_filename=filename)


class Downloader(SQLiteItem):

    _downloader_type: str = None
    _downloader_path: str = None
    _downloader_args: list = None
    _func = None
    _module = None

    @property
    def module(self):
        return self._module

    @module.setter
    def module(self, module: str):
        self._module = module

    @property
    def func(self):
        return self._func

    @func.setter
    def func(self, func: str):
        self._func = func

    @property
    def downloader_args(self):
        return self._downloader_args

    @downloader_args.setter
    def downloader_args(self, downloader_args: str):
        self._downloader_args = downloader_args

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
            os.path.abspath(downloader_path.strip()) if downloader_path else ""
        )

    def __init__(
        self,
        downloader_type: str = None,
        downloader_path: str = None,
        module: str = None,
        func: str = None,
        downloader_args: str = None,
    ):
        column_names = [
            "downloader_type",
            "downloader_path",
            "module",
            "func",
            "downloader_args",
        ]

        super().__init__(downloader_values, column_names, db_path=database_path)
        self.downloader_type = downloader_type
        self.downloader_path = downloader_path
        self.module = module
        self.func = func
        self.downloader_args = downloader_args
        self.conjunction_type = "OR"
        self.filter_condition = f"downloader_type = {self._downloader_type}"
        self.table_name = "downloaders"

    def __repr__(self):
        return f"{self.downloader_type}"

    def __str__(self):
        return f"{self.downloader_type}"

    def get_function(self):
        # determine what function to run for each download
        module = import_module(self.module)
        func = getattr(module, self.func)
        return func

    def get_downloader_args(self, download: Download, func):

        func_signature = inspect.signature(func)
        func_params = func_signature.parameters

        args_dict = {}

        if not self.downloader_args:
            for name, param in func_params.items():
                if param.default is not inspect.Parameter.empty:
                    args_dict[name] = param.default
                else:
                    args_dict[name] = getattr(download, name, None)
            return args_dict

        keys = [key.strip() for key in self.downloader_args.split(",")]

        func_keys = {
            k.strip(): v.strip()
            for k, v in (key.split("=", 1) for key in keys if "=" in key)
        }

        for idx, param in enumerate(func_params):
            key = None
            if idx < len(keys):
                key = keys[idx]

            if key and "=" not in key:
                args_val = getattr(download, key, key)
                args_dict[param] = args_val
            else:
                if param in func_keys:
                    val = func_keys[param]
                    args_val = getattr(download, val, val)

                    if args_val.lower() == "false":
                        args_val = False
                    elif args_val.lower() == "true":
                        args_val = True
                    args_dict[param] = args_val

        return args_dict

    @staticmethod
    def start_downloads(downloads: list[Download]):
        download_results = []

        for idx, download in enumerate(downloads):
            if download.output_directory:
                os.makedirs(download.output_directory, exist_ok=True)

            logger.info(f"Starting {download.downloader} download.")
            downloader = download.downloader
            downloader: Downloader
            results = []

            try:
                if not downloader:
                    raise ValueError(f"Downloader not found at index {idx}!")

                func = downloader.get_function()
                downloader_args = downloader.get_downloader_args(download, func)

                for result in func(**downloader_args):
                    status_code = result.get("status", 1)

                    if status_code == 1:
                        download.set_download_status_query(DownloadStatus.INTERRUPTED)
                    else:
                        download.set_download_status_query(DownloadStatus.COMPLETED)
            except Exception as e:
                print(e)
                continue
            # download_results.extend(results)

        return download_results


default_downloaders = [
    Downloader(
        "ytdlp",
        os.path.join(script_directory, "video_options_blank.json"),
        "ytdlp",
        "download",
        "url, downloader_path, downloads_path",
    ),
    Downloader(
        "ytdlp_video",
        os.path.join(script_directory, "video_options.json"),
        "ytdlp",
        "download",
        "url, downloader_path, downloads_path",
    ),
    Downloader(
        "ytdlp_video_2",
        os.path.join(script_directory, "video_options_2.json"),
        "ytdlp",
        "download",
        "url, downloader_path, downloads_path",
    ),
    Downloader(
        "ytdlp_video_3",
        os.path.join(script_directory, "video_options_3.json"),
        "ytdlp",
        "download",
        "url, downloader_path, downloads_path",
    ),
    Downloader(
        "ytdlp_audio",
        os.path.join(script_directory, "audio_options.json"),
        "ytdlp",
        "download",
        "url, downloader_path, downloads_path",
    ),
    Downloader(
        "wget",
        None,
        "wget",
        "download",
        "url, output_directory",
    ),
    Downloader("urllib", None, "url_lib", "download", "url, output_directory"),
]

if not db_exists:
    Downloader.insert_all(default_downloaders)
    print("Successfully generated default downloaders.")

# argparse commands


def downloaders_cmd(
    action: str,
    downloader_type: str = None,
    downloader_path: str = None,
    module: str = None,
    func: str = None,
    downloader_args: str = None,
):
    d = Downloader(downloader_type, downloader_path, module, func, downloader_args)
    downloaders = [d]

    if action == "add":
        d.upsert()
    elif action == "delete":
        d.delete()
    else:  # list downloaders
        if downloader_type:
            downloaders = d.filter_by(d.column_names)
        else:
            downloaders = d.select_all()
    return downloaders


def download_all_cmd(
    url: str = None,
    downloader_type: str = None,
    downloads_path: str = None,
    output_directory: str = None,
    output_filename: str = None,
    **kwargs,
):
    downloader: Downloader = None

    if not url and not downloads_path:
        raise ValueError("Either url or downloads path must be defined.")

    # get downloader based on type

    if downloader_type:
        downloader = Downloader(downloader_type).select_first()
        if not downloader:
            raise ValueError(f"Downloader of type '{downloader_type}' does not exist.")

    download = Download(**kwargs, downloader=downloader)
    downloads = []

    if url is None:
        downloads = download.filter_by(download.column_names)
        print(f"Total downloads ({len(downloads)}):")

        for download in downloads:
            download: Download
            pp.pprint(download.as_dict())
    else:

        downloads.append(
            Download(
                url,
                downloader,
                downloads_path=downloads_path,
                output_directory=output_directory,
                output_filename=output_filename,
            )
        )
        # create download string
        if downloads_path:
            if not os.path.exists(downloads_path):
                raise FileNotFoundError(
                    f"Download path {downloads_path} does not exist."
                )

            with open(downloads_path, "r") as file:
                for line in file:
                    download = Download.parse_download_string(line)
                    logger.info(f"Reading downloads from file {downloads_path}.")

                    if download is not None:
                        download.output_directory = output_directory
                        download.downloads_path = downloads_path
                        downloads.append(download)
        Downloader.start_downloads(downloads)

    return downloads


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
        default=os.environ.get("DOWNLOADER", "ytdlp_video"),
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

    download_cmd.add_argument("-f", "--output_filename", default=None, type=str)

    download_cmd.set_defaults(call=download_all_cmd)

    # downloader cmd
    downloader_cmd = subparsers.add_parser("downloaders", help="List downloaders")
    downloader_cmd.add_argument(
        "action", type=str, choices=["add", "delete", "list"], default="list", nargs="?"
    )
    downloader_cmd.add_argument(
        "-t", "--downloader_type", type=str, default="ytdlp_video"
    )
    downloader_cmd.add_argument(
        "-d", "--downloader_path", type=is_valid_path, default=None
    )
    downloader_cmd.add_argument("-f", "--func", type=str, default="download")
    downloader_cmd.add_argument("-m", "--module", type=str, default="ytdlp")
    downloader_cmd.add_argument("-a", "--downloader_args", type=str, default=None)

    downloader_cmd.set_defaults(call=downloaders_cmd)

    args = vars(parser.parse_args())
    call = args.get("call")
    args.pop("command")
    args.pop("call")

    output = call(**args)

    if output:
        pp.pprint(output)

# tests

# playlist urls
# https://www.youtube.com/playlist?list=PL3A_1s_Z8MQbYIvki-pbcerX8zrF4U8zQ

# regular video urls
# https://youtu.be/MvsAesQ-4zA?si=gDyPQcdb6sTLWipY
# https://youtu.be/OlEqHXRrcpc?si=4JAYOOH2B0A6MBvF

# regular urls (wget)
# https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/ChessSet.jpg/640px-ChessSet.jpg

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
