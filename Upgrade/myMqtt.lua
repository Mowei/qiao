local moduleName = ...
local M = {}
_G[moduleName] = M

M.status = "OFF"

function M.sendMsg(msg)
    if M.status == "ON" then
        m:publish(config.MyTopic, msg, 0,0, function(client) end)
    end
end

function M.mqtt_start()  
    -- Connect to broker
    m:connect(config.BROKER, config.PORT, config.QOS, config.RECONNECT, 
		function(client) 
			print("Connected!")
			print("Subscribing...")
			client:publish(config.MyTopic, config.ID .. " HELLO!", 0, 0, function(client)print("connected") end)
			client:subscribe(config.MyTopic, 0, 
				function(client) 
					M.status="ON"
					print("subscribe success") 
					print("Heap : " .. node.heap()) 
				end
			)
		end,
		function(client, reason)
			print("failed reason: " .. reason)
			setup.start() 
		end
	)
	-- on publish message receive event
	m:on("message", 
		function(client, topic, data) 
			print(topic .. ":" .. data )
            datas ={}
            for k,v in pairs(sjson.decode(data)) do
                if(k=="ID") then datas.ID = v end
                if(k=="CMD") then datas.CMD = v end
                if(k=="Data") then datas.Data = v end
            end
            if(tostring(datas.ID) == tostring(config.ID)) then
                if ( datas.CMD ~= nil and string.upper(datas.CMD) == "TELNET") then
                dofile("telnet.lua") 
                datas.msg = 'TELNET ON ' .. wifi.sta.getip()
                end
                if datas.msg ~= nil then
                    client:publish(config.MyTopic, '{"Result":"' .. datas.msg .. '"}', 0, 0, function(client) print("sent") end)
                end
            end
		end
	)

	-- This is part when wifi disconnects and I tested it for 5 minutes connecting wifi back and this works
	m:on("offline", function(client) 
		print ("Offline " .. config.ID) 
		setup.start()
	end)
    
	print("Connecting to broker...")
end

function M.start()
  print("Starting MQTT module...")
  -- initiate the mqtt client and set keepalive timer to 120sec
  m = mqtt.Client(config.ID, config.KEEPALIVE,  config.UN, config.PS)
  --m = mqtt.Client(config.ID, config.KEEPALIVE)
  m:lwt(config.MyTopic, "lwt : Offline " .. config.ID, 0, 0)
  M.mqtt_start()
end


return M
