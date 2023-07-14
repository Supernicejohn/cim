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
	for i=1, #keys - 1 do
		if walk[keys[i]] and type(walk[keys[i]])
				== "table" then
			walk = walk[keys[i]]
		elseif walk[keys[i]] then
			error("Error in pkg loader manager!"..
				" Cannot overwrite package with a"..
				" new directory!")
		else
			walk[keys[i]] = {}
		end
	end
	if #keys == 1 then
		manager.pkgs[keys[1]] = manager.incl(path)
		return 
	end
	walk = manager.pkgs
	for i=1, #keys -1  do
		walk = walk[keys[i]]
	end
	walk[keys[#keys]] = manager.incl(path)
	
end

manager.incl = function(path)
	local pretty = ""
	local keys = {manager.split(path)}
	for i = 1, #keys do
		pretty = pretty..(i==#keys 
			and "" or ".")..keys[i]
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
			break
		end
		if i==#keys then
			found = true
		end
	end
	if found then
		return walk
	end
	if not strict then
		manager.getany(manager.pkgs, str)
	end
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
	for str in pathstr:gmatch("[^\.]+") do
		ordered[#ordered + 1] = str
	end
	return table.unpack(ordered)
end


return manager
