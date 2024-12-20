# inspect currently open google chrome tab
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

chrome_options = Options()
chrome_options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")

chromedriver_path = "/opt/homebrew/bin/chromedriver"
driver = webdriver.Chrome(executable_path=chromedriver_path, options=chrome_options)

# Fetch the HTML of the current tab
html = driver.execute_script("return document.documentElement.outerHTML;")
print(html)
