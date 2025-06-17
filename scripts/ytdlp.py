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
    options: dict, format: str, prefix: str = None, output_directory: str = None
):

    outtmpl = options.get("outtmpl", f"%(title)s.%(ext)s")

    if prefix:
        outtmpl = f"{prefix}{outtmpl}"

    if not output_directory:
        if format == "ytdlp_audio":
            output_directory = os.environ.get("YTDLP_AUDIO_DIRECTORY")

        elif format == "ytdlp_video":
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
    format: str,
    custom_format: str = None,
    update_options: bool = True,
    prefix: str = None,
    extension: str = None,
    postprocessor_args: list = None,
    output_directory=None,
    options_path="",
):
    format = format.lower()

    if format not in valid_formats:
        format = "ytdlp_video"

    if os.path.exists(options_path):  # read from metadata file, if it exists
        print(f"Using ytdlp options from path: {options_path}.")
        options = read_json_file(options_path)
    else:
        options = {}

    if not update_options:
        return options

    options: dict

    if format == "ytdlp_video":  # default ytdlp_video options
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

    elif format == "ytdlp_audio":
        if not extension:
            extension = "mp3"

        options.update(
            {
                "progress": True,
                "ignoreerrors": True,
            }
        )

    ytdlp_format = get_format(options, format, custom_format)
    postprocessors = get_postprocessors(options, format, extension)
    options_postprocessor_args = get_postprocessor_args(options, postprocessor_args)
    outtmpl = get_outtmpl(options, format, prefix, output_directory)

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
        format,
        custom_format,
        update_options,
        prefix,
        extension,
        postprocessor_args,
        output_directory,
        options_path,
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
