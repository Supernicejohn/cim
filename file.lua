local file = {}
local var = manager.getpkg("var")

file.init = function()
	file.files = {}
	file.edited = {}
	file.active = 1
	if #var.args > 0 then
		file.files[1] = file.open(var.args[1], true)
		if not file.files[1] then
			file.files[1] = file.new(var.args[1], true)
		end
		file.edited[1] = false
	end
end
file.new = function(path, rel)
	if not path or #path==0 then
		path = "_new"
	end
	if rel then
		path = fs.combine(shell.dir(), path)
	end
	return path
end
file.open = function(path, rel)
	if not path or #path==0 then
		std.err("could not open <empty>")
		return
	end
	if (rel) then
		path = fs.combine(shell.dir(), path)
	end
	local file = fs.open(path, "r")
	if not file then
		std.err("could not open <"..path..">")
		return
	end
	t.text = {}
	while true do
		local line = file.readLine()
		if not line then
			break
		end
		t.text[#t.text+1] = line
	end
	file.close()
	if #t.text == 0 then
		t.text[1] = ""
	end
	return path --absolute path
end
file.save = function(path, rel)
	if not path or #path==0 then
		std.err("could not save to <empty>")
		return
	end
	if (rel) then
		path = fs.combine(path, shell.dir())
	end
	local f = fs.open(path, "w")
	if not f then
		std.err("could not save to <"..path..">")
		return
	end
	for i=1, #t.text do
		f.write(t.text[i]..config.newline)
	end
	f.close()
end

return file
