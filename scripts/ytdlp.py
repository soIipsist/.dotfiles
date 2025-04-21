import yt_dlp
import argparse
import os
import json
from pprint import PrettyPrinter
from urllib.parse import urlparse, parse_qsl, urlencode, urlunparse

bool_choices = [0, 1, "true", "false", True, False, None]
valid_formats = ["audio", "video"]
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


def get_outtmpl(format: str, prefix: str = None, output_directory: str = None):

    outtmpl = f"%(title)s.%(ext)s"

    if prefix:
        outtmpl = f"{prefix}{outtmpl}"

    if not output_directory:
        if format == "audio":
            output_directory = os.environ.get("YTDLP_AUDIO_DIRECTORY")

        elif format == "video":
            output_directory = os.environ.get("YTDLP_VIDEO_DIRECTORY")

    if output_directory:
        outtmpl = f"{output_directory}/{outtmpl}"

    return outtmpl


def get_postprocessor_args(
    extension: str, video_codec: str = None, audio_codec: str = None
):
    postprocessor_args: list = []

    if video_codec:
        postprocessor_args.extend(["-f", extension, "-c:v", video_codec])

    if audio_codec:
        postprocessor_args.extend(["-c:a", audio_codec])

    return postprocessor_args


def get_options(
    format: str,
    custom_format: str = None,
    prefix: str = None,
    extension: str = None,
    video_codec=None,
    audio_codec=None,
    output_directory=None,
    options_path="",
):
    format = format.lower()

    if format not in valid_formats:
        format = "video"

    if os.path.exists(options_path):  # read from metadata file, if it exists
        options = read_json_file(options_path)
        return options

    if format == "video":  # default video options
        options = {
            "format": "bestvideo+bestaudio",
            "progress": True,
            "postprocessors": [
                {"already_have_subtitle": False, "key": "FFmpegEmbedSubtitle"}
            ],
            "writesubtitles": True,
            "writeautomaticsub": True,
            "subtitleslangs": ["en"],
            "outtmpl": "%(title)s.%(ext)s",
        }

        if not extension:
            extension = "mp4"

    elif format == "audio":
        if not extension:
            extension = "mp3"

        options = {
            "format": "bestaudio/best",
            "outtmpl": "%(title)s.%(ext)s",
            "postprocessors": [
                {"key": "FFmpegExtractAudio", "preferredcodec": extension}
            ],
            "ignoreerrors": True,
        }

    postprocessor_args = get_postprocessor_args(extension, video_codec, audio_codec)
    outtmpl = get_outtmpl(format, prefix, output_directory)

    options["merge_output_format"] = extension
    options["outtmpl"] = outtmpl
    options["postprocessor_args"] = postprocessor_args

    if custom_format:
        options["format"] = custom_format

    return options


def extract_video_info(ytdl: yt_dlp.YoutubeDL, url: str, extract_info: bool):

    entries = [{"webpage_url": url}]
    info = {"entries": entries}

    if extract_info:
        info = ytdl.extract_info(url, download=False)
        entries = info["entries"] if "entries" in info else [info]

        cleaned_entries = []
        for idx, entry in enumerate(entries):
            if not entry:
                print(f"Skipping unavailable video at index {idx}.")
                continue
            cleaned_entries.append(entry)

        info["entries"] = cleaned_entries

    return info


def download(urls: list, options: dict = None, extract_info: bool = True):
    all_entries = []  # list of dictionaries containing info for each url
    error_entries = []

    for url in urls:
        entries = []
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                info = extract_video_info(ytdl, url, extract_info)
                entries = info.get("entries", [{"webpage_url": url}])

                if len(entries) > 1:
                    print(
                        f"Processing playlist: {info.get('title', 'Untitled Playlist')} ({len(info['entries'])} videos)"
                    )

                for entry in entries:
                    entry_url = entry.get("webpage_url")
                    status_code = ytdl.download(entry_url)

                    if status_code == 1:
                        error_entries.append(entry)

        except yt_dlp.utils.DownloadError as e:
            print(f"Download error for {url}: {e}")
        except SystemExit as e:
            print(f"SystemExit encountered for {url}: {e}. Continuing with next URL...")
        except Exception as e:
            print(f"An unexpected error occurred with {url}: {e}")
        finally:
            all_entries.extend(entries)
            print(f"Finished processing URL: {url}")

    return all_entries, error_entries


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-r", "--removed_args", default=[], nargs="?")
    parser.add_argument(
        "-f",
        "--format",
        default=os.environ.get("YTDLP_FORMAT", "video"),
        choices=["video", "audio"],
    )
    parser.add_argument("-d", "--output_directory", type=str, default=None)
    parser.add_argument(
        "-p", "--prefix", default=os.environ.get("YTDLP_PREFIX"), type=str
    )
    parser.add_argument(
        "-i",
        "--extract_info",
        default=os.environ.get("YTDLP_EXTRACT_INFO"),
        type=str_to_bool,
        choices=bool_choices,
    )
    parser.add_argument("-e", "--extension", default=None)
    parser.add_argument("-cf", "--custom_format", default=None)
    parser.add_argument(
        "-a", "--audio_codec", default=os.environ.get("YTDLP_AUDIO_CODEC")
    )
    parser.add_argument(
        "-v", "--video_codec", default=os.environ.get("YTDLP_VIDEO_CODEC")
    )
    parser.add_argument(
        "-o", "--options_path", default=os.environ.get("YTDLP_OPTIONS_PATH", "")
    )

    args = vars(parser.parse_args())

    urls = args.get("urls")
    removed_args = args.get("removed_args")
    format = args.get("format")
    extract_info = args.get("extract_info")
    output_directory = args.get("output_directory")
    prefix = args.get("prefix")
    custom_format = args.get("custom_format")
    extension = args.get("extension")
    audio_codec = args.get("audio_codec")
    video_codec = args.get("video_codec")
    options_path = args.get("options_path", "")

    options = get_options(
        format,
        custom_format,
        prefix,
        extension,
        video_codec,
        audio_codec,
        output_directory,
        options_path,
    )

    pp.pprint(options)
    urls = get_urls(urls, removed_args)
    all_entries, error_entries = download(urls, options, extract_info)

# playlist tests
# python ytdlp.py "https://youtube.com/playlist?list=OLAK5uy_nTBnmorryZikTJrjY0Lj1lHG_DWy4IPvk" -f audio
# python ytdlp.py "https://music.youtube.com/watch?v=owZyZrWppGg&list=PLcSQ3bJVgbvb43FGbe7c550xI7gZ9NmBW"

# video only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo"
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO"

# audio only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO" -f audio
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" -f audio -i 0
