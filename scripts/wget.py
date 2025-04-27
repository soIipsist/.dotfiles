import argparse
import subprocess


def download(urls: list, output_directory: str = None):
    for url in urls:
        try:
            print("Downloading with wget...")

            cmd = (
                ["wget", "-P", output_directory, url]
                if output_directory
                else ["wget", url]
            )

            result = subprocess.run(cmd, capture_output=True, text=True)
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
        except KeyboardInterrupt:
            print("\nDownload interrupted by user.")
            download_stopped = True

        except subprocess.CalledProcessError as e:
            print(f"\nDownload failed: {e}")
            download_stopped = True

        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            download_stopped = True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-d", "--output_directory", type=str, default=None)

    args = vars(parser.parse_args())

    download(**args)
