itemUses = {
	["crowbar"] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_criminalmisc:houserobbery:try')
		end,
	},
	["scuba"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:rebreather:use')
		end,
	},
	["id"] = {
		takeItem = false,
		use = function(item)
			local players = {}
			for _, ply in pairs(GetActivePlayers()) do
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(ply)),GetEntityCoords(GetPlayerPed(-1)),true) < 5 then
					players[#players+1] = GetPlayerServerId(ply)
				end
			end
			TriggerServerEvent('fsn_licenses:id:display', players, item.customData.Name, item.customData.Occupation, item.customData.DOB, item.customData.Issue, item.customData.CharID)
		end,
	},
	["painkillers"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent("mythic_progbar:client:progress", {
		        name = "firstaid_action",
		        duration = 3000,
		        label = "Taking Painkillers",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = false,
		            disableCarMovement = false,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "mp_suicide",
		            anim = "pill",
		            flags = 49,
		        },
		        prop = {
		            model = "prop_cs_pills",
		            bone = 58866,
		            coords = { x = 0.1, y = 0.0, z = 0.001 },
		            rotation = { x = -60.0, y = 0.0, z = 0.0 },
		        },
		    }, function(status)
		        if not status then
		            TriggerEvent('bonefive:client:RemoveBleed')
		            TriggerEvent('bonefive:client:FieldTreatBleed')
		        end
		    end)
		end
	},
	["oxy"] = {
		takeItem = true,
		use = function ()
			TriggerEvent("mythic_progbar:client:progress", {
        		name = "firstaid_action",
		        duration = 20000,
		        label = "Taking Oxy",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = false,
		            disableCarMovement = false,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "mp_suicide",
		            anim = "pill",
		            flags = 49,
		        },
		        prop = {
		            model = "prop_cs_pills",
		            bone = 58866,
		            coords = { x = 0.1, y = 0.0, z = 0.001 },
		            rotation = { x = -60.0, y = 0.0, z = 0.0 },
		        },
		    }, function(status)
		        if not status then
					SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
		            TriggerEvent('bonefive:client:FieldTreatLimbs')
		            TriggerEvent('bonefive:client:ResetLimbs')
		        end
		    end)
		end
	},
	["morphine"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('mythic_hospital:client:UsePainKiller', 6)
		end
	},
	["bandage"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent("mythic_progbar:client:progress", {
		        name = "firstaid_action",
		        duration = 5000,
		        label = "Using Bandage",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = false,
		            disableCarMovement = false,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "missheistdockssetup1clipboard@idle_a",
		            anim = "idle_a",
		            flags = 49,
		        },
		        prop = {
		            model = "prop_paper_bag_small",
		        }
		    }, function(status)
		        if not status then
					local maxHealth = GetEntityMaxHealth(PlayerPedId())
					local health = GetEntityHealth(PlayerPedId())
					local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 16))
		            SetEntityHealth(PlayerPedId(), newHealth)
		            TriggerEvent('bonefive:client:ReduceBleed')
		        end
		    end)
		end
	},
	["repair_kit"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_vehiclecontrol:damage:repairkit')
		end
	},
	["beef_jerky"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 15)
		end
	},
	["cupcake"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 5)
		end
	},
	["cupcake"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 5)
			if math.random(1, 100) < 5 then
				TriggerEvent('fsn_evidence:ped:addState', 'Crumbs down chest', 'UPPER_BODY')
			end
		end
	},
	["tuner_chip"] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('xgc-tuner:openTuner')
		end
	},
	["burger"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 23)
		end
	},
	["microwave_burrito"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 15)
		end
	},
	["panini"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:food', 13)
		end
	},
	["pepsi"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:drink', 10)
		end
	},
	["pepsi_max"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:drink', 10)
		end
	},
	["water"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:drink', 20)
		end
	},
	["coffee"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:drink', 25)
		end
	},
	["lockpick"] = {
		takeItem = false,
		use = function(item)
			print'uselockpick'
			TriggerEvent('fsn_criminalmisc:lockpicking')
		end
	},
	["phone"] = {
		takeItem = false,
		use = function(item)
			ExecuteCommand('p')
		end
	},
	["joint"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_criminalmisc:drugs:effects:weed')
			TriggerEvent('fsn_evidence:ped:addState', 'Seems agitated', 'UPPER_BODY')
		end
	},
	["meth_rocks"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_criminalmisc:drugs:effects:meth')
			TriggerEvent('fsn_evidence:ped:addState', 'Red eyes', 'HEAD')
			TriggerEvent('mythic_hospital:client:UseAdrenaline')
		end
	},
	["meth_rocks"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_criminalmisc:drugs:effects:cocaine')
			TriggerEvent('fsn_evidence:ped:addState', 'Grinding jaw', 'HEAD')
		end
	},
	["cigarette"] = {
		takeItem = true,
		use = function(item)
		TriggerEvent('fsn_criminalmisc:drugs:effects:smokeCigarette')
		end
	},
	["binoculars"] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('binoculars:Activate')
		end
	},
	["ecola_drink"] = {
		takeItem = true,
		use = function(item)
			TriggerEvent('fsn_inventory:use:drink', 50)
		end
	},
	["empty_canister"] = {
		takeItem = true,
		use = function(item)
			if GetDistanceBetweenCoords(3563.146484375, 3673.47265625, 28.121885299683, GetEntityCoords(GetPlayerPed(-1)), true) < 1 then
				TriggerEvent('fsn_inventory:item:take', 'empty_canister', 1)
				TriggerEvent('fsn_inventory:item:add', 'gas_canister', 1)
			else
				TriggerEvent('fsn_notify:displayNotification', 'Nothing to do with that here', 'centerLeft', 3000, 'error')
			end
		end
	},
	["gas_canister"] = {
		takeItem = true,
		use = function(item)
			local gasuse = {x = -628.78393554688, y = -226.52185058594, z = 55.901119232178}
			if GetDistanceBetweenCoords(gasuse.x, gasuse.y, gasuse.z, GetEntityCoords(GetPlayerPed(-1)), true) < 1 then
				TriggerEvent('fsn_notify:displayNotification', 'It looks like the vent is locked, you\'ll need to find another way to do this', 'centerLeft', 3000, 'info')
			else
				TriggerEvent('fsn_notify:displayNotification', 'Nothing to do with that here', 'centerLeft', 3000, 'error')
			end
		end
	},
	['ammo_pistol'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_pistol')
		end
	},
	['ammo_pistol_large'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_pistol_large')
		end
	},
	['ammo_shotgun'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_shotgun')
		end
	},
	['ammo_shotgun_large'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_shotgun_large')
		end
	},
	['ammo_rifle'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_rifle')
		end
	},
	['ammo_rifle_large'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_rifle_large')
		end
	},
	['ammo_smg'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_smg')
		end
	},
	['ammo_smg_large'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_smg_large')
		end
	},
	['ammo_sniper'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_sniper')
		end
	},
	['ammo_sniper_large'] = {
		takeItem = false,
		use = function(item)
			TriggerEvent('fsn_inventory:useAmmo', 'ammo_sniper_large')
		end
	},
	['armor'] = {
		takeItem = true,
		use = function(item)
			print'armor'
			TriggerEvent("mythic_progbar:client:progress", {
		        name = "firstaid_action",
		        duration = 3000,
		        label = "Taking Painkillers",
		        useWhileDead = false,
		        canCancel = true,
		        controlDisables = {
		            disableMovement = false,
		            disableCarMovement = false,
		            disableMouse = false,
		            disableCombat = true,
		        },
		        animation = {
		            animDict = "oddjobs@basejump@ig_15",
		            anim = "puton_parachute",
		            flags = 49,
		        },
		    }, function(status)
		        if not status then
		        	SetPedArmour(GetPlayerPed(-1), 100)
		        end
		    end)
		end
	},
}