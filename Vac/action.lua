local a = {}

a.vactions = {}

a.init = function()
	var.state = "normal"
end
a.escape = function()
	var.state = "normal"
	b.message("Normal")
end
a.movement = function(event)
	if event[1] == "key" and var.state ~= "text" then
		if event[2] == keys.k then
			c.chk_move(0, -1)
		elseif event[2] == keys.j then
			c.chk_move(0, 1)
		elseif event[2] == keys.h then
			c.chk_move(-1, 0)
		elseif event[2] == keys.l then
			c.chk_move(1, 0)
		end
	end
	if event[1] == "key" then
		if event[2] == keys.up then
			c.chk_move(0, -1)
		elseif event[2] == keys.down then
			c.chk_move(0, 1)
		elseif event[2] == keys.left then
			c.chk_move(-1, 0)
		elseif event[2] == keys.right then
			c.chk_move(1, 0)
		elseif event[2] == keys.pageUp then
			for i=1, w.screen.h do
				c.chk_move(0, -1)
			end
		elseif event[2] == keys.pageDown then
			for i=1, w.screen.h do
				c.chk_move(0, 1)
			end
		elseif event[2] == keys.home then
			c.chk_move(-999999, 0)
		elseif event[2] == keys["end"] then
			c.chk_move(999999, 0)
		end
	end
end
a.textkeys = function(event)
	if event[1] == "key" then
		if event[2] == keys.enter then
			t.enter()
		elseif event[2] == keys.backspace then
			t.backspace()
		elseif event[2] == keys.tab then
			t.tab()
		end
	end
end
a.control_keys = function(event)
	if event[1] == "key" then
		if event[2] == config.escape_key then
			a.escape()
			return true
		end
	end
	return false
end
a.buffer = function(event)
	if not a.buf then
		a.buf = ""
	end
	if event[1] == "char" then
		a.buf = a.buf..event[2]
	end
end
a.vmatch = function(buf, num) -- attempt to execute what's in buf
	if a.vactions[buf] then
		a.vactions[buf](num)
		a.buf = nil
		return
	end
	if buf:sub(1,1):find("%d") then
		local start = 1
		while buf:sub(start,start):find("%d") do
			start = start + 1
		end
		if buf:len() > start then
			a.vmatch(buf:sub(start, #buf), a.buf:sub(1, start - 1))
			return
		end
	end
	for k,v in pairs(a.vactions) do
		if k:sub(1, #buf) == buf then
			return
		end
	end
	a.buf = nil -- no valid matching
end
a.vkeys = function(event)
	if event[1] == "char" then
		a.buffer(event)
		a.vmatch(a.buf)
	end
end
a.normal = function(event)
	if event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
	elseif event[1] == "char" then
		--if event[2] == "i" then
			--var.state = "text"
		if event[2] == ":" then
			var.state = "command"
		elseif event[2] == "v" then
			var.state = "visual"
		else
			a.vkeys(event)
		end
	end
end
a.text = function(event)
	if event[1] == "char" then
		t.write(event[2], c.caret)
	elseif event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
		a.textkeys(event)
	end
end
a.visual = function(event)
	--TODO
	if event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
	end
end
a.command = function(event)
	b.message(":"..b.history[1])
	if event[1] == "key" then
		if a.control_keys(event) then
			table.insert(b.history, 1, "")
			return
		end
		if event[2] == keys.enter then
			b.run()
			table.insert(b.history, 1, "")
			var.state = "normal"
			return
		elseif event[2] == keys.backspace then
			if #b.history[1] == 0 then
				var.state = "normal"
			end
			b.history[1] = b.history[1]:sub(1, #b.history[1]-1)
			return
		end
	elseif event[1] == "char" then
		b.history[1] = b.history[1]..event[2]
	end
end
a.yield = function()
	--w.render_bar()
	local e = {coroutine.yield()}
	if e[1] == "terminate" then
		b.message("Use ':q!' to exit")
	elseif e[1] == "timer" then
		if e[2] == c.blink_timer then
			c.current_blink = not c.current_blink
			c.blink_timer = nil
			c.start_blink()
		end
	elseif a[var.state] then
		a[var.state](e)
	end
	local stext = var.state_text[var.state] or ""
	if var.state ~= "command" then
		local caret_str = c.caret.x..":"..c.caret.y
		local str = stext..w.msg_str:sub(#stext+1, 
			w.screen.w - #caret_str - 3)..caret_str
		b.message(str)
	end
end

-- basic v actions, to be redone later --

a.vactions.zz = function()
	w.screen.y = c.caret.y - math.floor(w.screen.h / 2)
	if w.screen.y < 1 then
		w.screen.y = 1
	end
end
a.vactions.o = function()
	var.state = "text"
	c.caret.y = c.caret.y + 1
	c.caret.x = 1
	table.insert(t.text, c.caret.y, "")
end
a.vactions.O = function()
	var.state = "text"
	c.caret.x = 1
	if c.caret.y > 1 then
		table.insert(t.text, c.caret.y - 1, "")
	elseif c.caret.y == 1 then
		table.insert(t.text, 1, "")
	end
end
a.vactions.A = function()
	var.state = "text"
	c.caret.x = #t.text[c.caret.y] + 1
end
a.vactions.a = function()
	var.state = "text"
	c.caret.x = c.caret.x + 1
	if c.caret.x > #t.text[c.caret.y] + 1 then
		c.caret.x = #t.text[c.caret.y] + 1
	end
end
a.vactions.i = function()
	var.state = "text"
end
a.vactions.I = function()
	var.state = "text"
	c.caret.x = 1
end
a.vactions.dd = function(num)
	if t.text[c.caret.y] then
		table.remove(t.text, c.caret.y)
		if #t.text < c.caret.y and #t.text > 0 then
			c.caret.y = c.caret.y - 1
		elseif #t.text == 1 then
			t.text[1] = "" -- not quite right, but close			
		end
	end
	if num and num > 0 then
		a.vactions.dd(num - 1)
	end
end
a.vactions.x = function()
	if t.text[c.caret.y] then
		if #t.text[c.caret.y]:sub(c.caret.x, c.caret.x) > 0 then
			t.text[c.caret.y] = t.text[c.caret.y]:sub(
				1, c.caret.x - 1)..t.text[c.caret.y]:sub(
				c.caret.x + 1, #t.text[c.caret.y])
		elseif #t.text > c.caret.y then
			local line = t.text[c.caret.y + 1]
			table.remove(t.text, c.caret.y + 1)
			t.text[c.caret.y] = t.text[c.caret.y]..line
		end
	end
end
a.vactions.w = function()
	if not t.text[c.caret.y] then
		error("???")
		return
	end
	local x = c.caret.x
	local y = c.caret.y
	local mode = false
	local found = false
	while y <= #t.text do
		while x <= #t.text[y] do
			local char = t.text[y]:sub(x,x)
			if not mode then
				if (char ~= " " and char ~= "\t") then
					--do nothing, just increment
				else
					mode = true
				end 
			else
				if (char ~= " " or char ~= "\t") then
					found = true
					break
				end
			end
			x = x + 1
		end
		if found then
			break
		end
		x = 1
		y = y + 1
	end
	if t.text[y] and #t.text[y] + 2 < x then
		--error("y = "..y..", x = "..x)
		c.caret.y = y
		c.caret.x = x
	else
		--error("y = "..y..", x = "..x)
	end
end
a.vactions.gg = function()
	c.caret.y = 1
end
a.vactions.G = function()
	c.caret.y = #t.text
end
return a
