import requests
from bs4 import BeautifulSoup
import sys


def get_links(url):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Error fetching {url}: {e}")
        return []

    soup = BeautifulSoup(response.text, "html.parser")

    links = []
    for a_tag in soup.find_all("a", href=True):
        links.append(a_tag["href"])

    return links


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    url = sys.argv[1]
    links = get_links(url)

    if links:
        print(f"Found {len(links)} links on {url}:")
        for link in links:
            print(link)
    else:
        print(f"No links found on {url}.")
