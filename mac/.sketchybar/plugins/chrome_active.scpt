if application "Google Chrome" is running then
    tell application "Google Chrome"
        tell active tab of the front window
            execute javascript "document.getElementsByClassName('ytp-play-button ytp-button')[0].click();"
        end tell
    end tell
end if