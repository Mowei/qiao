local moduleName = ...
local M = {}
_G[moduleName] = M


M.OnlineVersion = ""
local tmrTime = 0
local function wait_upgrade()
  if config.UpgradeStatus == "YES" then
    tmr.stop(1)
    app =nil
    package.loaded['app'] = nil
    -- dosomething
    setup = require("setup")
    app = require("myMqtt")
    app.start()
    else
    print("upgrade waiting ...")
    tmrTime = tmrTime + 1
    if tmrTime>=10 then
        tmr.stop(1)
        tmrTime = 0
        node.restart()
    end
  end
end

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
    print("Download Upgrade... " .. config.ScriptUrl .. "Upgrade.lua")
	http.get(config.ScriptUrl .. "Upgrade.lua", nil, function(code, data)
    if (code < 0) then
        print("Upgrade.lua Download fail")
    else
        file.open("Upgrade.lua", 'w')
        file.writeline(data)
        file.close()
        upg = require("Upgrade")
		upg.install(M.OnlineVersion)
        upg =nil
        package.loaded ['upg'] = nil
    end
  end)
end

function M.CheckVersion()
http.get(config.ScriptUrl .. "Version", nil, function(code, data)
    if (code < 0 ) then
	return false;
    else
		--get online Version
		for k,v in pairs(sjson.decode(data)) do
			if( k== "Version") then Version = v end
		end
        M.OnlineVersion = Version
        print("online Version : "..Version)
		--read nodemcu Version
		fileExists,nowVersion=M.read_setting("Version")
      
		if(fileExists) then
            print("New Version : "..nowVersion)
			if(nowVersion ~= Version) then
				M.Upgrade()
             else
                config.UpgradeStatus = "YES"
			end
		else
            print("not install")
			M.Upgrade()
		end
    end
    tmr.alarm(1, 2500, 1, wait_upgrade)
  end)
end

function M.start()
    setup =nil
    package.loaded['setup'] = nil
    M.CheckVersion()
end

return M 