local moduleName = ...
local M = {}
_G[moduleName] = M

M.SSID = {}  
M.SSID["WiFi-1"] = "Pass"
M.SSID["WiFi-2"] = "Pass"

M.ScriptUrl = "https://raw.githubusercontent.com/Mowei/qiao/master/"

M.MyTopic = "TEST/MyTopic"
M.BROKER = "m00.cloudmqtt.com"
M.ID = node.chipid()
M.UN = node.chipid()
M.PS = node.chipid()
M.RECONNECT = 0
M.QOS = 0
M.PORT = 15953
M.KEEPALIVE = 120

return M 
