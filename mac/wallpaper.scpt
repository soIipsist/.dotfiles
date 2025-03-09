on run argv
    tell application "System Events"
        tell every desktop
            set picture to item 1 of argv
        end tell
    end tell
end run