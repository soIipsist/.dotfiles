# inspect currently open google chrome tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver import ChromeService
import subprocess

# open chrome in debugging mode
cmd = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "--remote-debugging-port=9222",
    "--user-data-dir=/tmp/chrome-debug",
]
chrome_profile_path = ""
cmd = r'xcopy "%LOCALAPPDATA%\Google\Chrome\User Data\Default" C:\TempProfile /E /I /H /C /K /O /X'

# Execute the command
try:
    result = subprocess.run(
        cmd,
        shell=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    print(result.stdout)
except subprocess.CalledProcessError as e:
    print("Error occurred:")
    print(e.stderr)

chromedriver_path = "/opt/homebrew/bin/chromedriver"
chrome_options = Options()
chrome_options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")
service = ChromeService(chromedriver_path)

driver = webdriver.Chrome(options=chrome_options, service=service)
driver.get("https://www.google.com")
# Get the HTML content of the current page
html = driver.execute_script("return document.documentElement.outerHTML;")
print(html)

# Close the browser
driver.quit()
