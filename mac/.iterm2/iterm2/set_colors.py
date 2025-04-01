#!/usr/bin/env python3
import sys
import iterm2
import os


def hex_to_rgb(hex_color: str):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4)) + (255,)


async def set_colors(profile: iterm2.Profile):
    iterm2_vars = {
        key: value for key, value in os.environ.items() if key.startswith("ITERM2_")
    }

    ansi_0_color = os.environ.get("ITERM2_")
    colors = os.environ.get("")
    # profile.async_set_ansi_0_color()


async def main(connection):
    app = await iterm2.async_get_app(connection)
    session = app.current_window.current_tab.current_session
    profile = await session.async_get_profile()
    await set_colors(profile)

    # iterm2.run_until_complete(main)


print(hex_to_rgb("#0000000"))
