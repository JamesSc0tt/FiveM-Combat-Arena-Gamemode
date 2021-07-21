local round_active = true

local active_map = 1

local mapdata = {
	[1] = { -- bolingbroke
		center = { x = 1694.250, y = 2598.964, z = 45.56 },
		range = 300.0
	},
}

SetNuiFocus(false)

RegisterCommand('xyz', function()
	local xyz = GetEntityCoords(GetPlayerPed(-1))
	TriggerEvent('chat:addMessage', 'X: '..xyz.x)
	TriggerEvent('chat:addMessage', 'Y: '..xyz.y)
	TriggerEvent('chat:addMessage', 'Z: '..xyz.z)
end)

Citizen.CreateThread(function()
	while true do Citizen.Wait(0)
		if round_active then
			local dist =  GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), mapdata[active_map].center.x,mapdata[active_map].center.y,mapdata[active_map].center.z)
			local max = mapdata[active_map].range / 2
			local warn = max - 20
			if dist > max then
				-- outside the area
				DrawMarker(1, mapdata[active_map].center.x,mapdata[active_map].center.y,mapdata[active_map].center.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, mapdata[active_map].range, mapdata[active_map].range, 10000000.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
			elseif dist > warn then
				DrawMarker(1, mapdata[active_map].center.x,mapdata[active_map].center.y,mapdata[active_map].center.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, mapdata[active_map].range, mapdata[active_map].range, 10000000.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
			end
		end
	end
end)