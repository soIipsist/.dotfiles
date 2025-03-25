#!/usr/bin/env python3
import sys
import iterm2


async def main(connection):
    preset_name = sys.argv[1] if len(sys.argv) > 1 else "Dark Background"

    app = await iterm2.async_get_app(connection)
    session = app.current_window.current_tab.current_session
    profile = await session.async_get_profile()

    preset = await iterm2.ColorPreset.async_get(connection, preset_name)
    if preset:
        await profile.async_set_color_preset(preset)
    else:
        print(f"Error: Preset '{preset_name}' not found.")


iterm2.run_until_complete(main)
