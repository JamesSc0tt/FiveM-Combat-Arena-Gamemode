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

function isRoundActive()
	return round_active
end

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

AddEventHandler("playerSpawned", function()
  Citizen.CreateThread(function()
    local player = PlayerId()
    local playerPed = GetPlayerPed(-1)
    -- Enable pvp
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(playerPed, true, true)
  end)
end)

function RemoveWeaponDrops()
    local pickupList = {"PICKUP_AMMO_BULLET_MP","PICKUP_AMMO_FIREWORK","PICKUP_AMMO_FLAREGUN","PICKUP_AMMO_GRENADELAUNCHER","PICKUP_AMMO_GRENADELAUNCHER_MP","PICKUP_AMMO_HOMINGLAUNCHER","PICKUP_AMMO_MG","PICKUP_AMMO_MINIGUN","PICKUP_AMMO_MISSILE_MP","PICKUP_AMMO_PISTOL","PICKUP_AMMO_RIFLE","PICKUP_AMMO_RPG","PICKUP_AMMO_SHOTGUN","PICKUP_AMMO_SMG","PICKUP_AMMO_SNIPER","PICKUP_ARMOUR_STANDARD","PICKUP_CAMERA","PICKUP_CUSTOM_SCRIPT","PICKUP_GANG_ATTACK_MONEY","PICKUP_HEALTH_SNACK","PICKUP_HEALTH_STANDARD","PICKUP_MONEY_CASE","PICKUP_MONEY_DEP_BAG","PICKUP_MONEY_MED_BAG","PICKUP_MONEY_PAPER_BAG","PICKUP_MONEY_PURSE","PICKUP_MONEY_SECURITY_CASE","PICKUP_MONEY_VARIABLE","PICKUP_MONEY_WALLET","PICKUP_PARACHUTE","PICKUP_PORTABLE_CRATE_FIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR","PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL","PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW","PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE","PICKUP_PORTABLE_PACKAGE","PICKUP_SUBMARINE","PICKUP_VEHICLE_ARMOUR_STANDARD","PICKUP_VEHICLE_CUSTOM_SCRIPT","PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW","PICKUP_VEHICLE_HEALTH_STANDARD","PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW","PICKUP_VEHICLE_MONEY_VARIABLE","PICKUP_VEHICLE_WEAPON_APPISTOL","PICKUP_VEHICLE_WEAPON_ASSAULTSMG","PICKUP_VEHICLE_WEAPON_COMBATPISTOL","PICKUP_VEHICLE_WEAPON_GRENADE","PICKUP_VEHICLE_WEAPON_MICROSMG","PICKUP_VEHICLE_WEAPON_MOLOTOV","PICKUP_VEHICLE_WEAPON_PISTOL","PICKUP_VEHICLE_WEAPON_PISTOL50","PICKUP_VEHICLE_WEAPON_SAWNOFF","PICKUP_VEHICLE_WEAPON_SMG","PICKUP_VEHICLE_WEAPON_SMOKEGRENADE","PICKUP_VEHICLE_WEAPON_STICKYBOMB","PICKUP_WEAPON_ADVANCEDRIFLE","PICKUP_WEAPON_APPISTOL","PICKUP_WEAPON_ASSAULTRIFLE","PICKUP_WEAPON_ASSAULTSHOTGUN","PICKUP_WEAPON_ASSAULTSMG","PICKUP_WEAPON_AUTOSHOTGUN","PICKUP_WEAPON_BAT","PICKUP_WEAPON_BATTLEAXE","PICKUP_WEAPON_BOTTLE","PICKUP_WEAPON_BULLPUPRIFLE","PICKUP_WEAPON_BULLPUPSHOTGUN","PICKUP_WEAPON_CARBINERIFLE","PICKUP_WEAPON_COMBATMG","PICKUP_WEAPON_COMBATPDW","PICKUP_WEAPON_COMBATPISTOL","PICKUP_WEAPON_COMPACTLAUNCHER","PICKUP_WEAPON_COMPACTRIFLE","PICKUP_WEAPON_CROWBAR","PICKUP_WEAPON_DAGGER","PICKUP_WEAPON_DBSHOTGUN","PICKUP_WEAPON_FIREWORK","PICKUP_WEAPON_FLAREGUN","PICKUP_WEAPON_FLASHLIGHT","PICKUP_WEAPON_GRENADE","PICKUP_WEAPON_GRENADELAUNCHER","PICKUP_WEAPON_GUSENBERG","PICKUP_WEAPON_GOLFCLUB","PICKUP_WEAPON_HAMMER","PICKUP_WEAPON_HATCHET","PICKUP_WEAPON_HEAVYPISTOL","PICKUP_WEAPON_HEAVYSHOTGUN","PICKUP_WEAPON_HEAVYSNIPER","PICKUP_WEAPON_HOMINGLAUNCHER","PICKUP_WEAPON_KNIFE","PICKUP_WEAPON_KNUCKLE","PICKUP_WEAPON_MACHETE","PICKUP_WEAPON_MACHINEPISTOL","PICKUP_WEAPON_MARKSMANPISTOL","PICKUP_WEAPON_MARKSMANRIFLE","PICKUP_WEAPON_MG","PICKUP_WEAPON_MICROSMG","PICKUP_WEAPON_MINIGUN","PICKUP_WEAPON_MINISMG","PICKUP_WEAPON_MOLOTOV","PICKUP_WEAPON_MUSKET","PICKUP_WEAPON_NIGHTSTICK","PICKUP_WEAPON_PETROLCAN","PICKUP_WEAPON_PIPEBOMB","PICKUP_WEAPON_PISTOL","PICKUP_WEAPON_PISTOL50","PICKUP_WEAPON_POOLCUE","PICKUP_WEAPON_PROXMINE","PICKUP_WEAPON_PUMPSHOTGUN","PICKUP_WEAPON_RAILGUN","PICKUP_WEAPON_REVOLVER","PICKUP_WEAPON_RPG","PICKUP_WEAPON_SAWNOFFSHOTGUN","PICKUP_WEAPON_SMG","PICKUP_WEAPON_SMOKEGRENADE","PICKUP_WEAPON_SNIPERRIFLE","PICKUP_WEAPON_SNSPISTOL","PICKUP_WEAPON_SPECIALCARBINE","PICKUP_WEAPON_STICKYBOMB","PICKUP_WEAPON_STUNGUN","PICKUP_WEAPON_SWITCHBLADE","PICKUP_WEAPON_VINTAGEPISTOL","PICKUP_WEAPON_WRENCH"}
    local pedPos = GetEntityCoords(GetPlayerPed(PlayerId()), false)
    for a = 1, #pickupList do
        if IsPickupWithinRadius(GetHashKey(pickupList[a]), pedPos.x, pedPos.y, pedPos.z, 50.0) then
            RemoveAllPickupsOfType(GetHashKey(pickupList[a]))
        end
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)
		local playerLocalisation = GetEntityCoords(playerPed)
		ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)
		SetEveryoneIgnorePlayer(PlayerId(), 1)
		RemoveWeaponDrops()
		for i = 1, 12 do
			EnableDispatchService(i, false)
		end
		if GetPlayerWantedLevel(PlayerId()) ~= 0 then
			SetPlayerWantedLevel(PlayerId(), 0, false)
			SetPoliceIgnorePlayer(PlayerId(), true)
			SetDispatchCopsForPlayer(PlayerId(), false)
			SetPlayerWantedLevelNow(PlayerId(), false)
		end
		DisablePlayerVehicleRewards(PlayerId())
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

	TriggerEvent('fsn_inventory:items:emptyinv')
	SetEntityCoordsNoOffset(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(-1)), false, false, false, true)
	NetworkResurrectLocalPlayer(GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true, false)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	RemoveAllPedWeapons(GetPlayerPed(-1))
	ClearPlayerWantedLevel(PlayerId())

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
	if round_active then
		SetEntityAlpha(PlayerPedId(), 51, false)
		Citizen.Wait(100)
		SetEntityAlpha(PlayerPedId(), 255, false)
		Citizen.Wait(100)
		SetEntityAlpha(PlayerPedId(), 51, false)
		Citizen.Wait(100)
		SetEntityAlpha(PlayerPedId(), 255, false)
		Citizen.Wait(100)
		SetEntityAlpha(PlayerPedId(), 51, false)
		Citizen.Wait(100)
		SetEntityAlpha(PlayerPedId(), 255, false)

		SetEntityCoordsNoOffset(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(-1)), false, false, false, true)
		NetworkResurrectLocalPlayer(GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true, false)
		ClearPedTasksImmediately(GetPlayerPed(-1))
		RemoveAllPedWeapons(GetPlayerPed(-1))
		ClearPlayerWantedLevel(PlayerId())

		NetworkSetFriendlyFireOption(true)
	    SetCanAttackFriendly(GetPlayerPed(-1), true, true)

		SetEntityInvincible(GetPlayerPed(-1), false)
		SetEntityAlpha(PlayerPedId(), 255, false)
		SetEntityMaxHealth(GetPlayerPed(-1), 200)
		SetEntityHealth(GetPlayerPed(-1), 200)
		SetPedArmour(GetPlayerPed(-1), 100)
		SetMaxHealthHudDisplay(200)

	end
	TriggerServerEvent('fca-round:spawned')
