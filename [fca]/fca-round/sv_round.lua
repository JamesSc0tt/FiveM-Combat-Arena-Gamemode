local seconds = 0
local round_start = 0

local round_data = {}
local lobby_data = {}

local round_pending = false
local round_spawned = {}
local round_active = false

function handle_death()

end

local loadouts = {
	{
		name = 'COMBAT PISTOL',
		items = {
			{'weapon_combatpistol', 1},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5}
		},
	}
}

function sendLoadout(player)
	if round_active then
		local l = loadouts[round_data.loadout]
		print('Sending loadout '..l.name..' to player '..player)
	
		for key, item in pairs(l.items) do
			TriggerClientEvent('fsn_inventory:item:add', player, item[1], item[2])
		end
		TriggerClientEvent('FeedM:showNotification', -1, 'You got loadout: ~b~'..l.name..'~w~!')
	end
end

RegisterNetEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(player, killer)
	for k,v in pairs(killer) do
		print(tostring(k)..' => '..tostring(v))
	end
end)

RegisterNetEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
	print(killedBy)
end)

AddEventHandler('playerDropped', function (reason)
	-- remove from active lobby / players
	local pname = GetPlayerName(source)
	if round_active then
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'tdm' then
			for teamkey,teamtable in pairs(round_data.teams.players) do
				for playerkey, playertable in pairs(teamtable) do
					if playertable[1] == source then
						print('[tdm] Player '..source..' left the game')
						TriggerClientEvent('FeedM:showNotification', -1, '~r~'..pname..' left the game.')
						exports['fca-discord']:AddDiscordLog('player',  '**'..pname..'** removed from team **'..teamkey..'** due to leaving.')
						round_data.teams.players[teamkey][playerkey] = nil
						if #round_data.teams.players[teamkey] <= 0 then
							print('[tdm] Round forfeit, everybody in team '..teamkey..' left!')
							TriggerClientEvent('FeedM:showNotification', -1, 'Team '..key..' forfeited, everybody left the game')
							exports['fca-discord']:AddDiscordLog('player', 'Team '..key..' forfeited, everybody left the game')
							endRound()
						end
					end
				end
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'dm' then
			for playerkey,playertable in pairs(round_data.players) do
				if playertable[1] == source then
					print('[dm] '..source..' left the game')
					TriggerClientEvent('FeedM:showNotification', -1, '~r~'..pname..' left the game.')
					exports['fca-discord']:AddDiscordLog('player',  '**'..pname..'** left the game.')
					round_data.players[playerkey] = nil
					if #round_data.players < 2 then
						print('[dm] Cannot continue with only one player.')
						exports['fca-discord']:AddDiscordLog('player', 'Game ended, this gamemode can not be played with only 1 player.')
						endRound()
					end
				end
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
			for playerkey,playertable in pairs(round_data.players) do
				if playertable[1] == source then
					print('[br] '..source..' left the game')
					TriggerClientEvent('FeedM:showNotification', -1, '~r~'..pname..' left the game.')
					exports['fca-discord']:AddDiscordLog('player',  '**'..pname..'** left the game.')
					round_data.players[playerkey] = nil
					if #round_data.players < 2 then
						-- winner thing here!
						print('[br] Only one player left, immediate win')
					end
				end
			end
		end
	end
end)

RegisterNetEvent('fca-round:start', function(lobby)
	print 'fca-round:start'
	lobby_data = lobby -- reset at start of each round
	local gm = lobby.gamemodes[lobby.gamemode][1]
	local map = lobby.map

	round_data = {} -- reset at start of each round

	round_data.loadout = math.random(1, #loadouts)
	print('Random loadout: '..loadouts[round_data.loadout].name)

	if gm == 'tdm' then
		round_data.teams = {
			kills = {
				[1] = 0,
				[2] = 0,
			},
			players = {
				[1] = {},
				[2] = {},
			}
		}
		local count = 0
		round_data.players = lobby.players.active
		for k,v in pairs(lobby.players.active) do
			count = count + 1
			if (count % 2 == 0) then
				print(v[1]..' needs to be in team 1')
				table.insert(lobby.players, #lobby.players+1, {
					player = v[1],
					kills = 0,
					deaths = 0,
				})
			else
				print(v[1]..' needs to be in team 2')
			end
		end
	end
	if gm == 'dm' then
		round_data.players = {}
		for k,v in pairs(lobby.players.active) do
			table.insert(round_data.players, #round_data.players+1, {
				player = v[1], 
				kills = 0,
				deaths = 0
			})
			print('[dm] adding '..v[1]..' to round players')
		end
	end
	if gm == 'br' then
		round_data.players = {}
		for k,v in pairs(lobby.players.active) do
			table.insert(round_data.players, #round_data.players+1, {
				player = v[1], 
				kills = 0,
				deaths = 0,
				alive = true
			})
			print('[br] adding '..v[1]..' to round players')
		end
	end

	round_pending = true
	round_spawned = {}

	for k, v in pairs(lobby.players.active) do
		print('sending fca-round:loading to '..v[1])
		TriggerClientEvent('fca-round:loading', v[1], map) -- tell the user to hide lobby interface and start loading
	end
end)

RegisterNetEvent('fca-round:spawned')
AddEventHandler('fca-round:spawned', function()
	print 'fca-round:spawned'
	local pname = GetPlayerName(source)

	TriggerClientEvent('fca-misc:text:LG', source, lobby_data.gamemodes[lobby_data.gamemode][2], {0,255,0}, 30)
	TriggerClientEvent('fca-misc:text:SM', source, lobby_data.gamemodes[lobby_data.gamemode][4], {255,255,255}, 30)

	if round_pending == true then
		-- round pending
		local ins = #round_spawned+1
		round_spawned[ins] = source
		print('adding round spawn to: '..ins)
		TriggerClientEvent('FeedM:showNotification', -1, '~b~'..pname..'~w~ has spawned')
		if #round_spawned >= #lobby_data.players.active then
			TriggerClientEvent('FeedM:showNotification', -1, '~g~START:~w~ 10 seconds...')
			round_start = seconds + 10
		else
			print(#round_spawned..' players out of '..#lobby_data.players.active..' spawned')
		end
	end
end)

function startRound()
	TriggerClientEvent('FeedM:showNotification', -1, '~g~STARTING!~w~ Good luck...')
	round_timeout = seconds + 1800
	round_pending = false
	round_active = true
	for k,v in pairs(lobby_data.players.active) do
		print('sending fca-round:start: '..v[1])
		TriggerClientEvent('fca-round:start', v[1])
		sendLoadout(v[1])
	end 
end

function endRound()
	-- body
	round_pending = false
	round_active = false
	TriggerEvent('fca-lobby:reset')
	TriggerClientEvent('fca-round:end', -1)
end

RegisterCommand("reset_lobby", function(source)
	if source > 0 then
		print 'whoareyou?'
	else
		endRound()
	end
	exports['fca-discord']:AddDiscordLog('player', '**The lobby has been force reset by an admin.**')
end)

-- do stuff every second
Citizen.CreateThread(function()
	while true do Citizen.Wait(1000)
		seconds = seconds + 1

		if round_pending then
			if (round_start - 5) == seconds then
				TriggerClientEvent('FeedM:showNotification', -1, '~g~START:~w~ 5 seconds...')
			end
			if round_start == seconds then
				startRound()
			end
		end

		if round_active then
			if round_timeout == seconds then
				TriggerClientEvent('FeedM:showNotification', -1, '~r~END:~w~ The game lasted more than 30 minutes.')
				endRound()
			end
		end
	end
end)
