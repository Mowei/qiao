local moduleName = ...
local M = {}
_G[moduleName] = M

function M.save_setting(name, value)
  file.open(name, 'w') 
  file.writeline(value)
  file.close()
end

function M.read_setting(name)
  if (file.open(name)~=nil) then
      result = string.sub(file.readline(), 1, -2) -- to remove newline character
      file.close()
      return true, result
  else
      return false, nil
  end
end

function M.Upgrade()
	http.get(config.ScriptUrl .. "Upgrade.lua", nil, function(code, data)
    if (code < 0) then
    else
        file.open("Upgrade.lua", 'w')
        file.writeline(data)
        file.close()
		dofile("Upgrade.lua")
		M.save_setting("Version", value)
    end
  end)
end

function M.CheckVersion()
http.get(config.ScriptUrl .. "Version", nil, function(code, data)
    if (code < 0) then
	return false;
    else
		--get online Version
		for k,v in sjson.decode(data) do
			if( k== "Version") then Version = v end
		end
		--read nodemcu Version
		fileExists,nowVersion=M.read_setting("Version")
		if(fileExists) then
			if(nowVersion ~= Version) then
				M.Upgrade()
			end
		else
			M.Upgrade()
		end

    end
  end)
end

function M.start()  
    M.CheckVersion()
end

return M 
