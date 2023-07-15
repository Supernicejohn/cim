local manager = {}
manager.pkgs = {}
manager._path = shell.dir()
manager._verbose = true

manager.addpkg = function(path)
	local pathstr = path:gsub("\/",".")
	local keys = {manager.split(path)}
	local walk = manager.pkgs
	if not keys or #keys == 0 then
		error("Error in pkg loader manager!"..
			" Cannot load pkg with no name")
	end
	for i=1, #keys do
		if walk[keys[i]] and type(walk[keys[i]])
				== "table" then
			walk = walk[keys[i]]
		--[==[elseif walk[keys[i]] then
			error("Error in pkg loader manager!"..
				" Cannot overwrite package with a"..
				" new directory!")]==]
		else
			walk[keys[i]] = {}
			walk = walk[keys[i]]
		end
	end
	if #keys == 1 then
		local tbl = manager.incl(path)
		for k,v in pairs(tbl) do
			manager.pkgs[keys[1]][k] = v
		end
		return
	end
	local tbl = manager.incl(path)
	for k,v in pairs(tbl) do
		walk[k] = v
	end
end

manager.incl = function(path)
	local pretty = ""
	local keys = {manager.split(path)}
	for i = 1, #keys do
		if i > 1 then
			pretty = pretty.."."..keys[i]
		else
			pretty = pretty..keys[i]
		end
	end
	if manager._verbose then
		print("Attempting to include pkg "..pretty)
	end
	local ok, val = pcall(require, path)
	if ok and manager._verbose then
		print("Included pkg "..pretty)
	elseif not ok then
		print("Failed to include pkg "..pretty)
	end
	if ok then
		if val.init then
			val.init()
		end
		return val
	else
		print(val)
	end
end

manager.explore = function()
	
end

manager.getpkg = function(str, strict)
	local keys = {manager.split(str)}
	local walk = manager.pkgs
	local found = false
	for i=1, #keys do
		if walk[keys[i]] then
			walk = walk[keys[i]]
		else
			walk[keys[i]] = {}
			walk = walk[keys[i]]
		end
		if i==#keys then
			found = true
		end
	end
	if found then
		return walk
	else
		
	end
	--[[if not strict then
		manager.getany(manager.pkgs, str)
	end]]
end

manager.getany = function(base, str)
	for k,v in pairs(base) do
		local pkg 
		if type(v) == "table" then
			pkg= manager.getpkg(k.."."..str, true)
			if pkg then
				return pkg
			end
		end
	end
	for k,v in pairs(base) do
		if type(v) == "table" then
			local pkg = manager.getany(v, str)
			if pkg then 
				print("WARNING: loaded unspecified: "..str)
				return pkg
			end
		end
	end
end

manager.split = function(pathstr)
	local ordered = {}
	local index = 1
	local last = 1
	while index <= #pathstr do
		if pathstr:sub(index, index) == "/" then
			ordered[#ordered + 1] = pathstr:sub(last, index - 1)
			last = index + 1
		elseif index == #pathstr then
			ordered[#ordered + 1] = pathstr:sub(last, index)
		end
		index = index + 1
	end
	return table.unpack(ordered)
end
manager.___split = function(pathstr)
	local ordered = {}
	for str in pathstr:gmatch("[^\.]+") do
		ordered[#ordered + 1] = str
	end
	return table.unpack(ordered)
end

manager.listpkgs = function()
	for k,v in pairs(manager.pkgs) do
		print("key "..k..": "..tostring(v))
		if type(v)=="table" then
			for a,b in pairs(v) do
				print("--- key "..a..": "..tostring(b))
			end
		end
	end
end

return manager
