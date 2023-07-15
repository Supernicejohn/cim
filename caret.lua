local c = {}
local var = manager.getpkg("var")
local config = manager.getpkg("config")
c.caret = {}

c.init = function()
	c.caret.x = 1
	c.caret.y = 1
	c.current_blink = true
	c.bgcol = colors.black
	c.fgcol = colors.white
end
c.start = function()
	c.start_blink()
end
c.start_blink = function()
	if c.blink_timer then
		os.stopTimer(c.blink_timer)
	end
	c.blink_timer = os.startTimer(0.4)
end
c.move = function(x,y)
	c.caret.x = c.caret.x + x
	c.caret.y = c.caret.y + y
end
c.set = function(x,y)
	c.caret.x = x
	c.caret.y = y
end
c.chk_move = function(x,y)
	if config.linewrap then
		return --TODO
	end
	if #t.text >= c.caret.y + y and c.caret.y + y > 0 then
		c.caret.y = c.caret.y + y
		if #t.text[c.caret.y]+1 < c.caret.x then
			c.caret.x = #t.text[c.caret.y]+1
		end
	end
	if #t.text[c.caret.y] + 1 >= c.caret.x + x and 0 < c.caret.x + x then
		c.caret.x = c.caret.x + x
	elseif c.caret.x + x > #t.text[c.caret.y] + 1 then
		c.caret.x = #t.text[c.caret.y] + 1
	else
		c.caret.x = 1
	end
end

return c
