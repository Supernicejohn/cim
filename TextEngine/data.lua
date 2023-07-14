local data = {}
local var = manager.getpkg("var")
-- data is caret 0-origin, visual is 1-origin
data.origin = 0

data.text = {}
data.current = 0
data.carets = {}


data.createc = function()
	local index = #data.carets + 1
	data.carets[index] = {
		x = 0,
		y = 0
	}
	return index
end
data.removec = function(index)
	if data.carets[index] then
		table.remove(data.carets, index)
	end
end
data.getc = function(index)
	return data.carets[index]
end

data.createt = function()
	local index = #data.text + 1
	data.text[index] = {}
	return index
end
data.gett = function()
	return data.text[data.current + 1]
end
-- write str at (location of (caret with (index)))
data.write = function(index, str)
	if not data.text[index] then
		error("Unexpected state")
		for i = 1, #data.carets do
			data.writec(index, str, data.carets[i])
		end
	end
end
-- TODO: multiline writes
data.writec = function(index, str, cindex)
	if not data.text[index] then
		error("Unexpected state")
	end
	local c = data.carets[cindex]
	local line = data.text[index][c.y + 1]
	line = line:sub(1, c.x)..str..line:sub(c.x + 1, #line)
	-- update other carets
	for i = 1, #data.carets do
		if i ~= cindex then
			if data.carets[i].y == c.y then
				if data.carets[i].x > c.x then
					data.carets[i].x = data.carets[i].x + #str
				end
			elseif data.carets[i].y > c.y then
				-- not necessary to update with single line only
			end
		end
	end
	data.carets[cindex].x = data.carets[cindex].x + #str
end


-- save/load integration
-- call every time you need a new iteration over the text (index)
data.getiter = function(index)
	return {
		line = 0,
		geteach = function()
			line = line + 1
			if data.text[index] and data.text[index][line] then
				return data.text[index][line]
			end
			return nil
		end,
		seteach = function(str)
			if data.text[index] then
				line = line + 1
				data.text[index][line] = str
			end
		end
	}
end

return data

