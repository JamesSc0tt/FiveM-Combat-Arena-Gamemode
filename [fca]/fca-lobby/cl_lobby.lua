local uiActive = false

RegisterNetEvent('fca-lobby:ui')
AddEventHandler('fca-lobby:ui', function(info)
	-- update the UI
	if not uiActive then
		-- show ui
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
		SendNUIMessage({
			display = true,
			lobbydata = info,
		})
		SetNuiFocus(true, true)
	else
		-- send update
	end
end)

RegisterNUICallback("addVote", function(data, cb)
	data.id = data.id + 1
	print(data.type)
	print(data.identifier)
	TriggerServerEvent('fca-lobby:addVote', data.type, data.id)
end)

RegisterNUICallback("setReady", function(data, cb)
	TriggerServerEvent('fca-lobby:setReady')
end)



SetNuiFocus(false, false)