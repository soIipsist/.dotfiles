tell application "Google Chrome"
    -- Get the first window
    set frontWindow to front window
    
    -- Loop through all tabs in the front window
    repeat with t in tabs of frontWindow
        -- Get the URL of each tab
        set tabURL to URL of t
        
        -- Check if the URL contains "youtube"
        if tabURL contains "music.youtube" then
            -- Execute JavaScript on the matching tab
            tell t to execute javascript "document.getElementsByClassName('ytp-play-button ytp-button')[0].click();"
            exit repeat  -- Exit the loop after the first match
        end if
    end repeat
end tell
