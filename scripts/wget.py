import argparse
import subprocess


def download(url: str, output_directory: str = None):
    status_code = 0
    try:
        print("Downloading with wget...")

        cmd = (
            ["wget", "-P", output_directory, url] if output_directory else ["wget", url]
        )

        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print("STDOUT:", result.stdout)
        print("STDERR:", result.stderr)
    except KeyboardInterrupt:
        print("\nDownload interrupted by user.")
        status_code = 1

    except subprocess.CalledProcessError as e:
        print(f"\nDownload failed: {e}")
        status_code = 1

    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        status_code = 1

    return status_code


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-d", "--output_directory", type=str, default=None)

    args = vars(parser.parse_args())

    urls = args.get("urls")
    output_directory = args.get("output_directory")

    for url in urls:
        status = download(url, output_directory)
