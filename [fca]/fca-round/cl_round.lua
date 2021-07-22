local round_active = false
local seconds = 0
local active_map = 0
local active_gm = 0

local mapdata = {
	[1] = { -- bolingbroke
		center = { x = 1694.250, y = 2598.964, z = 45.56 },
		range = 300.0
	},
}

local in_area = true
local left_area = 0
local ooa_remaining = 30

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
			local max = mapdata[active_map].range / 2 + 2
			local warn = max - 20
			if dist > max then
				-- outside the area
				if in_area then
					in_area = false
					left_area = seconds
				end
				local remaining = left_area + ooa_remaining - seconds
				if remaining <= 0 then
					-- kill player

				end
				DrawMarker(1, mapdata[active_map].center.x,mapdata[active_map].center.y,mapdata[active_map].center.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, mapdata[active_map].range, mapdata[active_map].range, 10000000.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
				exports['fca-misc']:drawTxt(0.94, 1.30, 1.0, 1.0, 0.6, "~r~RETURN TO THE PLAY AREA", 255, 255, 255, 255)
				exports['fca-misc']:drawTxt(0.945, 1.35, 1.0, 1.0, 0.6, remaining.." SECONDS REMAINING", 255, 255, 255, 255)
			elseif dist > warn then
				in_area = true
				ooa_remaining = 30
				DrawMarker(1, mapdata[active_map].center.x,mapdata[active_map].center.y,mapdata[active_map].center.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, mapdata[active_map].range, mapdata[active_map].range, 10000000.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
			else
				in_area = true
				ooa_remaining = 30
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do Citizen.Wait(1000)
		seconds = seconds + 1 -- easiest way to do that
	end
end)

function ReSpawn()
	local map = mapdata[active_map]

	local coords = vector3(map.center.x, map.center.y, map.center.z)
	local range = map.range / 2 - 50
	local x = coords.x + math.random(-range, range)
	local y = coords.y + math.random(-range, range)

	local spawned = false

	FreezeEntityPosition(GetPlayerPed(-1),false)

	while not spawned do
		Citizen.Wait(0)
		local foundSafeCoords, safeCoords = GetSafeCoordForPed(x, y, coords.z, false , 16)
		if not foundSafeCoords then
			TriggerEvent('FeedM:showNotification', '~y~ Could not find safe coords!')
		else
			SetEntityCoords(GetPlayerPed(-1), safeCoords)
			TriggerEvent('FeedM:showNotification', '~g~Safe to spawn')
			spwaned = true
			break
		end
	end

	-- reset player
	SetEntityAlpha(PlayerPedId(), 51, false)
	FreezeEntityPosition(GetPlayerPed(-1),true)

	TriggerServerEvent('fca-round:spawned')
end

RegisterNetEvent('fca-round:loading')
AddEventHandler('fca-round:loading', function(map)
	active_map = map
	local map = mapdata[map]
	ReSpawn()
	Citizen.Wait(100)
end)


TriggerEvent('fca-round:loading', 1)
