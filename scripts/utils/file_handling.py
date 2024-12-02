import json
import os


def read_file(file_path, encoding=None, errors=None):
    """
    Returns a file object.
    """
    try:
        with open(file_path, "r", encoding=encoding, errors=errors) as file:
            return file.read()
    except Exception as e:
        return f"An error occurred: {e}"


def read_json_file(json_file, errors=None):
    try:
        with open(json_file, "r", errors=errors) as file:
            json_object = json.load(file)
            return json_object
    except Exception as e:
        print(e)


def get_file_extension(file):
    return os.path.splitext(file)[1][1:]


def check_file_extension(choices, file_name):
    ext = get_file_extension(file_name)
    if ext not in choices or ext == "":
        raise Exception(
            "Invalid file extension. File doesn't end with one of {}".format(choices)
        )
    return file_name
