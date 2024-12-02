import yt_dlp
import argparse
import os
import json
import re


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        print(e)


parent_directory = os.getcwd()

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
        with yt_dlp.YoutubeDL(options) as ytdl:
            if extract_info:
                info = ytdl.extract_info(url, download=False)
                print(info)

            status_code = ytdl.download(url)
            print("Status code: ", status_code)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-f", "--format", default="video", choices=["video", "audio"])
    parser.add_argument("-o", "--output_directory", type=str, default=None)
    parser.add_argument("--options", default=None, type=str)
    parser.add_argument("--extract_info", default=False)
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
