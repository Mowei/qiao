local moduleName = ...
local M = {}
_G[moduleName] = M

local waitCounts = 0

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
    waitCounts = waitCounts + 1
    if waitCounts>=250 then
        waitCounts = 0
        M.start()
    end
  else
    waitCounts = 0
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")

    app.start()
  end
end

local function wifi_start(list_aps)  
    if list_aps then
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                station_cfg={}
                station_cfg.ssid=key
                station_cfg.pwd=config.SSID[key]
                wifi.setmode(wifi.STATION);
                wifi.sta.config(station_cfg)
                wifi.sta.connect()
                print("Connecting to " .. key .. " ...")
                --config.SSID = nil  -- can save memory
                tmr.alarm(1, 2500, 1, wifi_wait_ip)
                print("Connected!")
            end
        end
    else
        print("Error getting AP list")
    end
end

function M.start()
    print("Configuring Wifi ...")
    wifi.setmode(wifi.STATION);
    wifi.sta.getap(wifi_start)
end

return M 
