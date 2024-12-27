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


def get_default_chrome_profile_path(profile_name: str = "Default"):
    if os.name == "nt":  # Windows
        local_appdata = os.getenv("LOCALAPPDATA")
        if local_appdata:
            return os.path.join(
                local_appdata, "Google", "Chrome", "User Data", profile_name
            )
        else:
            raise EnvironmentError(
                "LOCALAPPDATA environment variable not found on Windows."
            )

    elif os.name == "posix":  # macOS and Linux
        # Check if it's macOS
        if os.path.exists(
            os.path.expanduser(
                f"~/Library/Application Support/Google/Chrome/{profile_name}"
            )
        ):
            return os.path.expanduser(
                f"~/Library/Application Support/Google/Chrome/{profile_name}"
            )
        # Otherwise, assume Linux
        return os.path.expanduser(f"~/.config/google-chrome/{profile_name}")

    else:
        raise NotImplementedError(f"Unsupported operating system: {os.name}")


def launch_chrome_in_debugging_mode(
    chrome_path: str,
    chrome_profile_path: str,
    remote_debugging_port: str,
    user_data_dir: str,
):
    cmd = [chrome_path]

    cmd.append(f"--user-data-dir={user_data_dir}")
    cmd.append(f"--profile-directory={chrome_profile_path}")
    cmd.append(f"--remote-debugging-port={remote_debugging_port}")
    cmd.append("--disable-application-cache")
    cmd.append("--no-referrers")
    cmd.append("--restore_last_session")
    print(cmd)
    return execute_command(cmd)


def execute_command(cmd: list):
    output = None
    try:
        result = subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        output = result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print("Error occurred:")
        print(e.stderr)

    return output


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
    parser.add_argument("-n", "--profile_name", default="Profile 1", type=str)
    parser.add_argument("-u", "--user_data_dir", default="/tmp/chrome-debug")
    parser.add_argument("-r", "--remote_debugging_port", default="9222")

    args = vars(parser.parse_args())
    chrome_path = args.get("chrome_path")
    chromedriver_path = args.get("chromedriver_path")
    chrome_profile_path = args.get("chrome_profile_path")
    profile_name = args.get("profile_name")
    remote_debugging_port = args.get("remote_debugging_port")
    user_data_dir = args.get("user_data_dir")
    chrome_profile_path = os.path.join(
        os.path.dirname(chrome_profile_path), profile_name
    )

    print(chrome_profile_path)
    launch_chrome_in_debugging_mode(
        chrome_path, chrome_profile_path, remote_debugging_port, user_data_dir
    )

    chrome_options = Options()
    chrome_options.add_experimental_option(
        "debuggerAddress", f"127.0.0.1:{remote_debugging_port}"
    )
    service = ChromeService(chromedriver_path)
    driver = webdriver.Chrome(options=chrome_options, service=service)
    html = driver.execute_script("return document.documentElement.outerHTML;")

    # driver.quit()
