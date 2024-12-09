import yt_dlp
import argparse
import os
import json


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        print(e)


parent_directory = os.path.dirname(os.path.abspath(__file__))

from pprint import PrettyPrinter

settings = read_json_file(f"{parent_directory}/metadata/settings.json")
pp = PrettyPrinter(indent=2)


def get_options(format: str, options_file: str = None):
    if options_file:
        options = read_json_file(options_file)
    else:
        options = read_json_file(f"{parent_directory}/metadata/{settings.get(format)}")

    return options


def download(urls: list, options: dict, extract_info: bool):
    for url in urls:
        try:
            with yt_dlp.YoutubeDL(options) as ytdl:

                if extract_info:
                    info = ytdl.extract_info(url, download=False)

                    original_filename = ytdl.prepare_filename(info)

                    # Determine the final filename after postprocessing
                    final_extension = options.get("postprocessors", [{}])[0].get(
                        "preferredcodec"
                    )
                    if final_extension:
                        final_filename = f"{os.path.splitext(original_filename)[0]}.{final_extension}"
                    else:
                        final_filename = original_filename

                    print("Filename:", final_filename)

                    # Check if the file already exists
                    if os.path.exists(final_filename):
                        print(f"File already exists, skipping: {final_filename}")
                        continue

                status_code = ytdl.download(url)
                print("Status code: ", status_code)
        except yt_dlp.utils.DownloadError as e:
            print(f"Download error for {url}: {e}")
        except SystemExit as e:
            print(f"SystemExit encountered for {url}: {e}. Continuing with next URL...")
        except Exception as e:
            print(f"An unexpected error occurred with {url}: {e}")
        finally:
            print(f"Finished processing URL: {url}")


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-f", "--format", default="audio", choices=["video", "audio"])
    parser.add_argument("-o", "--output_directory", type=str, default=None)
    parser.add_argument("--options", default=None, type=str)
    parser.add_argument("-e", "--extract_info", default=False)
    args = vars(parser.parse_args())

    urls = args.get("urls")
    format = args.get("format")
    options = args.get("options")
    extract_info = args.get("extract_info")
    output_directory = args.get("output_directory")
    options = get_options(format, options)

    if output_directory:
        options["outtmpl"] = f"{output_directory}/%(title)s.%(ext)s"

    pp.pprint(options)
    download(urls, options, extract_info)
