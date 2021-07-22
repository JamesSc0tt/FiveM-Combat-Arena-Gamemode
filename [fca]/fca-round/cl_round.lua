local round_active = false
local seconds = 0
local active_map = 0
local active_gm = 0

local mapdata = {
	[1] = { -- bolingbroke
		center = { x = 1694.250, y = 2598.964, z = 45.56 },
		range = 300.0
	},
	[2] = { -- humane labs
		center = { x = 3524.551, y = 3704.953, z = 36.6172 },
		backupspawns = {
			{3574.70, 3784.83, 30.0}
		},
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
	print('sorting respawn for '..active_map)
	local map = mapdata[active_map]
	if not map then
		print('NO MAP '..active_map)
		active_map = 1
		map = mapdata[1]
	end

	TriggerEvent('FeedM:showNotification', 'Generating map scenery...')

	SetEntityCoords(GetPlayerPed(-1), map.center.x, map.center.y, map.center.z)
	FreezeEntityPosition(GetPlayerPed(-1),true)
	SetEntityAlpha(PlayerPedId(), 51, false)
	SetEntityInvincible(GetPlayerPed(-1), true)

	Citizen.Wait(3000)

	local coords = vector3(map.center.x, map.center.y, map.center.z)
	local range = map.range / 2 - 50
	local x = coords.x + math.random(-range, range)
	local y = coords.y + math.random(-range, range)

	local spawned = false

	FreezeEntityPosition(GetPlayerPed(-1),false)
	local count = 0
	while not spawned do
		Citizen.Wait(0)
		map = mapdata[active_map]
		local foundSafeCoords, safeCoords = GetSafeCoordForPed(x, y, coords.z, false , 16)
		if not foundSafeCoords then
			SetEntityCoords(GetPlayerPed(-1), map.center.x, map.center.y, map.center.z)
			TriggerEvent('FeedM:showNotification', '~y~Could not find safe coords!')
			count = count + 1
			if count >= 3 then
				-- use backup coords
				if map.backupspawns then
					local spawnloc = map.backupspawns[math.random(1, #map.backupspawns)]
					SetEntityCoords(GetPlayerPed(-1), spawnloc)
					TriggerEvent('FeedM:showNotification', '~r~USING PRESET SPAWN')
					spawned = true
					break
				else
					TriggerEvent('FeedM:showNotification', '~r~This map ('..active_map..') has no preset spawns, this will take longer...')
				end
			end
		else
			SetEntityCoords(GetPlayerPed(-1), safeCoords)
			TriggerEvent('FeedM:showNotification', '~g~Safe to spawn')
			spwaned = true
			break
		end
	end

	-- reset player
	TriggerEvent('FeedM:showNotification', 'Waiting for other players to spawn...')
	

	TriggerServerEvent('fca-round:spawned')
end

RegisterNetEvent('fca-round:start')
AddEventHandler('fca-round:start', function(items)
	print'fca-round:start'
	SetEntityInvincible(GetPlayerPed(-1), false)
	SetEntityAlpha(PlayerPedId(), 255, false)
	SetEntityMaxHealth(GetPlayerPed(-1), 200)
	SetEntityHealth(GetPlayerPed(-1), 200)
	SetPedArmour(GetPlayerPed(-1), 100)
	SetMaxHealthHudDisplay(200)
end)

RegisterNetEvent('fca-lobby:respawn')
AddEventHandler('fca-lobby:respawn', function(items)
	
end)

Citizen.CreateThread(function()
	-- body
	--ReSpawn()
end)

RegisterNetEvent('fca-round:loading')
AddEventHandler('fca-round:loading', function(map)
	print 'fca-round:loading'
	active_map = map
	local map = mapdata[map]
	--DoScreenFadeOut(1000)
	Citizen.Wait(500)
	TriggerEvent('fca-lobby:destroy')
	ReSpawn()
	Citizen.Wait(500)
	--DoScreenFadeIn(500)
end)


-- TriggerEvent('fca-round:loading', 1)
