from ytdlp import get_channel_info, download
from argparse import ArgumentParser
from pprint import PrettyPrinter
from downloader import Downloader, Download

pp = PrettyPrinter(indent=2)

downloader_names = [
    downloader.downloader_type for downloader in Downloader().select_all()
]


def download(
    channel_id: str,
    downloader: str = "ytdlp",
    sleep_interval: str = None,
    max_sleep_interval: str = None,
):

    if downloader is None:
        downloader = Downloader("ytdlp")

    downloader = Downloader(downloader_type=downloader).select_first()

    if not downloader:
        raise ValueError(f"Downloader of type {downloader} was not found.")

    downloader: Downloader

    results = get_channel_info(channel_id)
    video_urls = [
        f"https://www.youtube.com/watch?v={entry['id']}" for entry in results["entries"]
    ]

    downloads = [
        Download(
            url=video_url,
            downloader=downloader,
            extra_args=f"sleep_interval={sleep_interval}, max_sleep_interval={max_sleep_interval}",
        )
        for video_url in video_urls
    ]

    downloader.start_downloads(downloads)


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("channel_id", type=str)
    parser.add_argument(
        "-d", "--downloader", default="ytdlp_video", choices=downloader_names
    )
    parser.add_argument("-i", "--sleep_interval", default=None)
    parser.add_argument("-m", "--max_sleep_interval", default=None)

    args = parser.parse_args()
    download(
        args.channel_id, args.downloader, args.sleep_interval, args.max_sleep_interval
    )
