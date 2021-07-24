local isLoggedIn = false
local isBleeding = 0
local advanceBleedTimer = 0
local blackoutTimer = 0

local onPainKiller = 0
local wasOnPainKillers = false

local onDrugs = 0
local wasOnDrugs = false

local legCount = 0
local armcount = 0
local headCount = 0

local playerHealth = nil
local playerArmour = nil

local WeaponClasses = {
    ['SMALL_CALIBER'] = 1,
    ['MEDIUM_CALIBER'] = 2,
    ['HIGH_CALIBER'] = 3,
    ['SHOTGUN'] = 4,
    ['CUTTING'] = 5,
    ['LIGHT_IMPACT'] = 6,
    ['HEAVY_IMPACT'] = 7,
    ['EXPLOSIVE'] = 8,
    ['FIRE'] = 9,
    ['SUFFOCATING'] = 10,
    ['OTHER'] = 11,
    ['WILDLIFE'] = 12,
    ['NOTHING'] = 13
}

local WoundStates = {
    'Irritated',
    'Fairly Painful',
    'Extremely Painful',
    'Unbearably Painful',
}

local BleedingStates = {
    'Minor Bleeding',
    'Significant Bleeding',
    'Major Bleeding',
    'Extreme Bleeding',
}

local MovementRate = {
    0.98,
    0.96,
    0.94,
    0.92,
}

local BodyParts = {
    ['HEAD'] = { label = 'Head', causeLimp = false, isDamaged = false, severity = 0 },
    ['NECK'] = { label = 'Neck', causeLimp = false, isDamaged = false, severity = 0 },
    ['SPINE'] = { label = 'Spine', causeLimp = true, isDamaged = false, severity = 0 },
    ['UPPER_BODY'] = { label = 'Upper Body', causeLimp = false, isDamaged = false, severity = 0 },
    ['LOWER_BODY'] = { label = 'Lower Body', causeLimp = true, isDamaged = false, severity = 0 },
    ['LARM'] = { label = 'Left Arm', causeLimp = false, isDamaged = false, severity = 0 },
    ['LHAND'] = { label = 'Left Hand', causeLimp = false, isDamaged = false, severity = 0 },
    ['LFINGER'] = { label = 'Left Hand Fingers', causeLimp = false, isDamaged = false, severity = 0 },
    ['LLEG'] = { label = 'Left Leg', causeLimp = true, isDamaged = false, severity = 0 },
    ['LFOOT'] = { label = 'Left Foot', causeLimp = true, isDamaged = false, severity = 0 },
    ['RARM'] = { label = 'Right Arm', causeLimp = false, isDamaged = false, severity = 0 },
    ['RHAND'] = { label = 'Right Hand', causeLimp = false, isDamaged = false, severity = 0 },
    ['RFINGER'] = { label = 'Right Hand Fingers', causeLimp = false, isDamaged = false, severity = 0 },
    ['RLEG'] = { label = 'Right Leg', causeLimp = true, isDamaged = false, severity = 0 },
    ['RFOOT'] = { label = 'Right Foot', causeLimp = true, isDamaged = false, severity = 0 },
}

local parts = {
    [0]     = 'NONE',
    [31085] = 'HEAD',
    [31086] = 'HEAD',
    [39317] = 'NECK',
    [57597] = 'SPINE',
    [23553] = 'SPINE',
    [24816] = 'SPINE',
    [24817] = 'SPINE',
    [24818] = 'SPINE',
    [10706] = 'UPPER_BODY',
    [64729] = 'UPPER_BODY',
    [11816] = 'LOWER_BODY',
    [45509] = 'LARM',
    [61163] = 'LARM',
    [18905] = 'LHAND',
    [4089] = 'LFINGER',
    [4090] = 'LFINGER',
    [4137] = 'LFINGER',
    [4138] = 'LFINGER',
    [4153] = 'LFINGER',
    [4154] = 'LFINGER',
    [4169] = 'LFINGER',
    [4170] = 'LFINGER',
    [4185] = 'LFINGER',
    [4186] = 'LFINGER',
    [26610] = 'LFINGER',
    [26611] = 'LFINGER',
    [26612] = 'LFINGER',
    [26613] = 'LFINGER',
    [26614] = 'LFINGER',
    [58271] = 'LLEG',
    [63931] = 'LLEG',
    [2108] = 'LFOOT',
    [14201] = 'LFOOT',
    [40269] = 'RARM',
    [28252] = 'RARM',
    [57005] = 'RHAND',
    [58866] = 'RFINGER',
    [58867] = 'RFINGER',
    [58868] = 'RFINGER',
    [58869] = 'RFINGER',
    [58870] = 'RFINGER',
    [64016] = 'RFINGER',
    [64017] = 'RFINGER',
    [64064] = 'RFINGER',
    [64065] = 'RFINGER',
    [64080] = 'RFINGER',
    [64081] = 'RFINGER',
    [64096] = 'RFINGER',
    [64097] = 'RFINGER',
    [64112] = 'RFINGER',
    [64113] = 'RFINGER',
    [36864] = 'RLEG',
    [51826] = 'RLEG',
    [20781] = 'RFOOT',
    [52301] = 'RFOOT',
}

