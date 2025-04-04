#!/usr/bin/env python3
import iterm2
import os
import subprocess


def get_env_vars():
    shell = os.environ.get("SHELL", "/bin/bash")  # Get the current shell
    result = subprocess.run([shell, "-c", "env"], capture_output=True, text=True)
    env_vars = {}
    for line in result.stdout.splitlines():
        key, _, value = line.partition("=")
        env_vars[key] = value
    return env_vars


async def hex_to_rgb(hex_color: str):
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


async def set_theme(profile: iterm2.Profile):
    iterm2_vars = {
        "ITERM2_NORMAL_FONT": profile.async_set_normal_font,
        "ITERM2_NON_ASCII_FONT": profile.async_set_non_ascii_font,
        "ITERM2_FOREGROUND": profile.async_set_foreground_color,
        "ITERM2_BACKGROUND": profile.async_set_background_color,
        "ITERM2_SELECTION_COLOR": profile.async_set_selection_color,
        "ITERM2_SELECTED_TEXT_COLOR": profile.async_set_selected_text_color,
        "ITERM2_LINK_COLOR": profile.async_set_link_color,
        "ITERM2_ANSI_BLACK": profile.async_set_ansi_0_color,
        "ITERM2_ANSI_RED": profile.async_set_ansi_1_color,
        "ITERM2_ANSI_GREEN": profile.async_set_ansi_2_color,
        "ITERM2_ANSI_YELLOW": profile.async_set_ansi_3_color,
        "ITERM2_ANSI_BLUE": profile.async_set_ansi_4_color,
        "ITERM2_ANSI_MAGENTA": profile.async_set_ansi_5_color,
        "ITERM2_ANSI_CYAN": profile.async_set_ansi_6_color,
        "ITERM2_ANSI_WHITE": profile.async_set_ansi_7_color,
        "ITERM2_ANSI_BRIGHT_BLACK": profile.async_set_ansi_8_color,
        "ITERM2_ANSI_BRIGHT_RED": profile.async_set_ansi_9_color,
        "ITERM2_ANSI_BRIGHT_GREEN": profile.async_set_ansi_10_color,
        "ITERM2_ANSI_BRIGHT_YELLOW": profile.async_set_ansi_11_color,
        "ITERM2_ANSI_BRIGHT_BLUE": profile.async_set_ansi_12_color,
        "ITERM2_ANSI_BRIGHT_MAGENTA": profile.async_set_ansi_13_color,
        "ITERM2_ANSI_BRIGHT_CYAN": profile.async_set_ansi_14_color,
        "ITERM2_ANSI_BRIGHT_WHITE": profile.async_set_ansi_15_color,
        "ITERM2_BADGE_COLOR": profile.async_set_badge_color,
        "ITERM2_BOLD_COLOR": profile.async_set_bold_color,
        "ITERM2_CURSOR_COLOR": profile.async_set_cursor_color,
        "ITERM2_CURSOR_TEXT_COLOR": profile.async_set_cursor_text_color,
        "ITERM2_CURSOR_GUIDE_COLOR": profile.async_set_cursor_guide_color,
        "ITERM2_TAB_COLOR": profile.async_set_tab_color,
    }

    for key, func in iterm2_vars.items():
        # check if environment variable exists
        env_vars = get_env_vars()
        iterm_value = env_vars.get(key, None)

        if key == "ITERM2_BACKGROUND":
            print("BG", iterm_value)

        # print(iterm_value)
        if iterm_value:
            if iterm_value.startswith("#"):
                color_tuple = await hex_to_rgb(iterm_value)
                iterm_value = iterm2.Color(
                    color_tuple[0], color_tuple[1], color_tuple[2], 255
                )

            await func(iterm_value)
    # await profile.async_set_background_color(iterm2.Color(0, 0, 0, 255))


async def main(connection):
    app = await iterm2.async_get_app(connection)
    session = app.current_window.current_tab.current_session

    profile = await session.async_get_profile()
    await set_theme(profile)


iterm2.run_until_complete(main)
