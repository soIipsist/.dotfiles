import os
import time
import argparse
import difflib


def get_mtime(path):
    return os.path.getmtime(path)


def read_file(path):
    with open(path, "r") as f:
        return f.readlines()


def main(downloads_path: str = None):
    if not os.path.exists(downloads_path) or not downloads_path:
        print(f"{downloads_path} does not exist.")
        return

    last_mtime = get_mtime(downloads_path)
    last_content = read_file(downloads_path)

    while True:
        time.sleep(1)
        try:
            current_mtime = get_mtime(downloads_path)
            if current_mtime != last_mtime:
                current_content = read_file(downloads_path)
                print(f"\n{downloads_path} changed at {time.ctime(current_mtime)}")
                diff = difflib.unified_diff(
                    last_content,
                    current_content,
                    fromfile="before.txt",
                    tofile="after.txt",
                    lineterm="",
                )

                # run downloader.py with added lines as params
                for line in diff:
                    print(line)
                last_mtime = current_mtime
                last_content = current_content
        except FileNotFoundError:
            print(f"{downloads_path} was deleted!")
            break


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f", "--file_path", default=os.environ.get("DOWNLOADER_PATH"), type=str
    )

    args = vars(parser.parse_args())
    main(**args)
