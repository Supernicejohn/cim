local t = {}

t.init = function()
	t.text = {}
	t.text[1] = ""
end
t.vis_line = function(n)
	if t.text and t.text[n] then
	   return t.text[n]
	else
	   return config.empty_line_fill
	end
end
t.write = function(str, caret)
	if not str or not caret then
	   return
	end
	file.edited[file.active] = true
	if not t.text[caret.y] or #t.text[caret.y]+1 < caret.x then
	   return
	end
	t.text[caret.y] = t.text[caret.y]:sub(1,caret.x-1)..str..
			t.text[caret.y]:sub(caret.x,#t.text[caret.y])
	caret.x = caret.x + #str
end
t.remove = function(caret1, caret2, mode)
	if caret1.y > caret2.y then
		return
	elseif caret1.y == caret2.y and caret1.x > caret2.x then
		return
	end
	-- straight-through mode
	-- TODO: test
	if mode == "straight" then
		local y = caret1.y
		local first = t.text[y]:sub(1, caret1.x)
		while y < caret2.y do
			if caret1.y < y and y < caret2.y then
				table.remove(t.text, y)
				caret2.y = caret2.y - 1
			end
			if y == caret2.y then
				t.text[y] = t.text[y]:sub(caret2.x, #t.text[y])
				t.text[y] = first..t.text[y]
			end
		end
	end
end
t.backspace = function()
	if c.caret.x == 1 and c.caret.y == 1 then
		return
	elseif c.caret.x == 1 then
		local len = #t.text[c.caret.y-1]
		t.text[c.caret.y-1] = t.text[c.caret.y-1]..t.text[c.caret.y]
		table.remove(t.text, c.caret.y)
		c.caret.y = c.caret.y - 1
		c.caret.x = len+1
	else
		t.text[c.caret.y] = t.text[c.caret.y]:sub(1, c.caret.x-2)..
				t.text[c.caret.y]:sub(c.caret.x, #t.text[c.caret.y])
		c.caret.x = c.caret.x - 1
	end
end
t.enter = function()
	local line = t.text[c.caret.y]:sub(c.caret.x, #t.text[c.caret.y])
	t.text[c.caret.y] = t.text[c.caret.y]:sub(1, c.caret.x-1)
	table.insert(t.text, c.caret.y+1, line)
	c.caret.x = 1
	c.caret.y = c.caret.y + 1
end
t.delete = function()
	--TODO
end

return t
