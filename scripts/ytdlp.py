import yt_dlp
import argparse
import os
import json
from pprint import PrettyPrinter
from urllib.parse import urlparse, parse_qsl, urlencode, urlunparse

bool_choices = ["0", "1", 0, 1, "true", "false", True, False, None]
valid_formats = ["ytdlp_audio", "ytdlp_video"]
parent_directory = os.path.dirname(os.path.abspath(__file__))
pp = PrettyPrinter(indent=2)


def get_urls(urls: list, removed_args: list = None):
    if not removed_args:
        return urls

    remove_set = set(removed_args)
    return [
        urlunparse(
            parsed._replace(
                query=urlencode(
                    [(k, v) for k, v in parse_qsl(parsed.query) if k not in remove_set]
                )
            )
        )
        for url in urls
        if (parsed := urlparse(url))
    ]


def str_to_bool(string: str):
    return string in ["1", "true", True]


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        print(e)


def get_outtmpl(
    options: dict, ytdlp_format: str, prefix: str = None, output_directory: str = None
):

    outtmpl = options.get("outtmpl", f"%(title)s.%(ext)s")

    if prefix:
        outtmpl = f"{prefix}{outtmpl}"

    if not output_directory:
        if ytdlp_format == "ytdlp_audio":
            output_directory = os.environ.get("YTDLP_AUDIO_DIRECTORY")

        elif ytdlp_format == "ytdlp_video":
            output_directory = os.environ.get("YTDLP_VIDEO_DIRECTORY")

    if output_directory:
        outtmpl = f"{output_directory}/{outtmpl}"

    return outtmpl


def get_format(options: dict, format: str, custom_format: str = None):
    existing_format = options.get("format")

    if custom_format:
        return custom_format

    if format == "ytdlp_audio":
        return "bestaudio/best"

    return "bestvideo+bestaudio" if not existing_format else existing_format


def get_postprocessors(options: dict, format: str, extension: str):
    postprocessors: list = options.get("postprocessors", [])

    embed_subtitle = {"already_have_subtitle": False, "key": "FFmpegEmbedSubtitle"}
    extract_audio = {"key": "FFmpegExtractAudio", "preferredcodec": extension}

    if format == "ytdlp_video":
        if embed_subtitle not in postprocessors:
            postprocessors.append(embed_subtitle)
    else:
        if extract_audio not in postprocessors:
            postprocessors.append(extract_audio)

    return postprocessors


def get_postprocessor_args(options: dict, postprocessor_args: list = []):
    if not postprocessor_args:
        postprocessor_args = []

    options_postprocessor_args: list = options.get("postprocessor_args", [])
    options_postprocessor_args.extend(postprocessor_args)
    return options_postprocessor_args


def get_options(
    options_path="",
    ytdlp_format: str = "ytdlp_video",
    custom_format: str = None,
    update_options: bool = False,
    prefix: str = None,
    extension: str = None,
    postprocessor_args: list = None,
    output_directory=None,
):
    ytdlp_format = ytdlp_format.lower()

    if ytdlp_format not in valid_formats:
        ytdlp_format = "ytdlp_video"

    if os.path.exists(options_path):  # read from metadata file, if it exists
        print(f"Using ytdlp options from path: {options_path}.")
        options = read_json_file(options_path)
    else:
        options = {}

    if not update_options:
        return options

    options: dict

    if ytdlp_format == "ytdlp_video":  # default ytdlp_video options
        options.update(
            {
                "progress": True,
                "writesubtitles": True,
                "writeautomaticsub": True,
                "subtitleslangs": ["en"],
            }
        )

        if not extension:
            extension = "mp4"

    elif ytdlp_format == "ytdlp_audio":
        if not extension:
            extension = "mp3"

        options.update(
            {
                "progress": True,
                "ignoreerrors": True,
            }
        )

    ytdlp_format = get_format(options, ytdlp_format, custom_format)
    postprocessors = get_postprocessors(options, ytdlp_format, extension)
    options_postprocessor_args = get_postprocessor_args(options, postprocessor_args)
    outtmpl = get_outtmpl(options, ytdlp_format, prefix, output_directory)

    options["merge_output_format"] = extension
    options["outtmpl"] = outtmpl
    options["postprocessors"] = postprocessors
    options["postprocessor_args"] = options_postprocessor_args
    options["format"] = ytdlp_format

    return options


