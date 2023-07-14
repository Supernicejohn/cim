local config = {}

--### Default config ###
config.newline = "\n"
config.tabulate = "\t"
config.linewrap = false --TODO: testing this
config.blinking = true
config.text_color = colors.white
config.background_color = colors.black
config.escape_key = keys.leftCtrl
config.tab_disp = "   "
config.cursor_normal = string.char(127)
config.cursor_insert = "_"

--### End Default config ###

return config
