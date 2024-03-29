local uiActive = false

RegisterNetEvent('fca-lobby:destroy')
AddEventHandler('fca-lobby:destroy', function()
	print'destroy???'
	SendNUIMessage({
		hide = true,
	})
	SetNuiFocus(false)
end)

RegisterNetEvent('fca-lobby:reset')
AddEventHandler('fca-lobby:reset', function()
	uiActive = false
	Citizen.Wait(math.random(100,500)) -- make it so all players dont try to create at once
	TriggerServerEvent('fca-lobby:register')
end)

RegisterNetEvent('fca-lobby:ui')
AddEventHandler('fca-lobby:ui', function(info)
	-- update the UI
	for k, v in pairs(info.maps) do
		local votedmap = false
		for key, val in pairs(v[3]) do
			if val == GetPlayerServerId(PlayerId()) then
				votedmap = true
			end
		end
		if votedmap then
			info.maps[k][5] = true
		else
			info.maps[k][5] = false
		end
	end
	for k, v in pairs(info.gamemodes) do
		local votedgm = false
		for key, val in pairs(v[5]) do
			if val == GetPlayerServerId(PlayerId()) then
				votedgm = true
			end
		end
		if votedgm then
			info.gamemodes[k][6] = true
		else
			info.gamemodes[k][6] = false
		end
	end
	if info.lobby_active then
		-- show ui when lobby is active, always
		uiActive = true
		SendNUIMessage({
			display = true,
			lobbydata = info,
		})
		SetNuiFocus(true, true)
	else
		-- send update
		SendNUIMessage({
			display = false,
			lobbydata = info,
		})
	end
end)

RegisterNUICallback("addVote", function(data, cb)
	data.id = data.id + 1
	TriggerServerEvent('fca-lobby:addVote', data.type, data.id)
end)

RegisterNUICallback("setReady", function(data, cb)
	TriggerServerEvent('fca-lobby:setReady')
end)



SetNuiFocus(false, false)