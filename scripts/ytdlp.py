import yt_dlp
import argparse
import os
import json
from pprint import PrettyPrinter

bool_choices = [0, 1, "true", "false", True, False, None]


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        print(e)


parent_directory = os.path.dirname(os.path.abspath(__file__))
pp = PrettyPrinter(indent=2)


def get_options(format: str):

    # check if options exist as environment variables
    options_file = f"{parent_directory}/metadata/{format}_options.json"

    options = {}

    if os.path.exists(options_file):
        options = read_json_file(options_file)

    return options


def process_video_entry(entry, ytdl: yt_dlp.YoutubeDL, options):
    """
    Check for filename duplicates.
    """
    print("PROCESSING FILE...")
    original_filename = ytdl.prepare_filename(entry)
    final_extension = options.get("postprocessors", [{}])[0].get("preferredcodec")
    final_filename = (
        f"{os.path.splitext(original_filename)[0]}.{final_extension}"
        if final_extension
        else original_filename
    )

    print("Filename:", final_filename)

    # Check if the file already exists
    if os.path.exists(final_filename):
        print(f"File already exists, skipping: {final_filename}")
        return

    # Download the file
    status_code = ytdl.download(entry["webpage_url"])
    print("Status code: ", status_code)


def download(urls: list, options: dict, extract_info: bool):
    for url in urls:
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:
                if extract_info:
                    # Extract video/playlist information
                    info = ytdl.extract_info(url, download=False)

                    # Check if it's a playlist
                    if "entries" in info:
                        print(
                            f"Processing playlist: {info.get('title', 'Untitled Playlist')} ({len(info['entries'])} videos)"
                        )
                        for entry in info["entries"]:
                            if not entry:
                                print("Skipping unavailable video.")
                                continue
                            process_video_entry(entry, ytdl, options)
                    else:
                        process_video_entry(info, ytdl, options)
                else:
                    ytdl.download(url)
        except yt_dlp.utils.DownloadError as e:
            print(f"Download error for {url}: {e}")
        except SystemExit as e:
            print(f"SystemExit encountered for {url}: {e}. Continuing with next URL...")
        except Exception as e:
            print(f"An unexpected error occurred with {url}: {e}")
        finally:
            print(f"Finished processing URL: {url}")


def get_urls(urls: list, remove_list: bool):
    if remove_list:
        urls = [url.split("&list")[0] if "&list" in url else url for url in urls]

    return urls


def str_to_bool(string: str):
    return string in ["1", "true", True]


def configure_options(format_type="video", video_extension=None, audio_extension=None):
    options = {}

    audio_extension = audio_extension or ("m4a" if format_type == "video" else "mp3")
    video_extension = video_extension or "mp4"

    if format_type == "video":
        options["format"] = (
            f"bestvideo[ext={video_extension}]+bestaudio[ext={audio_extension}]/{video_extension}"
        )
    elif format_type == "audio":
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


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument(
        "-r", "--remove_list", default=True, type=str_to_bool, choices=bool_choices
    )
    parser.add_argument(
        "-f",
        "--format",
        default=os.environ.get("YTDLP_FORMAT"),
        choices=["video", "audio"],
    )
    parser.add_argument("-o", "--output_path", type=str, default=None)
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
        "-v", "--video_extension", default=os.environ.get("YTDLP_VIDEO_EXT")
    )

    args = vars(parser.parse_args())

    urls = args.get("urls")
    remove_list = args.get("remove_list")
    format = args.get("format")
    extract_info = args.get("extract_info")
    output_path = args.get("output_path")
    prefix = args.get("prefix")
    extension = args.get("extension")
    audio_extension = args.get("audio_extension")
    video_extension = args.get("video_extension")
    options = get_options(format)

    outtmpl = f"%(title)s.%(ext)s"

    if format == "audio":
        audio_extension = extension if extension else audio_extension

    if format == "video":
        video_extension = extension if extension else video_extension

    if extension or audio_extension or video_extension:
        options: dict
        new_opts = configure_options(format, video_extension, audio_extension)
        options.update(new_opts)

    if prefix:
        outtmpl = f"{prefix} - {outtmpl}"

    if output_path:
        outtmpl = f"{output_path}/{outtmpl}"

    options["outtmpl"] = outtmpl

    pp.pprint(options)
    urls = get_urls(urls, remove_list)
    download(urls, options, extract_info)


# download playlist
# python ytdlp.py "https://music.youtube.com/watch?v=owZyZrWppGg&list=PLcSQ3bJVgbvb43FGbe7c550xI7gZ9NmBW" -f audio

# download video with mp4 format
# python ytdlp.py -e mp4 -i 1