local weapons = {
    --[[ Small Caliber ]]--
    [`WEAPON_PISTOL`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_COMBATPISTOL`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_APPISTOL`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_COMBATPDW`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MACHINEPISTOL`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MICROSMG`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_MINISMG`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_PISTOL_MK2`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_SNSPISTOL`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_SNSPISTOL_MK2`] = WeaponClasses['SMALL_CALIBER'],
    [`WEAPON_VINTAGEPISTOL`] = WeaponClasses['SMALL_CALIBER'],

    --[[ Medium Caliber ]]--
    [`WEAPON_ADVANCEDRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_ASSAULTSMG`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_BULLPUPRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_BULLPUPRIFLE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_CARBINERIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_CARBINERIFLE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_COMPACTRIFLE`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_DOUBLEACTION`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_GUSENBERG`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_HEAVYPISTOL`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_MARKSMANPISTOL`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_PISTOL50`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_REVOLVER`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_REVOLVER_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SMG`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SMG_MK2`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SPECIALCARBINE`] = WeaponClasses['MEDIUM_CALIBER'],
    [`WEAPON_SPECIALCARBINE_MK2`] = WeaponClasses['MEDIUM_CALIBER'],

    --[[ High Caliber ]]--
    [`WEAPON_ASSAULTRIFLE`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_ASSAULTRIFLE_MK2`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_COMBATMG`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_COMBATMG_MK2`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_HEAVYSNIPER`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_HEAVYSNIPER_MK2`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MARKSMANRIFLE`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MARKSMANRIFLE_MK2`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MG`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MINIGUN`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_MUSKET`] = WeaponClasses['HIGH_CALIBER'],
    [`WEAPON_RAILGUN`] = WeaponClasses['HIGH_CALIBER'],

    --[[ Shotguns ]]--
    [`WEAPON_ASSAULTSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_BULLUPSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_DBSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_HEAVYSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_PUMPSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_PUMPSHOTGUN_MK2`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_SAWNOFFSHOTGUN`] = WeaponClasses['SHOTGUN'],
    [`WEAPON_SWEEPERSHOTGUN`] = WeaponClasses['SHOTGUN'],

    --[[ Animals ]]--
    [`WEAPON_ANIMAL`] = WeaponClasses['WILDLIFE'], -- Animal
    [`WEAPON_COUGAR`] = WeaponClasses['WILDLIFE'], -- Cougar
    [`WEAPON_BARBED_WIRE`] = WeaponClasses['WILDLIFE'], -- Barbed Wire
    
    --[[ Cutting Weapons ]]--
    [`WEAPON_BATTLEAXE`] = WeaponClasses['CUTTING'],
    [`WEAPON_BOTTLE`] = WeaponClasses['CUTTING'],
    [`WEAPON_DAGGER`] = WeaponClasses['CUTTING'],
    [`WEAPON_HATCHET`] = WeaponClasses['CUTTING'],
    [`WEAPON_KNIFE`] = WeaponClasses['CUTTING'],
    [`WEAPON_MACHETE`] = WeaponClasses['CUTTING'],
    [`WEAPON_SWITCHBLADE`] = WeaponClasses['CUTTING'],

    --[[ Light Impact ]]--
    [`WEAPON_GARBAGEBAG`] = WeaponClasses['WILDLIFE'], -- Garbage Bag
    [`WEAPON_BRIEFCASE`] = WeaponClasses['WILDLIFE'], -- Briefcase
    [`WEAPON_BRIEFCASE_02`] = WeaponClasses['WILDLIFE'], -- Briefcase 2
    [`WEAPON_BALL`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_FLASHLIGHT`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_KNUCKLE`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_NIGHTSTICK`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_SNOWBALL`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_UNARMED`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_PARACHUTE`] = WeaponClasses['LIGHT_IMPACT'],
    [`WEAPON_NIGHTVISION`] = WeaponClasses['LIGHT_IMPACT'],
    
    --[[ Heavy Impact ]]--
    [`WEAPON_BAT`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_CROWBAR`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_FIREEXTINGUISHER`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_FIRWORK`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_GOLFLCUB`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_HAMMER`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_PETROLCAN`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_POOLCUE`] = WeaponClasses['HEAVY_IMPACT'],
    [`WEAPON_WRENCH`] = WeaponClasses['HEAVY_IMPACT'],
    
    --[[ Explosives ]]--
    [`WEAPON_EXPLOSION`] = WeaponClasses['EXPLOSIVE'], -- Explosion
    [`WEAPON_GRENADE`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_COMPACTLAUNCHER`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_HOMINGLAUNCHER`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_PIPEBOMB`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_PROXMINE`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_RPG`] = WeaponClasses['EXPLOSIVE'],
    [`WEAPON_STICKYBOMB`] = WeaponClasses['EXPLOSIVE'],
    
    --[[ Other ]]--
    [`WEAPON_FALL`] = WeaponClasses['FALL'], -- Fall
    [`WEAPON_HIT_BY_WATER_CANNON`] = WeaponClasses['OTHER'], -- Water Cannon
    [`WEAPON_RAMMED_BY_CAR`] = WeaponClasses['OTHER'], -- Rammed
    [`WEAPON_RUN_OVER_BY_CAR`] = WeaponClasses['OTHER'], -- Ran Over
    [`WEAPON_HELI_CRASH`] = WeaponClasses['OTHER'], -- Heli Crash
    [`WEAPON_STUNGUN`] = WeaponClasses['OTHER'],
    
    --[[ Fire ]]--
    [`WEAPON_ELECTRIC_FENCE`] = WeaponClasses['FIRE'], -- Electric Fence 
    [`WEAPON_FIRE`] = WeaponClasses['FIRE'], -- Fire
    [`WEAPON_MOLOTOV`] = WeaponClasses['FIRE'],
    [`WEAPON_FLARE`] = WeaponClasses['FIRE'],
    [`WEAPON_FLAREGUN`] = WeaponClasses['FIRE'],

    --[[ Suffocate ]]--
    [`WEAPON_DROWNING`] = WeaponClasses['SUFFOCATING'], -- Drowning
    [`WEAPON_DROWNING_IN_VEHICLE`] = WeaponClasses['SUFFOCATING'], -- Drowning Veh
    [`WEAPON_EXHAUSTION`] = WeaponClasses['SUFFOCATING'], -- Exhaust
    [`WEAPON_BZGAS`] = WeaponClasses['SUFFOCATING'],
    [`WEAPON_SMOKEGRENADE`] = WeaponClasses['SUFFOCATING'],
}

