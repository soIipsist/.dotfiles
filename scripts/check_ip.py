import requests

try:
    response = requests.get("http://httpbin.org/ip", timeout=5)
    print("Your IP as seen by the server:", response.text)
except requests.RequestException as e:
    print("Error fetching IP:", e)
