local anticheat_enabled = true

local anticheat_whitelist = {}
RegisterNetEvent('fca-anticheat:whitelist')
AddEventHandler('fca-anticheat:whitelist', function(wl)
     anticheat_whitelist = wl
end)

-- super jump
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if (anticheat_enabled) then
      if IsPedJumping(PlayerPedId()) then
        local firstCoord = GetEntityCoords(GetPlayerPed(-1))
        while IsPedJumping(PlayerPedId()) do
          Wait (0)
        end
        local secondCoord = GetEntityCoords(GetPlayerPed(-1))
        local jumplength = GetDistanceBetweenCoords(firstCoord, secondCoord, false)
        if jumplength > 10.0 then
          print('You triggered superjump')
          TriggerServerEvent('AntiCheat:Jump', jumplength )
        end
      end
    end
  end
end) 