local injured = {}

function IsInjuryCausingLimp()
    for k, v in pairs(BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end

    return false
end

function IsInjuredOrBleeding()
    if isBleeding > 0 then
        return true
    else
        for k, v in pairs(BodyParts) do
            if v.isDamaged then
                return true
            end
        end
    end

    return false
end

function GetDamagingWeapon(ped)
    for k, v in pairs(weapons) do
        if HasPedBeenDamagedByWeapon(ped, k, 0) then
            ClearEntityLastDamageEntity(ped)
            return v
        end
    end

    return nil
end

function ProcessRunStuff(ped)
    if IsInjuryCausingLimp() and not (onPainKiller > 0)  then
        RequestAnimSet("move_m@injured")
        while not HasAnimSetLoaded("move_m@injured") do
            Citizen.Wait(0)
        end
        SetPedMovementClipset(ped, "move_m@injured", 1 )
        SetPlayerSprint(PlayerId(), false)

        local level = 0
        for k, v in pairs(injured) do
            if v.severity > level then
                level = v.severity
            end
        end

        SetPedMoveRateOverride(ped, MovementRate[level])

        if wasOnPainKillers then
            SetPedToRagdoll(PlayerPedId(), 1500, 2000, 3, true, true, false)
            wasOnPainKillers = false
            exports['mythic_notify']:DoCustomHudText('inform', 'You\'ve Realized Doing Drugs Does Not Fix All Your Problems', 5000)
        end
    else
        SetPedMoveRateOverride(ped, 1.0)
        ResetPedMovementClipset(ped, 0)
        if DecorGetInt(ped, 'player_thirst') > 25 or onPainKiller > 0 then
            SetPlayerSprint(PlayerId(), true)
        end

        if not wasOnPainKillers and (onPainKiller > 0) then wasOnPainKillers = true end

        if onPainKiller > 0 then
            onPainKiller = onPainKiller - 1
        end
    end
end

Citizen.CreateThread(function()
    while true do
        for k, v in pairs(injured) do
            if (v.part == 'RARM' and v.severity >= 1) or (v.part == 'LARM' and v.severity >= 1) then
                BlockWeaponWheelThisFrame()
            end
        end
        Citizen.Wait(0)
    end
end)



function ProcessDamage(ped)
    if not IsEntityDead(ped) or not (onDrugs > 0) then
        for k, v in pairs(injured) do
            if (v.part == 'LLEG' and v.severity >= 1) or (v.part == 'RLEG' and v.severity >= 1) or (v.part == 'LFOOT' and v.severity >= 2) or (v.part == 'RFOOT' and v.severity >= 2) then
                if legCount >= 15 then
                    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) then
                        local chance = math.random(100)
                        if (IsPedRunning(ped) or IsPedSprinting(ped)) then
                            if chance <= 50 then
                                exports['mythic_notify']:DoCustomHudText('inform', 'You\'re Having A Hard Time Running', 5000)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(PlayerPedId(), 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        else
                            if chance <= 15 then
                                exports['mythic_notify']:DoCustomHudText('inform', 'You\'re Having A Hard time Using Your Legs', 5000)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(PlayerPedId(), 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        end
                    end
                    legCount = 0
                else
                    legCount = legCount + 1
                end
            elseif (v.part == 'LARM' and v.severity >= 1) or (v.part == 'LHAND' and v.severity >= 1) or (v.part == 'LFINGER' and v.severity >= 2) or (v.part == 'RARM' and v.severity >= 1) or (v.part == 'RHAND' and v.severity >= 1) or (v.part == 'RFINGER' and v.severity >= 2) then
                if armcount >= 30 then
                    local chance = math.random(100)

                    armcount = 0
                else
                    armcount = armcount + 1
                end
            elseif (v.part == 'HEAD' and v.severity >= 2) then
                if headCount >= 30 then
                    local chance = math.random(100)

                    if chance <= 15 then
                        exports['mythic_notify']:DoCustomHudText('inform', 'You Suddenly Black Out', 5000)
                        SetFlash(0, 0, 100, 10000, 100)
                        
                        DoScreenFadeOut(100)
                        while not IsScreenFadedOut() do
                            Citizen.Wait(0)
                        end

                        if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                            SetPedToRagdoll(ped, 5000, 1, 2)
                        end

                        Citizen.Wait(5000)
                        DoScreenFadeIn(250)
                    end
                    headCount = 0
                else
                    headCount = headCount + 1
                end
            end
        end

        if wasOnDrugs then
            SetPedToRagdoll(PlayerPedId(), 1500, 2000, 3, true, true, false)
            wasOnDrugs = false
            exports['mythic_notify']:DoCustomHudText('inform', 'You\'ve Realized Doing Drugs Does Not Fix All Your Problems', 5000)
        end
    else
        onDrugs = onDrugs - 1

        if not wasOnDrugs then
            wasOnDrugs = true
        end
    end
end

function CheckDamage(ped, bone, weapon)
    if weapon == nil then return end

    if parts[bone] ~= nil then
        if not BodyParts[parts[bone]].isDamaged then
            BodyParts[parts[bone]].isDamaged = true
            BodyParts[parts[bone]].severity = 1
            exports['mythic_notify']:DoHudText('inform', 'Your ' .. BodyParts[parts[bone]].label .. ' feels ' .. WoundStates[BodyParts[parts[bone]].severity])

            if weapon == WeaponClasses['SMALL_CALIBER'] or weapon == WeaponClasses['MEDIUM_CALIBER'] or weapon == WeaponClasses['CUTTING'] or weapon == WeaponClasses['WILDLIFE'] or weapon == WeaponClasses['OTHER'] or weapon == WeaponClasses['LIGHT_IMPACT'] then
                if isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            elseif weapon == WeaponClasses['HIGH_CALIBER'] or weapon == WeaponClasses['HEAVY_IMPACT'] or weapon == WeaponClasses['SHOTGUN'] or weapon == WeaponClasses['EXPLOSIVE'] then
                if isBleeding < 3 then
                    isBleeding = tonumber(isBleeding) + 2
                elseif isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            end

            table.insert(injured, {
                part = parts[bone],
                label = BodyParts[parts[bone]].label,
                severity = BodyParts[parts[bone]].severity
            })

            TriggerServerEvent('bonefive:server:SyncInjuries', {
                limbs = BodyParts,
                isBleeding = tonumber(isBleeding)
            })
        else
            if weapon == WeaponClasses['SMALL_CALIBER'] or weapon == WeaponClasses['MEDIUM_CALIBER'] or weapon == WeaponClasses['CUTTING'] or weapon == WeaponClasses['WILDLIFE'] or weapon == WeaponClasses['OTHER'] or weapon == WeaponClasses['LIGHT_IMPACT'] then
                if isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            elseif weapon == WeaponClasses['HIGH_CALIBER'] or weapon == WeaponClasses['HEAVY_IMPACT'] or weapon == WeaponClasses['SHOTGUN'] or weapon == WeaponClasses['EXPLOSIVE'] then
                if isBleeding < 3 then
                    isBleeding = tonumber(isBleeding) + 2
                elseif isBleeding < 4 then
                    isBleeding = tonumber(isBleeding) + 1
                end
            end

            if BodyParts[parts[bone]].severity < 4 then
                BodyParts[parts[bone]].severity = BodyParts[parts[bone]].severity + 1
                TriggerServerEvent('bonefive:server:SyncInjuries', {
                    limbs = BodyParts,
                    isBleeding = tonumber(isBleeding)
                })

                exports['mythic_notify']:DoHudText('inform', 'Your ' .. BodyParts[parts[bone]].label .. ' feels ' .. WoundStates[BodyParts[parts[bone]].severity])

                for k, v in pairs(injured) do
                    if v.parts == parts[bone] then
                        v.severity = BodyParts[parts[bone]].severity
                    end
                end
            else

            end
        end
    else
        print('Bone Not In Index - Report This! - ' .. bone)
    end
end

RegisterNetEvent('bonefive:client:SyncBleed')
AddEventHandler('bonefive:client:SyncBleed', function(bleedStatus)
    isBleeding = tonumber(bleedStatus)
end)

RegisterNetEvent('bonefive:client:FieldTreatLimbs')
AddEventHandler('bonefive:client:FieldTreatLimbs', function()
    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 1
    end

    for k, v in pairs(injured) do
        if v.parts == parts[bone] then
            v.severity = BodyParts[parts[bone]].severity
        end
    end
end)

RegisterNetEvent('bonefive:client:ResetLimbs')
AddEventHandler('bonefive:client:ResetLimbs', function()
    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end

    injured = {}
end)

RegisterNetEvent('bonefive:client:FieldTreatBleed')
AddEventHandler('bonefive:client:FieldTreatBleed', function()
    if isBleeding > 1 then
        isBleeding = tonumber(isBleeding) - 1
    end
end)

RegisterNetEvent('bonefive:client:ReduceBleed')
AddEventHandler('bonefive:client:ReduceBleed', function()
    if isBleeding > 0 then
        isBleeding = tonumber(isBleeding) - 1
    end
end)

RegisterNetEvent('bonefive:client:RemoveBleed')
AddEventHandler('bonefive:client:RemoveBleed', function()
    isBleeding = 0
end)

RegisterNetEvent('bonefive:client:UsePainKiller')
AddEventHandler('bonefive:client:UsePainKiller', function(tier)
    if tier < 4 then
        onPainKiller = 90 * tier
    end

    exports['mythic_notify']:DoCustomHudText('inform', 'You feel the pain subside temporarily', 5000)
end)

RegisterNetEvent('bonefive:client:UseAdrenaline')
AddEventHandler('bonefive:client:UseAdrenaline', function(tier)
    if tier < 4 then
        onDrugs = 180 * tier
    end

    exports['mythic_notify']:DoCustomHudText('inform', 'You\'re Able To Ignore Your Body Failing', 5000)
end)  
    
Citizen.CreateThread(function()
    local player = PlayerPedId()
	while true do
		if not IsEntityDead(player) and not (#injured == 0) then
			if #injured > 0 then
				local str = ''
				if #injured > 1 and #injured < 3 then
					for k, v in pairs(injured) do
						str = str .. 'Your ' .. v.label .. ' feels ' .. WoundStates[v.severity]
						if k < #injured then
							str = str .. ' | '
						end
					end
				elseif #injured > 2 then
					str = 'You Feel Multiple Pains'
				else
					str = 'Your ' .. injured[1].label .. ' feels ' .. WoundStates[injured[1].severity]
				end
		
				exports['mythic_notify']:DoCustomHudText('inform', str, 15000)
			end

			if isBleeding > 0 then
				if blackoutTimer >= 10 then
					exports['mythic_notify']:DoCustomHudText('inform', 'You Suddenly Black Out', 5000)
					SetFlash(0, 0, 100, 7000, 100)
						
					DoScreenFadeOut(500)
					while not IsScreenFadedOut() do
						Citizen.Wait(0)
					end
			
					if not IsPedRagdoll(player) and IsPedOnFoot(player) and not IsPedSwimming(player) then
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
						SetPedToRagdollWithFall(PlayerPedId(), 10000, 12000, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
					end
			
					Citizen.Wait(5000)
					DoScreenFadeIn(500)
					blackoutTimer = 0
				end
			
				if isBleeding == 1 then
					SetFlash(0, 0, 100, 100, 100)
				elseif isBleeding == 2 then
					SetFlash(0, 0, 100, 250, 100)
				elseif isBleeding == 3 then
					SetFlash(0, 0, 100, 500, 100)
					--Function.Call(Hash.SET_FLASH, 0, 0, 100, 500, 100);
				elseif isBleeding == 4 then
					SetFlash(0, 0, 100, 500, 100)
					--Function.Call(Hash.SET_FLASH, 0, 0, 100, 500, 100);
				end
				exports['mythic_notify']:DoCustomHudText('inform', 'You Have ' .. BleedingStates[isBleeding], 25000)
                local bleedDamage = tonumber(isBleeding) * 4
                ApplyDamageToPed(player, bleedDamage, false)
                playerHealth = playerHealth - bleedDamage
				blackoutTimer = blackoutTimer + 1
				advanceBleedTimer = advanceBleedTimer + 1
			
				if advanceBleedTimer >= 10 then
					if isBleeding < 4 then
						isBleeding = tonumber(isBleeding) + 1
					end
					advanceBleedTimer = 0
				end
			end
		end

		Citizen.Wait(30000)
	end
end)

Citizen.CreateThread(function()
    local player = PlayerPedId()
    
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local armour = GetPedArmour(ped)

        if not playerHealth then
            playerHealth = health
        end

        if not playerArmour then
            playerArmour = armour
        end

        if player ~= ped then
            player = ped
            playerHealth = health
            playerArmour = armour
        end

        local armourDamaged = (playerArmour ~= armour and armour < playerArmour and armour > 0) -- Players armour was damaged
        local healthDamaged = (playerHealth ~= health and health < playerHealth) -- Players health was damaged
        
        if armourDamaged or healthDamaged then
            local hit, bone = GetPedLastDamageBone(player)
            local bodypart = parts[bone]

            if hit and bodypart ~= 'NONE' then
                local checkDamage = true
                local weapon = GetDamagingWeapon(player)
                if weapon ~= nil then
                    if armourDamaged and (bodypart == 'SPINE' or bodypart == 'LOWER_BODY') and weapon <= WeaponClasses['LIGHT_IMPACT'] and weapon ~= WeaponClasses['NOTHING'] then
                        checkDamage = false -- Don't check damage if the it was a body shot and the weapon class isn't that strong
                    end

                    if checkDamage then
                        CheckDamage(player, bone, weapon)
                    end
                end
            end
        end

        playerHealth = health
        playerArmour = armour
        Citizen.Wait(333)

		ProcessRunStuff(player)
		Citizen.Wait(333)

		ProcessDamage(player)
		Citizen.Wait(333)
	end
end)