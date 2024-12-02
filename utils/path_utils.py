import os
import re


def is_valid_dir(string, raiseError=True):
    if os.path.isdir(string):
        return string
    if raiseError:
        raise NotADirectoryError(string)


def is_valid_path(string, raiseError=True):
    if os.path.exists(string):
        return string

    if raiseError:
        raise FileNotFoundError(string)


def is_valid_url(url: str) -> bool:
    """Check if a given string is a valid URL using the provided regex."""
    regex = re.compile(
        r"^((https?|ftp|smtp):\/\/)?(www\.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*$",
        re.IGNORECASE,
    )
    return bool(regex.match(url))
