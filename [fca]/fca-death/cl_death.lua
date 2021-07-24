
local Melee = { -1569615261, 1737195953, 1317494643, -1786099057, 1141786504, -2067956739, -868994466 }
local Bullet = { 453432689, 1593441988, 584646201, -1716589765, 324215364, 736523883, -270015777, -1074790547, -2084633992, -1357824103, -1660422300, 2144741730, 487013001, 2017895192, -494615257, -1654528753, 100416529, 205991906, 1119849093 }
local Knife = { -1716189206, 1223143800, -1955384325, -1833087301, 910830060, }
local Car = { 133987706, -1553120962 }
local Animal = { -100946242, 148160082 }
local FallDamage = { -842959696 }
local Explosion = { -1568386805, 1305664598, -1312131151, 375527679, 324506233, 1752584910, -1813897027, 741814745, -37975472, 539292904, 341774354, -1090665087 }
local Gas = { -1600701090 }
local Burn = { 615608432, 883325847, -544306709 }
local Drown = { -10959621, 1936677264 }

Citizen.CreateThread(function()
    local alreadyDead = false

    while true do
        Citizen.Wait(50)
        local playerPed = GetPlayerPed(-1)
        if IsEntityDead(playerPed) and not alreadyDead then
            print 'gotdeath'

            local killer = GetPedKiller(playerPed)
            local killername = false
            local killerid = false
            local killerhealth = 0
            local killermaxhealth = 0
            local killerarmour = 0
            local killermaxarmour = 0

            local lcl = GetPlayerPed(-1)
            local lclname = GetPlayerName(PlayerId())



            for _, id in ipairs(GetActivePlayers()) do
                if killer == GetPlayerPed(id) then
                    killername = GetPlayerName(id)
                    killerid = GetPlayerServerId(id)
                    killerhealth = GetEntityHealth(killer)
                    killermaxhealth = GetPedMaxHealth(killer)
                    killerarmour = GetPedArmour(killer)
                    killermaxarmour = GetPlayerMaxArmour(id)
                end
            end

            local death = GetPedCauseOfDeath(playerPed)

            if checkArray (Melee, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'melee'}) --killername .. " meleed " .. playerName)
            elseif checkArray (Bullet, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'shot'}) --killername .. " shot " .. playerName)
            elseif checkArray (Knife, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'stabbed'}) --killername .. " stabbed " .. playerName)
            elseif checkArray (Car, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'vehicle'}) --killername .. " hit " .. playerName)
            elseif checkArray (Animal, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'animal'}) --playerName .. " died by an animal")
            elseif checkArray (FallDamage, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'fall'}) --playerName .. " died of fall damage")
            elseif checkArray (Explosion, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'exploded'}) --playerName .. " died of an explosion")
            elseif checkArray (Gas, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'gas'}) --playerName .. " died of gas")
            elseif checkArray (Burn, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'fire'}) --playerName .. " burned to death")
            elseif checkArray (Drown, death) then
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'drowned'}) --playerName .. " drowned")
            else
                TriggerServerEvent('fca-death:report', {{killer = true, id = killerid, name = killername, health = killerhealth, maxhealth = killermaxhealth, armour = killerarmour, maxarmour = killermaxarmour}, death, 'unknown'}) --playerName .. " was killed by an unknown force")
                --print(death)
            end

            alreadyDead = true
        end

        if not IsEntityDead(playerPed) then
            alreadyDead = false
        end
    end
end)

function checkArray (array, val)
    for name, value in ipairs(array) do
        if value == val then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    -- for testing
    if IsEntityDead(GetPlayerPed(-1)) then
        local loc = GetEntityCoords(GetPlayerPed(-1))
        exports.spawnmanager:spawnPlayer({
            x = loc.x,
            y = loc.y,
            z = loc.z,
            heading = 291.71,
            model = 'a_m_m_farmer_01',
            skipFade = false
        })
    end
end)