def get_entry_url(original_url: str, entry: dict) -> str:
    id = entry.get("id")
    if not id:
        return None
    parsed = urlparse(original_url)
    hostname = parsed.hostname or ""

    if "youtube" in hostname or "youtu.be" in hostname:
        url = f"https://www.youtube.com/watch?v={id}"
    else:
        new_path = parsed.path.rstrip("/") + "/" + id
        url = urlunparse(parsed._replace(path=new_path))

    print(f"Entry url found from ID {id}: {url}.")
    return url


def download(urls: list, options: dict = None):
    print("Downloading with yt-dlp...")

    if isinstance(options, str):  # this is a path
        options = get_options(options_path=options)

    pp.pprint(options)
    all_entries = []
    error_entries = []

    for url in urls:
        print(f"\nProcessing URL: {url}")
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                info = ytdl.extract_info(url, download=False)

                # Determine if it's a playlist or a single video
                is_playlist = info.get("entries") is not None
                entries = info.get("entries") if is_playlist else [info]

                if is_playlist:
                    print(
                        f"Playlist: {info.get('title', 'Untitled')} ({len(entries)} videos)"
                    )

                cleaned_entries = []
                for idx, entry in enumerate(entries):
                    if not entry:
                        print(f"Skipping unavailable video at index {idx}.")
                        error_entries.append(entry)
                        continue

                    entry_url = entry.get("webpage_url", get_entry_url(url, entry))
                    if not entry_url:
                        print(f"Missing URL at index {idx}. Skipping.")
                        continue

                    print(f"Downloading: {entry.get('title', entry_url)}")
                    if ytdl.download([entry_url]) != 0:
                        print(f"Error downloading: {entry_url}")
                        error_entries.append(entry)
                    else:
                        cleaned_entries.append(entry)

                all_entries.extend(cleaned_entries)

        except yt_dlp.utils.DownloadError as e:
            print(f"Download error: {e}")
        except SystemExit as e:
            print(f"SystemExit: {e} — continuing...")
        except Exception as e:
            print(f"Unexpected error: {e}")

    return all_entries, error_entries


# def start_ytldp_download(self):

#     status_code = 0
#     ytdlp_format = self._get_ytdlp_format()

#     ytdlp_options = get_options(
#         ytdlp_format=ytdlp_format,
#         output_directory=self.output_directory,
#         options_path=self.ytdlp_options_path,
#     )

#     try:
#         urls = get_ytdlp_urls([self.url], removed_args=None)
#         self.upsert()
#         all_entries, error_entries = ytdlp_download(urls, ytdlp_options)
#         # self._insert_ytdlp_entries(all_entries, error_entries)

#     except KeyboardInterrupt:
#         print("\nDownload interrupted by user.")
#         status_code = 1

#     except subprocess.CalledProcessError as e:
#         print(f"\nDownload failed: {e}")
#         status_code = 1

#     except Exception as e:
#         print(f"An unexpected error occurred: {e}")
#         status_code = 1

#     if status_code == 1:
#         self.set_download_status_query(DownloadStatus.INTERRUPTED)
#     else:
#         self.set_download_status_query(DownloadStatus.COMPLETED)


# def _get_ytdlp_options_path(self):
#     options = self.downloader.downloader_path
#     options_path = os.path.join(script_directory, options)
#     return options_path


#   def _insert_ytdlp_entries(self, entries, error_entries: list):

#         # generate a new download based on url of entry
#         is_playlist = len(entries) > 1
#         original_url = self.url

#         if is_playlist:
#             print(f"Downloading playlist {self.url}")

#         for entry in entries:
#             title = entry.get("title")
#             entry_id = entry.get("id")
#             url = None

#             url = (
#                 self._normalize_ytdlp_url(self.url, entry_id) if entry_id else self.url
#             )

#             if title:
#                 filename = title.strip().replace("/", "_")
#                 self.output_path = os.path.join(
#                     self.output_directory or os.getcwd(), filename
#                 )
#             else:
#                 self.output_path = self.get_output_path(url)

#             if is_playlist:
#                 self.source_url = original_url

