local spectate_active = false
local spectate_target = false
local spectate_cam = false

RegisterCommand('spectate', function(s, a)
	TriggerEvent('FeedM:showNotification', 'Requesting... '..a[1])
	TriggerServerEvent('fca-spectate:spectatePlayer', a[1])
end)

RegisterNetEvent('fca-spectate:reset')
AddEventHandler('fca-spectate:reset', function()
	SetEntityVisible(GetPlayerPed(-1), true)
	SetEntityCollision(GetPlayerPed(-1), true, true)
	spectate_active = false
	spectate_target = false
	spectate_cam = false
end)

RegisterNetEvent('fca-spectate:spectatePlayer')
AddEventHandler('fca-spectate:spectatePlayer', function(id, coords)
	if not spectate_active then
	    if coords == nil then return end
	    print(id)
	    print(coords)

	   	SetEntityVisible(GetPlayerPed(-1), false)
	   	SetEntityCollision(GetPlayerPed(-1), false, true)

	   	SetEntityCoords(GetPlayerPed(-1), coords)

	   	local player = GetPlayerFromServerId(id)
	   	if not player then
	   		print'noplayer?'
	   	else
	   		local pped = GetPlayerPed(player)
	   		if not pped then
	   			print'noped?'
	   		else
	   			AttachEntityToEntity(GetPlayerPed(-1), pped, 11816, 0.0, -5.0, 4.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	   			spectate_active = true
	   			spectate_cam = CreateCam('DEFAULT_SCRIPTED_CAMERA')
	   			spectate_target = player
	   			SetCamCoord(spectate_cam, GetEntityCoords(GetPlayerPed(-1)))
	   			PointCamAtCoord(spectate_cam, GetEntityCoords(pped))
	   		end
	   	end
	else
		print'reset?'
	end
end)

Citizen.CreateThread(function()
	while true do Citizen.Wait(0)
		if spectate_active then
			if spectate_cam and spectate_target then
				local pped = GetPlayerPed(spectate_target)
				SetCamCoord(spectate_cam, GetEntityCoords(GetPlayerPed(-1)))
				PointCamAtCoord(spectate_cam, GetEntityCoords(pped).x, GetEntityCoords(pped).y, GetEntityCoords(pped).z)
	   			SetCamActive(spectate_cam, true)
	   			RenderScriptCams(true, true, 500, true, true)
			else
				print'nocam?'
			end
		end
	end
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