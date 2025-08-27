from ytdlp import get_channel_info
from argparse import ArgumentParser
from pprint import PrettyPrinter

pp = PrettyPrinter(indent=2)


def download(channel_id: str):

    results = get_channel_info(channel_id)
    video_urls = [
        f"https://www.youtube.com/watch?v={entry['id']}" for entry in results["entries"]
    ]

    for url in video_urls:
        print(url)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("channel_id", type=str)

    args = parser.parse_args()

    download(args.channel_id)
