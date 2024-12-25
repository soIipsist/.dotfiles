# inspect currently open google chrome tab
import argparse
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver import ChromeService
import subprocess
import os
import shutil


def get_default_chrome_executable_path():
    if os.name == "nt":  # Windows
        possible_paths = [
            os.path.join(
                os.getenv("ProgramFiles(x86)"),
                "Google",
                "Chrome",
                "Application",
                "chrome.exe",
            ),
            os.path.join(
                os.getenv("ProgramFiles"),
                "Google",
                "Chrome",
                "Application",
                "chrome.exe",
            ),
            os.path.join(
                os.getenv("LOCALAPPDATA"),
                "Google",
                "Chrome",
                "Application",
                "chrome.exe",
            ),
        ]
        for path in possible_paths:
            if path and os.path.exists(path):
                return path
        raise FileNotFoundError("Google Chrome executable not found on Windows.")

    elif os.name == "posix":
        # Check macOS first
        mac_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        if os.path.exists(mac_path):
            return mac_path

        # Check Linux paths
        linux_paths = [
            shutil.which("google-chrome"),
            shutil.which("chrome"),
            "/usr/bin/google-chrome",
            "/usr/local/bin/google-chrome",
            "/snap/bin/chromium",
        ]
        for path in linux_paths:
            if path and os.path.exists(path):
                return path

        raise FileNotFoundError("Google Chrome executable not found on macOS/Linux.")

    else:
        raise FileNotFoundError("Google Chrome executable not found")


def get_default_chrome_profile_path():
    if os.name == "nt":  # Windows
        local_appdata = os.getenv("LOCALAPPDATA")
        if local_appdata:
            return os.path.join(
                local_appdata, "Google", "Chrome", "User Data", "Default"
            )
        else:
            raise EnvironmentError(
                "LOCALAPPDATA environment variable not found on Windows."
            )

    elif os.name == "posix":  # macOS and Linux
        # Check if it's macOS
        if os.path.exists(
            os.path.expanduser("~/Library/Application Support/Google/Chrome/Default")
        ):
            return os.path.expanduser(
                "~/Library/Application Support/Google/Chrome/Default"
            )
        # Otherwise, assume Linux
        return os.path.expanduser("~/.config/google-chrome/Default")

    else:
        raise NotImplementedError(f"Unsupported operating system: {os.name}")


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-c",
        "--chrome_path",
        type=str,
        default=get_default_chrome_executable_path(),
    )
    parser.add_argument(
        "-d", "--chromedriver_path", type=str, default="/opt/homebrew/bin/chromedriver"
    )
    parser.add_argument(
        "-p",
        "--chrome_profile_path",
        type=str,
        default=get_default_chrome_profile_path(),
    )
    parser.add_argument("-u", "--user_data_dir", default="/tmp/chrome-debug")
    parser.add_argument("-r", "--remote_debugging_port", default="9222")

    args = vars(parser.parse_args())
    chrome_path = args.get("chrome_path")
    chromedriver_path = args.get("chromedriver_path")
    chrome_profile_path = args.get("chrome_profile_path")
    remote_debugging_port = args.get("remote_debugging_port")
    user_data_dir = args.get("user_data_dir")

    # open chrome in debugging mode
    cmd = [
        chrome_path,
        f"--remote-debugging-port={remote_debugging_port}",
        f"--user-data-dir={user_data_dir}",
    ]

    # cmd = r'cp -r "%LOCALAPPDATA%\Google\Chrome\User Data\Default" C:\TempProfile /E /I /H /C /K /O /X'

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
