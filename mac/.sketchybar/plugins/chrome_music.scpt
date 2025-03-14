tell application "Google Chrome"
    -- Get the first window
    set frontWindow to front window
    
    -- Loop through all tabs in the front window
    repeat with t in tabs of frontWindow
        -- Get the URL of each tab
        set tabURL to URL of t
        
        -- Check if the URL contains "music.youtube"
        if tabURL contains "music.youtube" then
            -- Execute JavaScript on the matching tab using the provided XPath
            tell t to execute javascript "
                var playPauseButton = document.evaluate('/html/body/ytmusic-app/ytmusic-app-layout/ytmusic-player-bar/div[1]/div/tp-yt-paper-icon-button[3]/tp-yt-iron-icon', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                if (playPauseButton) { playPauseButton.click(); }
            "
            exit repeat  -- Exit after finding the first match
        end if
    end repeat
end tell
