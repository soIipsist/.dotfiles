import argparse
import os
from urllib.parse import urljoin
import requests
import re

from enum import Enum
from pprint import PrettyPrinter

pp = PrettyPrinter(indent=4)

torrent = {"url": None, "size": None, "title": None, "description": None, "hash": None}


def get_torrent_info(url: str):
    pass


def get_pattern(base_url: str, custom_pattern=None):
    if custom_pattern:
        return custom_pattern

    if "piratebay" in base_url:
        pattern = r"magnet:([^\"]*)"

    return pattern


def get_links(base_url: str, query: str, custom_pattern: str = None):
    url = urljoin(base_url, query)

    response = requests.get(url)
    pattern = get_pattern(base_url, custom_pattern)
    print("PATT", url)
    matches = re.findall(pattern, response.text)

    if not matches:
        print("No magnet links found.")
        return

    links = [(match.split("&")[0], match) for match in matches]

    print(links)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("query", default=None)
    parser.add_argument("-u", "--base_url", default=os.environ.get("TORRENT_URL"))
    parser.add_argument("-c", "--custom_pattern", default=None)
    args = parser.parse_args()
    links = get_links(args.base_url, args.custom_pattern)
    pp.pprint(links)
