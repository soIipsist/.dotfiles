import os
import time
import argparse
import difflib


def get_mtime(path):
    return os.path.getmtime(path)


def read_file(path):
    with open(path, "r") as f:
        return f.readlines()


def main(FILE_PATH: str = None):
    if not os.path.exists(FILE_PATH) or not FILE_PATH:
        print(f"{FILE_PATH} does not exist.")
        return

    last_mtime = get_mtime(FILE_PATH)
    last_content = read_file(FILE_PATH)

    while True:
        time.sleep(1)
        try:
            current_mtime = get_mtime(FILE_PATH)
            if current_mtime != last_mtime:
                current_content = read_file(FILE_PATH)
                print(f"\n{FILE_PATH} changed at {time.ctime(current_mtime)}")
                diff = difflib.unified_diff(
                    last_content,
                    current_content,
                    fromfile="before.txt",
                    tofile="after.txt",
                    lineterm="",
                )
                for line in diff:
                    print(line)
                last_mtime = current_mtime
                last_content = current_content
        except FileNotFoundError:
            print(f"{FILE_PATH} was deleted!")
            break


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--file_path", default=os.environ.get("DOWNLOADER_PATH"), type=str
    )

    args = vars(parser.parse_args())
    main(**args)
