RegisterNetEvent('fca-spectate:spectatePlayer')
AddEventHandler('fca-spectate:spectatePlayer', function(id)
	print(source..' requested specate '..id)
    local src = source
    local id = tonumber(id)
    if tonumber(src) == tonumber(id) then 
    	TriggerClientEvent('ShortText', src, 'Can not spectate yourself!', 3) 
    	return 
   	end
    local coords = GetEntityCoords(GetPlayerPed(tonumber(id)))
    if coords then
        TriggerClientEvent('fca-spectate:spectatePlayer', src, id, coords)
    end
end)