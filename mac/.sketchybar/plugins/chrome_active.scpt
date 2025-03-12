tell application "Google Chrome"
    tell the tab whose URL contains "youtube" of the front window
        execute javascript "document.getElementsByClassName('ytp-play-button ytp-button')[0].click();"
    end tell
end tell