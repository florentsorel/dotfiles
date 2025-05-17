local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrainsMono Nerd Font", { bold = false, italic = false })
config.font_size = 14.0

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 0.9

return config
