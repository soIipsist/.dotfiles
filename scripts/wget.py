import argparse
import subprocess


def download(url: str, output_directory: str = None):
    result = {"url": url, "status": 0}

    try:
        print("Downloading with wget...")

        cmd = (
            ["wget", "-P", output_directory, url] if output_directory else ["wget", url]
        )
        proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
        result["stdout"] = proc.stdout
        result["stderr"] = proc.stderr
    except subprocess.CalledProcessError as e:
        result["status"] = 1
        result["error"] = str(e)
    except Exception as e:
        result["status"] = 1
        result["error"] = f"Unexpected: {e}"

    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("urls", nargs="+", type=str)
    parser.add_argument("-d", "--output_directory", type=str, default=None)

    args = vars(parser.parse_args())

    urls = args.get("urls")
    output_directory = args.get("output_directory")

    for url in urls:
        status = download(url, output_directory)
