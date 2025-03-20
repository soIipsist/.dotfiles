if application "Music" is running then
    tell application "Music"
        if player state is playing then
            pause
        else
            play
        end if
    end tell
end if
