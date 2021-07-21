AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

local firstspawn = false
AddEventHandler('playerSpawned', function(spawn)
	if not firstspawn then
		TriggerServerEvent('fca-lobby:register')
	end
end)

RegisterNetEvent('fca-spawn:lobby')
AddEventHandler('fca-spawn:lobby', function()
	SetEntityCoords(GetPlayerPed(-1), 0,0,0)
	FreezeEntityPosition(GetPlayerPed(-1), true)
	SetEntityInvincible(GetPlayerPed(-1), true)
	SetEntityVisible(GetPlayerPed(-1), false)

	TriggerEvent('fca-lobby:ui')
end)

RegisterCommand("respawn", function(source, args, raw)
	firstspawn = false
	exports.spawnmanager:spawnPlayer()
end)