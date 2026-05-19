on run argv
	set shouldHide to (item 1 of argv)

	if shouldHide is "true" then
		set shouldHide to true
	else
		set shouldHide to false
	end if

	tell application "System Events"
		tell dock preferences
			set autohide menu bar to shouldHide
		end tell
	end tell

	do shell script "killall SystemUIServer"
end run