local moduleName = ...
local M = {}
_G[moduleName] = M

M.OnlineVersion = ""

M.Downloads=0
M.Files=2
M.List = {}
M.List[0] = "myMqtt.lua"
M.List[1] = "telnet.lua"

function M.save_setting(name, value)
  file.open(name, 'w') 
  file.writeline(value)
  file.close()
end

function M.Download(url,fileName)
    print("Downloading " .. url)
    http.get(url, nil, function(code, data)
        if (code < 0) then
        else
            file.open(fileName, 'w')
            file.writeline(data)
            file.close()
            M.Downloads = M.Downloads +1
            M.status()
        end
    end)
end

function M.status()
    path = config.ScriptUrl .. "Upgrade/"
    print("Download...")
    if(M.Files==M.Downloads) then
        print("set Version...")
        M.save_setting("Version", M.OnlineVersion)
        config.UpgradeStatus ="YES"
    else
        M.Download(path .. M.List[M.Downloads],M.List[M.Downloads])
    end
end
function M.install(Version)
    app =nil
    package.loaded['app'] = nil
    M.OnlineVersion = Version
    print("install Version: ".. Version)
    M.status()
end

return M 