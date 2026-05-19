on run argv
	tell application "System Events"
		tell dock preferences
			set autohide menu bar to item 1 of argv
		end tell
	end tell

	do shell script "killall SystemUIServer"
end run