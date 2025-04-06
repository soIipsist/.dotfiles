import yt_dlp
import argparse
import os
import json
from pprint import PrettyPrinter

bool_choices = [0, 1, "true", "false", True, False, None]
parent_directory = os.path.dirname(os.path.abspath(__file__))
pp = PrettyPrinter(indent=2)


def get_urls(urls: list, remove_list: bool):
    if remove_list:
        urls = [url.split("&list")[0] if "&list" in url else url for url in urls]

    return urls


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
    video_extension=None,
    audio_extension=None,
    video_sound_extension=None,
):
    # check if options exist as environment variables
    options_file = f"{parent_directory}/metadata/{format}_options.json"
    options = {}

    if os.path.exists(options_file):
        options = read_json_file(options_file)

    audio_extension = audio_extension or "mp3"
    video_extension = video_extension or "mp4"
    video_sound_extension = video_sound_extension or "m4a"

    if format == "video":
        options["format"] = (
            f"bestvideo[ext={video_extension}]+bestaudio[ext={video_sound_extension}]/{video_extension}"
        )
    elif format == "audio":
        options["format"] = "bestaudio/best"
        options["postprocessors"] = [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": audio_extension,
            }
        ]
    else:
        raise ValueError("Invalid format_type. Choose 'video' or 'audio'.")
    return options


def extract_video_info_and_download(
    ytdl: yt_dlp.YoutubeDL, url: str, extract_info: bool
):

    if extract_info:
        info = ytdl.extract_info(url, download=False)

        entries = info["entries"] if "entries" in info else info

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


def get_outtmpl(format: str, output_directory: str = None):

    if not output_directory:
        if format == "audio":
            output_directory = os.environ.get("YTDLP_AUDIO_DIRECTORY")

        elif format == "video":
            output_directory = os.environ.get("YTDLP_VIDEO_DIRECTORY")

    return output_directory


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument(
        "-r", "--remove_list", default=True, type=str_to_bool, choices=bool_choices
    )
    parser.add_argument(
        "-f",
        "--format",
        default=os.environ.get("YTDLP_FORMAT", "video"),
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
        "-s", "--video_sound_extension", default=os.environ.get("YTDLP_VIDEO_SOUND_EXT")
    )
    parser.add_argument(
        "-v", "--video_extension", default=os.environ.get("YTDLP_VIDEO_EXT")
    )

    args = vars(parser.parse_args())

    urls = args.get("urls")
    remove_list = args.get("remove_list")
    format = args.get("format")
    extract_info = args.get("extract_info")
    output_directory = args.get("output_directory")
    prefix = args.get("prefix")
    extension = args.get("extension")
    audio_extension = args.get("audio_extension", extension)
    video_extension = args.get("video_extension", extension)
    video_sound_extension = args.get("video_sound_extension")
    options = get_options(format)

    outtmpl = f"%(title)s.%(ext)s"

    if prefix:
        outtmpl = f"{prefix} - {outtmpl}"

    output_directory = get_outtmpl(format, output_directory)

    if output_directory:
        outtmpl = f"{output_directory}/{outtmpl}"

    options["outtmpl"] = outtmpl

    pp.pprint(options)
    urls = get_urls(urls, remove_list)
    download(urls, options, extract_info)


# download playlist
# python ytdlp.py "https://music.youtube.com/watch?v=owZyZrWppGg&list=PLcSQ3bJVgbvb43FGbe7c550xI7gZ9NmBW" -f audio

# download video with mp4 format
# python ytdlp.py -e mp4 -i 1