#             entry_data = {
#                 "Title": title,
#                 "URL": url,
#                 "Source url (playlist url)": self.source_url,
#                 "Output path": self.output_path,
#             }
#             self.logger.info(f"Inserting playlist entry: \n{pp.pformat(entry_data)}")
#             self.url = url
#             self.download_status = (
#                 DownloadStatus.COMPLETED
#                 if entry not in error_entries
#                 else DownloadStatus.INTERRUPTED
#             )
#             self.upsert()

#  def _get_ytdlp_format(self):

#         # choose different format based on downloader.txt base file name
#         ytdlp_format = self.downloader.downloader_type

#         path_name = (
#             os.path.basename(self.downloads_path).removesuffix(".txt")
#             if self.downloads_path is not None
#             else None
#         )
#         file_formats = {
#             "music": "ytdlp_audio",
#             "mp3": "ytdlp_audio",
#             "videos": "ytdlp_video",
#         }

#         if path_name in file_formats.keys():
#             ytdlp_format = file_formats.get(path_name)

#         return ytdlp_format


def download_url(url: str, options: dict) -> list[tuple[bool, dict]]:
    results = []

    try:
        with yt_dlp.YoutubeDL(options) as ytdl:
            info = ytdl.extract_info(url, download=False)
            is_playlist = info.get("_type") == "playlist"
            entries = info["entries"] if is_playlist else [info]

            for idx, entry in enumerate(entries):
                if not entry:
                    print(f"Skipping unavailable video at index {idx}.")
                    results.append((False, None))
                    continue

                entry_url = entry.get("webpage_url")
                if not entry_url:
                    print(f"Missing URL at index {idx}. Skipping.")
                    results.append((False, entry))
                    continue

                print(f"Downloading: {entry.get('title', entry_url)}")
                try:
                    success = ytdl.download([entry_url]) == 0
                except Exception as e:
                    print(f"Download failed: {e}")
                    success = False

                results.append((success, entry))

    except Exception as e:
        print(f"Failed to process URL '{url}': {e}")
        return [(False, None)]

    return results


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-r", "--removed_args", default=None, nargs="+")
    parser.add_argument(
        "-f",
        "--format",
        default=os.environ.get("YTDLP_FORMAT", "ytdlp_video"),
        choices=["ytdlp_video", "ytdlp_audio"],
    )
    parser.add_argument("-d", "--output_directory", type=str, default=None)
    parser.add_argument(
        "-p", "--prefix", default=os.environ.get("YTDLP_PREFIX"), type=str
    )
    parser.add_argument("-e", "--extension", default=None)
    parser.add_argument("-cf", "--custom_format", default=None)
    parser.add_argument("-ppa", "--postprocessor_args", default=None, nargs="+")
    parser.add_argument(
        "-o", "--options_path", default=os.environ.get("YTDLP_OPTIONS_PATH", "")
    )
    parser.add_argument(
        "-u",
        "--update_options",
        default=os.environ.get("YTDLP_UPDATE_OPTIONS", True),
        type=str_to_bool,
        choices=bool_choices,
    )

    args = vars(parser.parse_args())

    urls = args.get("urls")
    removed_args = args.get("removed_args")
    format = args.get("format")
    output_directory = args.get("output_directory")
    prefix = args.get("prefix")
    custom_format = args.get("custom_format")
    extension = args.get("extension")
    postprocessor_args = args.get("postprocessor_args", [])
    options_path = args.get("options_path", "")
    update_options = args.get("update_options")

    options = get_options(
        options_path,
        format,
        custom_format,
        update_options,
        prefix,
        extension,
        postprocessor_args,
        output_directory,
    )

    urls = get_urls(urls, removed_args)
    all_entries, error_entries = download(urls, options)

# playlist tests
# python ytdlp.py "https://youtube.com/playlist?list=OLAK5uy_nTBnmorryZikTJrjY0Lj1lHG_DWy4IPvk" -f ytdlp_audio
# python ytdlp.py "https://music.youtube.com/watch?v=owZyZrWppGg&list=PLcSQ3bJVgbvb43FGbe7c550xI7gZ9NmBW"

# ytdlp_video only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo"
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO"

# ytdlp_audio only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO" -f ytdlp_audio
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" -f ytdlp_audio -i 0
