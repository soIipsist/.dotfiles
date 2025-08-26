from ytdlp import get_channel_info
from argparse import ArgumentParser
from pprint import PrettyPrinter

pp = PrettyPrinter(indent=2)


def download(channel_id: str):
    pass


if __name__ == "__main__":
    # parser = ArgumentParser()

    results = get_channel_info("@CodeProvider")
    pp.pprint(results)