end
RegisterNetEvent('fca-round:respawn')
AddEventHandler('fca-round:respawn', function()
	print'fca-round:respawn'
	ReSpawn()
end)

RegisterNetEvent('fca-round:start')
AddEventHandler('fca-round:start', function(items)
	print'fca-round:start'
	round_active = true
	-- respawn ped
	TriggerEvent('fsn_inventory:items:emptyinv')
	SetEntityCoordsNoOffset(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(-1)), false, false, false, true)
	NetworkResurrectLocalPlayer(GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true, false)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	RemoveAllPedWeapons(GetPlayerPed(-1))
	ClearPlayerWantedLevel(PlayerId())

	NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(GetPlayerPed(-1), true, true)

	SetEntityInvincible(GetPlayerPed(-1), false)
	SetEntityAlpha(PlayerPedId(), 255, false)
	SetEntityMaxHealth(GetPlayerPed(-1), 200)
	SetEntityHealth(GetPlayerPed(-1), 200)
	SetPedArmour(GetPlayerPed(-1), 100)
	SetMaxHealthHudDisplay(200)
end)

RegisterNetEvent('fca-round:end')
AddEventHandler('fca-round:end', function()
	round_active = false
end)

RegisterNetEvent('fca-lobby:respawn')
AddEventHandler('fca-lobby:respawn', function(items)
	SetEntityCoordsNoOffset(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(-1)), false, false, false, true)
	NetworkResurrectLocalPlayer(GetEntityCoords(GetPlayerPed(-1)), GetEntityHeading(GetPlayerPed(-1)), true, true, false)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	RemoveAllPedWeapons(GetPlayerPed(-1))
	ClearPlayerWantedLevel(PlayerId())
end)

Citizen.CreateThread(function()
	-- body
	--ReSpawn()
end)

RegisterNetEvent('fca-round:loading')
AddEventHandler('fca-round:loading', function(map)
	print 'fca-round:loading'
	TriggerEvent('fca-spectate:reset')
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
