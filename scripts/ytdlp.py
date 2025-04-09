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


def get_options(
    format: str,
    prefix: str = None,
    video_extension="mp4",
    audio_extension="mp3",
    video_sound_extension="m4a",
    output_directory=None,
    metadata_file="",
):
    format = format.lower()

    if format not in valid_formats:
        format = "video"

    if os.path.exists(metadata_file):  # read from metadata file, if it exists
        options = read_json_file(metadata_file)
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
        options["format"] = (
            f"bestvideo[ext={video_extension}]+bestaudio[ext={video_sound_extension}]/{video_extension}"
        )
    elif format == "audio":
        options = {
            "format": "bestaudio/best",
            "outtmpl": "%(title)s.%(ext)s",
            "postprocessors": [
                {"key": "FFmpegExtractAudio", "preferredcodec": audio_extension}
            ],
            "ignoreerrors": True,
        }

    options["outtmpl"] = get_outtmpl(format, prefix, output_directory)

    if output_directory:
        outtmpl = f"{output_directory}/{outtmpl}"
    return options


def extract_video_info_and_download(
    ytdl: yt_dlp.YoutubeDL, url: str, extract_info: bool
):

    if extract_info:
        info = ytdl.extract_info(url, download=False)
        entries = info["entries"] if "entries" in info else [info]

        if len(entries) > 1:
            print(
                f"Processing playlist: {info.get('title', 'Untitled Playlist')} ({len(info['entries'])} videos)"
            )

        for entry in entries:
            if not entry:
                print("Skipping unavailable video.")
                continue

            filename = ytdl.prepare_filename(entry, outtmpl=f"%(title)s.%(ext)s")

            if os.path.exists(filename):
                print(f"File already exists, skipping: {filename}")

            status_code = ytdl.download(entry["webpage_url"])
            print("Status code: ", status_code)

    else:
        ytdl.download(url)


def download(urls: list, options: dict, extract_info: bool):
    for url in urls:
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                extract_video_info_and_download(ytdl, url, extract_info)

        except yt_dlp.utils.DownloadError as e:
            print(f"Download error for {url}: {e}")
        except SystemExit as e:
            print(f"SystemExit encountered for {url}: {e}. Continuing with next URL...")
        except Exception as e:
            print(f"An unexpected error occurred with {url}: {e}")
        finally:
            print(f"Finished processing URL: {url}")


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


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-r", "--removed_args", default=["list"], nargs="?")
    parser.add_argument(
        "-f",
        "--format",
        default=os.environ.get("YTDLP_FORMAT") or "video",
        choices=["video", "audio"],
    )
    parser.add_argument("-o", "--output_directory", type=str, default=None)
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
    parser.add_argument(
        "-a", "--audio_extension", default=os.environ.get("YTDLP_AUDIO_EXT")
    )
    parser.add_argument(
        "-s",
        "--video_sound_extension",
        default=os.environ.get("YTDLP_VIDEO_SOUND_EXT"),
    )
    parser.add_argument(
        "-v", "--video_extension", default=os.environ.get("YTDLP_VIDEO_EXT")
    )
    parser.add_argument("-m", "--metadata_file", default="")

    args = vars(parser.parse_args())

    urls = args.get("urls")
    removed_args = args.get("removed_args")
    format = args.get("format")
    extract_info = args.get("extract_info")
    output_directory = args.get("output_directory")
    prefix = args.get("prefix")
    extension = args.get("extension")
    audio_extension = args.get("audio_extension")
    video_extension = args.get("video_extension")
    video_sound_extension = args.get("video_sound_extension")
    metadata_file = args.get("metadata_file", "")

    options = get_options(
        format,
        prefix,
        video_extension,
        audio_extension,
        video_sound_extension,
        output_directory,
        metadata_file,
    )

    pp.pprint(options)
    urls = get_urls(urls, removed_args)

    # print(urls)
    download(urls, options, extract_info)

# playlist tests
# python ytdlp.py "https://youtube.com/playlist?list=OLAK5uy_nTBnmorryZikTJrjY0Lj1lHG_DWy4IPvk" -f audio
# python ytdlp.py "https://music.youtube.com/watch?v=owZyZrWppGg&list=PLcSQ3bJVgbvb43FGbe7c550xI7gZ9NmBW"

# video only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo"
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO"

# audio only tests
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" "https://music.youtube.com/watch?v=n3WmS_Yj0jU&si=gC3_A3MrL0RYhooO" -f audio
# python ytdlp.py "https://www.youtube.com/watch?v=RlXjyYlM4xo" -f audio -i 0
