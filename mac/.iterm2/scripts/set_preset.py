#!/usr/bin/env python3

import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)
    session = app.current_window.current_tab.current_session
    profile = await session.async_get_profile()

    preset = await iterm2.ColorPreset.async_get(connection, "Dark Background")
    await profile.async_set_color_preset(preset)


iterm2.run_until_complete(main)
