RegisterCommand('goto', function(s,a)
	SetEntityCoords(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(a[1])))))
end)