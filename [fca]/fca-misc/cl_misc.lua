function drawTxt(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextCentre(true)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

RegisterNetEvent('fca-misc:text:LG')
AddEventHandler('fca-misc:text:LG', function(text, color, seconds)
    text=string.upper(text)
    Citizen.CreateThread(function()
        local destroy = GetGameTimer() + (seconds * 1000)
        while GetGameTimer() < destroy do
            Citizen.Wait(0)
            exports['fca-misc']:drawTxt(1.0, 0.8, 1.0, 1.0, 2.0, text, color[1], color[2], color[3], 255)
        end
    end)
end)

RegisterNetEvent('fca-misc:text:SM')
AddEventHandler('fca-misc:text:SM', function(text, color, seconds)
    text=string.upper(text)
    Citizen.CreateThread(function()
        local destroy = GetGameTimer() + (seconds * 1000)
        while GetGameTimer() < destroy do
            Citizen.Wait(0)
            exports['fca-misc']:drawTxt(1.0, 0.93, 1.0, 1.0, 0.8, text, color[1], color[2], color[3], 255)
        end
    end)
end)
