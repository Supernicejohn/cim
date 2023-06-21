local a = {}

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
a.normal = function(event)
	if event[1] == "key" then
		if a.control_keys(event) then
			return
		end
		a.movement(event)
	elseif event[1] == "char" then
		if event[2] == "i" then
			var.state = "text"
		elseif event[2] == ":" then
			var.state = "command"
		elseif event[2] == "v" then
			var.state = "visual"
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

return a
