local spectate_active = false
local spectate_target = false
local spectate_cam = false
local spectate_players = {{2}}

RegisterCommand('spectate', function(s, a)
	TriggerEvent('FeedM:showNotification', 'Requesting... '..a[1])
	TriggerServerEvent('fca-spectate:spectatePlayer', a[1])
end)

RegisterNetEvent('fca-spectate:reset')
AddEventHandler('fca-spectate:reset', function()
	SetEntityVisible(GetPlayerPed(-1), true)
	SetEntityCollision(GetPlayerPed(-1), true, true)
	DestroyCam(spectate_cam, true)
	RenderScriptCams(false, false, 500, false, false)
	spectate_active = false
	spectate_target = false
	spectate_cam = false
	spectate_players = false
end)

function getFirstActivePlayer()
	local fap = false
	if spectate_players then
		for _,v in pairs(spectate_players) do
			if not fap then
				fap = v.player
			end
		end
	end
	if not fap then
		print'failedtofindfap'
	else
		return fap
	end
end

function getNextActivePlayer()
	local nap = false
	local trigger = false
	if spectate_players then
		for k,v in pairs(spectate_players) do
			print(v.player)
			print(spectate_target)
			if tonumber(v.player) == tonumber(GetPlayerServerId(spectate_target)) then
				print'current'
				trigger = true
			else
				if trigger then
					if NetworkIsPlayerActive(spectate_target) then
						print'trigger'
						nap = v.player
					else
						print'notnetactive'
					end
				end
			end
		end
	end
	if nap == false then
		print'fap'
		return getFirstActivePlayer()
	else
		return nap
	end
end

function getLastActivePlayer()
	local lap = false
	local last = false
	local trigger = false
	if spectate_players then
		for k,v in pairs(spectate_players) do
			if trigger then
				-- catch case
				lap = v.player
			elseif tonumber(v.player) == tonumber(GetPlayerServerId(spectate_target)) then
				lap = last
				trigger = true
			else
				last = v.player
			end
			if tonumber(v.player) == tonumber(GetPlayerServerId(spectate_target)) then
				lap = last
				trigger = true
			else
				if trigger then
					if NetworkIsPlayerActive(spectate_target) then
						print'trigger'
						lap = v.player
					else
						print'notnetactive'
					end
				end
			end
		end
	end
	if lap == false then
		print'fap'
		return getFirstActivePlayer()
	else
		return lap
	end
end


RegisterNetEvent('fca-spectate:enable')
AddEventHandler('fca-spectate:enable', function(players)
	spectate_players = players
	TriggerServerEvent('fca-spectate:spectatePlayer', getFirstActivePlayer())
end)

RegisterNetEvent('fca-spectate:spectatePlayer')
AddEventHandler('fca-spectate:spectatePlayer', function(id, coords)
    if coords == nil then return end
    SetEntityVisible(GetPlayerPed(-1), false)
    SetEntityCoords(GetPlayerPed(-1), coords)


    RequestCollisionAtCoord(coords)
	SetEntityCoordsNoOffset(PlayerPedId(), coords, 0, 0, 2.5)
	FreezeEntityPosition(GetPlayerPed(-1), true)

	while not HasCollisionLoadedAroundEntity(GetPlayerPed(-1)) do
        Citizen.Wait(1)
        print'colliding...'
    end

    FreezeEntityPosition(GetPlayerPed(-1), false)

   	DoScreenFadeOut(500)
   	SetEntityVisible(GetPlayerPed(-1), false)
   	SetEntityCollision(GetPlayerPed(-1), false, true)


   	SetEntityCoords(GetPlayerPed(-1), coords)
   	Citizen.Wait(1000)
   	DoScreenFadeIn(500)

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
	   			DisableAllControlActions(1)

	   			SetTextComponentFormat("STRING")
            	AddTextComponentString("~INPUT_ATTACK~ Next Player\n~INPUT_AIM~ Previous Player")
            	DisplayHelpTextFromStringLabel(0, 0, 1, -1)

	   			-- handle swapping
	   			if IsDisabledControlJustReleased(1, 24) then
	   				-- back
	   				if spectate_players then
		   				local lap = getLastActivePlayer()
		   				print('LAST: '..lap)
		   				TriggerServerEvent('fca-spectate:spectatePlayer', lap)
		   			end
	   			end
	   			if IsDisabledControlJustReleased(1, 25) then
	   				-- next
	   				if spectate_players then
		   				local nap = getNextActivePlayer()
		   				print('NEXT: '..nap)
		   				TriggerServerEvent('fca-spectate:spectatePlayer', nap)
		   			end
	   			end
			else
				print'nocam?'
			end
		end
	end
end)