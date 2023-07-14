local w = {}

w.init = function()
	w.term = term.current()
	w.dimensions = {}
	w.screen = {}
	w.dimensions.w, w.dimensions.h = w.term.getSize()
	w.screen.x = 1
	w.screen.y = 1
	w.screen.w = w.dimensions.w
	w.screen.h = w.dimensions.h - 1
	w.text = window.create(w.term, 1, 1,
			w.dimensions.w, w.dimensions.h-1)
	w.bar = window.create(w.term, 1, w.dimensions.h,
			w.dimensions.w, 1)
	w.msg_str = ""
	for i=1, w.screen.w do
		w.msg_str = w.msg_str.." "
	end
	
end
w.keep_focus = function(mode)
	local xp, yp = w.get_caret_pos()
	if not mode then --default behavior
		while xp > (w.screen.x - 1 + w.screen.w) do
			w.screen.x = w.screen.x + 1;
		end
		while xp < (w.screen.x) do
			w.screen.x = w.screen.x - 1
		end
		while yp > (w.screen.y - 1 + w.screen.h) do
			w.screen.y = w.screen.y + 1
		end
		while yp < (w.screen.y) do
			w.screen.y = w.screen.y - 1
		end
	end
end
w.render = function()
	w.keep_focus()
	term.redirect(w.term)
	w.text.setVisible(true)
	w.bar.setVisible(true)
	w.draw_text()
	w.draw_bar()
	w.text.setVisible(false)
	w.bar.setVisible(false)
end
w.render_bar = function()
	w.bar.setVisible(true)
	w.draw_bar()
	term.redirect(w.term)
	w.bar.setVisible(false)
end
w.screen_line = function(n) --TODO: make scrolling work correctly
	local y = w.screen.y
	local line = ""
	if config.linewrap then
		local index = w.screen.y
		local line = t.text[index] --get first visible row on screen
		local sub = ""
		for i=1, w.screen.h do
			if #line == 0 then
				index = index + 1
				line = t.text[index]
			end
			sub = line:sub(1, w.screen.w)
			if i == n then
				return sub
			end
			if #line > #sub then
				line = line:sub(w.screen.w+1, #line)
			end
		end
	else
		if t.text[w.screen.y + n - 1] then
			line = t.text[w.screen.y + n - 1]
			line = line:gsub("\t", config.tab_disp)
			line = line:sub(w.screen.x, w.screen.x - 1 + w.screen.w)
			return line
		else
			return "~"
		end
	end
end
w.draw_text = function()
	term.redirect(w.text)
	for i=1, w.screen.h do
		term.setCursorPos(1,i)
		term.clearLine()
		term.write(w.screen_line(i)) -- logical screen line
	end
	w.draw_caret()
end
w.get_caret_pos = function()
	local line = t.text[c.caret.y]:sub(1, c.caret.x-1)
	line = line:gsub("\t", config.tab_disp)
	return #line+1, c.caret.y
end
w.draw_caret = function()
	term.redirect(w.text)
	local xp, yp = w.get_caret_pos()
	term.setCursorPos(xp - w.screen.x + 1, yp - w.screen.y + 1)
	local bgc = term.getBackgroundColor()
	term.setBackgroundColor(c.bgcol)
	local char = w.screen_line(c.caret.y-w.screen.y+1)
		:sub(xp-w.screen.x+1, xp-w.screen.x+1)
	if c.current_blink then
		if not char or #char == 0 then
			if var.state == "text" then
				char = config.cursor_insert
			else
				char = config.cursor_normal
			end
		end
		term.write(char)
	else
		if not char or #char == 0 then
			term.write(" ")
		else
			if var.state == "text" then
				char = config.cursor_insert
			else
				char = config.cursor_normal
			end
			term.write(char)
		end
	end
	term.setBackgroundColor(bgc)
end
w.draw_bar = function()
	term.redirect(w.bar)
	term.clearLine()
	term.setCursorPos(1,1)
	term.write(b.text)
end

return w
