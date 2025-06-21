import argparse
import os
import urllib3
from urllib.parse import urlparse
from pathlib import Path


def download(url: str, output_directory: str = None) -> int:
    http = urllib3.PoolManager()
    status_code = 0

    try:
        path = urlparse(url).path
        filename = os.path.basename(path) or "downloaded_file"

        # Determine output path
        output_dir = Path(output_directory) if output_directory else Path(".")
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / filename

        response = http.request("GET", url, preload_content=False)

        if response.status != 200:
            print(f"Failed to download {url}: HTTP {response.status}")
            return response.status

        with open(output_path, "wb") as f:
            for chunk in response.stream(1024):
                f.write(chunk)

        print(f"Downloaded: {url} → {output_path}")
        response.release_conn()

    except Exception as e:
        print(f"Error downloading {url}: {e}")
        status_code = 1

    return status_code


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download files using urllib3")
    parser.add_argument("urls", nargs="+", type=str, help="URLs to download")
    parser.add_argument(
        "-d",
        "--output_directory",
        type=str,
        default=None,
        help="Directory to save downloads",
    )

    args = vars(parser.parse_args())
    urls = args.get("urls")
    output_directory = args.get("output_directory")

    for url in urls:
        status = download(url, output_directory)
        if status != 0:
            print(f"Download failed for: {url}")
