import argparse
import os
import subprocess
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


def get_search_url(base_url: str, query: str):
    return base_url + query


def get_page(url, q):
    command = ["wget", "-qO-", f"{url}"]
    output = subprocess.check_output(command).decode("utf-8")
    # page = output.replace("+", " ").replace("%", "\\x")
    return output


def get_links(base_url: str, query: str, custom_pattern: str = None):

    url = get_search_url(base_url, query)
    page = get_page(url, query)
    pattern = get_pattern(base_url, custom_pattern)

    matches = re.findall(pattern, page)

    if not matches:
        print("No magnet links found.")
        return

    links = [match for match in matches]

    return links


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("query", default=None)
    parser.add_argument("-u", "--base_url", default=os.environ.get("TORRENT_URL"))
    parser.add_argument("-c", "--custom_pattern", default=None)
    args = parser.parse_args()
    links = get_links(args.base_url, args.query, args.custom_pattern)
    pp.pprint(links)
