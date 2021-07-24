RegisterCommand('goto', function(s,a)
	SetEntityCoords(GetPlayerPed(-1), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(a[1])))))
end)

RegisterCommand('xyz', function()
	local xyz = GetEntityCoords(GetPlayerPed(-1))
	TriggerEvent('chat:addMessage', 'X: '..xyz.x)
	TriggerEvent('chat:addMessage', 'Y: '..xyz.y)
	TriggerEvent('chat:addMessage', 'Z: '..xyz.z)
end)


local function DrawText3D(x,y,z, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz)-vector3(x,y,z))
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        if not useCustomScale then
            SetTextScale(0.0*scale, 0.55*scale)
        else 
            SetTextScale(0.0*scale, customScale)
        end
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
	while true do Citizen.Wait(0)
		for _, id in ipairs(GetActivePlayers()) do
			SetMpGamerTagVisibility(GetPlayerPed(id), GetPlayerServerId( id ) .. "", false, false, "", false )
			local loc = GetEntityCoords(GetPlayerPed(id))
			DrawText3D(loc.x,loc.y,loc.z, GetPlayerServerId( id ), 255,0,0) 
		end
	end
end)
