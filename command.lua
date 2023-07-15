local b = {
	history = {},
	text = ""
}
local var = manager.getpkg("var")
local file = manager.getpkg("file")
b.init = function()
	b.history[1] = ""
end
b.message = function(str)
	b.text = str
end
b.gettext = function()
	return b.text
end
b.run = function()
	--Interpret commands TODO
	local force = false
	local save = false
	local quit = false
	for i=1, #b.history[1] do
		local char = b.history[1]:sub(i,i)
		if char == "q" then
			quit = true
		elseif char == "w" then
			save = true
		elseif char == "!" then
			force = true
		end -- obviously not adequate for vim-like, but quick and easy
	end
	if save then
		if file.files[1] then
			file.save(file.files[1], false)
		end
	end
	if quit then
		--[[if file.changed[file.active] and not force then
			return
		end]]--
		var.exit = true
	end
end

return b
