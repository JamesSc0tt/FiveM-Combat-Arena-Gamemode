local TDM_REQUIRED_KILLS = 80
local DM_REQUIRED_KILLS = 40

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
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
	{
		name = 'PISTOL',
		items = {
			{'weapon_pistol', 1},
			{'ammo_pistol', 5},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
	{
		name = 'SMG',
		items = {
			{'weapon_smg', 1},
			{'ammo_smg', 5},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
	{
		name = 'PUMP SHOTGUN',
		items = {
			{'weapon_pumpshotgun', 1},
			{'ammo_shotgun', 5},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
	{
		name = 'ASSAULT RIFLE',
		items = {
			{'weapon_assaultrifle', 1},
			{'ammo_rifle', 5},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
	{
		name = 'CARBINE RIFLE',
		items = {
			{'weapon_carbinerifle', 1},
			{'ammo_rifle', 5},
			{'armor', 2},
			{'bandage', 10},
			{'painkillers', 5},
			{'oxy', 5}
		},
	},
}

function sendLoadout(player)
	if round_active then
		local l = loadouts[round_data.loadout]
		print('Sending loadout '..l.name..' to player '..player)
	
		for key, item in pairs(l.items) do
			TriggerClientEvent('fsn_inventory:item:add', player, item[1], item[2])
		end
		TriggerClientEvent('FeedM:showNotification', player, 'You got loadout: ~b~'..l.name..'~w~!')
	end
end
RegisterNetEvent('fca-round:death')
AddEventHandler('fca-round:death', function(died, killer)
	if not round_active then return end
	print 'gotdeath'
	-- insert kill to team if TDM
	local died_data = {}
	for key, ply in pairs(round_data.players) do 
		if ply.player == died then
			died_data = ply
			print('Adding death to player '..GetPlayerName(ply.player))
			round_data.players[key]['deaths'] = round_data.players[key]['deaths'] + 1
			print(GetPlayerName(ply.player)..' now has '..round_data.players[key]['deaths']..' deaths')
			if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
				round_data.players[key]['alive'] = false
				print('[br] '..GetPlayerName(ply.player)..' is now out of the game, dead')
			end

			-- api endpoint stuff
			exports['fca-api']:api_request('/register.php', {}, {
				discord = exports['fca-spawn']:GetPlayerDiscord(ply.player),
				register = 'deaths',
				gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
				amount = 1,
			}, false)
		end
	end

	if killer then
		for key, ply in pairs(round_data.players) do
			if ply.player == killer and ply.player ~= died then
				-- killer and did not kill selves
				if died_data.team and died_data.team == ply.team then
					print('[tdm] Friendly fire! Kill not registered')
					TriggerClientEvent('FeedM:showNotification', ply.player, '~r~Watch out! You killed a team mate.')
				else
					print('Adding kill to player '..GetPlayerName(ply.player))
					round_data.players[key]['kills'] = round_data.players[key]['kills'] + 1
					print(GetPlayerName(ply.player)..' now has '..round_data.players[key]['kills']..' kills')

					-- api endpoint stuff
					exports['fca-api']:api_request('/register.php', {}, {
						discord = exports['fca-spawn']:GetPlayerDiscord(ply.player),
						register = 'kills',
						gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
						amount = 1,
					}, false)
				end
			end
		end
	end

	local end_round = false
	local win_data = {}
	-- check if anybody is a winner
	-- do gamemode maths
	if lobby_data.gamemodes[lobby_data.gamemode][1] == 'tdm' then
		local count = {}
		for k,v in pairs(round_data.players) do
			if count[v.team] then
				count[v.team] = count[v.team] + v.kills
				print('[tdm] adding '..v.kills..' to team '..v.team)
			else
				count[v.team] = v.kills
				print('[tdm] set '..v.team..' kills to '..v.kills)
			end
		end

		for k,v in pairs(count) do
			print('[tdm] '..k..' has '..v..' out of '..TDM_REQUIRED_KILLS..' required kills')
			if v >= TDM_REQUIRED_KILLS then
				print('[tdm] '..k..' has satisfied kill number for win')
				-- team has won???
				end_round = true
				win_data = {
					winner = k,
					kills = v,
					required = TDM_REQUIRED_KILLS
				}

				-- api endpoint stuff
				for k,ply in pairs(round_data.players) do
					if ply.team == win_data.winner then
						exports['fca-api']:api_request('/register.php', {}, {
							discord = exports['fca-spawn']:GetPlayerDiscord(ply.player),
							register = 'wins',
							gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
							amount = 1,
						}, false)
					else
						exports['fca-api']:api_request('/register.php', {}, {
							discord = exports['fca-spawn']:GetPlayerDiscord(ply.player),
							register = 'losses',
							gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
							amount = 1,
						}, false)
					end
				end
			end
		end
	end
	if lobby_data.gamemodes[lobby_data.gamemode][1] == 'dm' then
		for k,v in pairs(round_data.players) do
			print('[dm] '..GetPlayerName(v.player)..' has '..v.kills..' out of '..DM_REQUIRED_KILLS..' required kills')
			if v.kills >= DM_REQUIRED_KILLS then
				print('[dm] '..GetPlayerName(v.player)..' has satisfied kill number for win')
				end_round = true
				win_data = {
					winner = GetPlayerName(v.player),
					kills = v.kills,
					player = v.player,
					required = DM_REQUIRED_KILLS
				}

				-- api endpoint stuff
				exports['fca-api']:api_request('/register.php', {}, {
					discord = exports['fca-spawn']:GetPlayerDiscord(v.player),
					register = 'wins',
					gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
					amount = 1,
				}, false)
			end
		end 

		for k,v in pairs(round_data.players) do
			if v.player ~= win_data.player then
				exports['fca-api']:api_request('/register.php', {}, {
					discord = exports['fca-spawn']:GetPlayerDiscord(v.player),
					register = 'losses',
					gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
					amount = 1,
				}, false)
			end
		end
	end
	if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
		local count = 0 
		local alive = false
		for k,v in pairs(round_data.players) do
			if v.alive then
				alive = v
				count = count + 1
			end 
		end
		if count <= 1 then
			print('[br] only '..count..' players alive, deciding winner')
			end_round = true
			win_data = {
				winner = GetPlayerName(alive.player),
				kills = alive.kills,
				player = alive.player,
				required = 0
			}
			
			-- api endpoint stuff
			exports['fca-api']:api_request('/register.php', {}, {
				discord = exports['fca-spawn']:GetPlayerDiscord(alive.player),
				register = 'wins',
				gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
				amount = 1,
			}, false)

			for k,v in pairs(round_data.players) do
				if v.player ~= win_data.player then
					exports['fca-api']:api_request('/register.php', {}, {
						discord = exports['fca-spawn']:GetPlayerDiscord(v.player),
						register = 'losses',
						gamemode = lobby_data.gamemodes[lobby_data.gamemode][1],
						amount = 1,
					}, false)
				end
			end
		else
			print('[br] '..count..' players remaining')
		end
	end

	if end_round then
		-- someone has won?
		print 'the game has been won?'
		exports['fca-discord']:AddDiscordLog('player', '```The game has ended.\n\nWinner: '..win_data.winner..' with '..win_data.kills..' kills```')

		local endtimenow = GetGameTimer() + 10000

		TriggerClientEvent('fca-misc:text:LG', -1, win_data.winner..' wins!', {0,255,0}, 10)
		TriggerClientEvent('fca-misc:text:SM', -1, 'With '..win_data.kills..' kills', {255,255,255}, 10)

		while GetGameTimer() <= endtimenow do
			Citizen.Wait(1)
		end

		endRound()
	else
		-- send respawn unless br
		if lobby_data.gamemodes[lobby_data.gamemode][1] ~= 'br' then
			print('sending round:respawn to'..died)
			TriggerClientEvent('fca-round:respawn', died)
			sendLoadout(died)
		else	
			TriggerEvent('fca-round:setSpectate', died) -- put into spectate mode if in battle royale
		end
	end
end)

AddEventHandler('playerDropped', function (reason)
	-- remove from active lobby / players
	local pname = GetPlayerName(source)
	if round_active or round_pending then
		for playerkey,playertable in pairs(round_data.players) do
			if playertable.player == source then
				print('[tdm] '..source..' has left the game, removing from active players.')
				round_data.players[playerkey] = nil
			end
		end
		-- if was last player or under 2 players

		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'tdm' then -- gamemode specific
			local count = {}
			for k,v in pairs(round_data.players) do
				if not count[v.team] then
					count[v.team] = 1
				else
					count[v.team] = count[v.team] + 1
				end
				print(v.team..' has '..count[v.team]..' left!')
			end
			for k,v in pairs(count) do
				print(k..' has '..v..' left!')
				if v <= 0 then
					print('not enough players, '..k..' team have forfeited')
					endRound()
				end
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'dm' then
			if #round_data.players < 2 then
				print('not enough players, need to forfeit')
					endRound()
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
			if #round_data.players < 2 then
				print('not enough players, need to forfeit')
				endRound()
			end
		end
	end
end)

RegisterNetEvent('fca-round:start')
AddEventHandler('fca-round:start', function(lobby)
	print 'fca-round:start'
	lobby_data = lobby -- reset at start of each round
	local gm = lobby.gamemodes[lobby.gamemode][1]
	local map = lobby.map

	round_data = {} -- reset at start of each round

	round_data.loadout = math.random(1, #loadouts)
	print('Random loadout: '..loadouts[round_data.loadout].name)

	if gm == 'tdm' then
		local count = 0
		round_data.players = {}
		for k,v in pairs(lobby.players.active) do
			table.insert(round_data.players, #round_data.players+1, {
				player = v[1], 
				kills = 0,
				deaths = 0
			})
			print('[tdm] adding '..v[1]..' to round players')
		end
		-- sorting hat for teams
		for k,v in pairs(round_data.players) do
			count = count+1
			if (count % 2 == 0) then
				-- team 1
				round_data.players[k]['team'] = 'Blue Team'
			else
				-- team 2
				round_data.players[k]['team'] = 'Red Team'
			end
			print('[tdm] Added player '..GetPlayerName(round_data.players[k].player)..' to team: '..round_data.players[k]['team'])
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

RegisterNetEvent('fca-round:setSpectate')
AddEventHandler('fca-round:setSpectate', function(ply)
	if round_active then
		TriggerClientEvent('fca-spectate:enable', ply, round_data.players)
		print'sentspectateplayerlist'
	else
		print'trying to spectateoutside of round?'
	end 
end)

RegisterNetEvent('fca-round:spawned')
AddEventHandler('fca-round:spawned', function()
	if not round_pending then return end
	print 'fca-round:spawned'
	local pname = GetPlayerName(source)

	TriggerClientEvent('fca-misc:text:LG', source, lobby_data.gamemodes[lobby_data.gamemode][2], {0,255,0}, 12)
	TriggerClientEvent('fca-misc:text:SM', source, lobby_data.gamemodes[lobby_data.gamemode][4], {255,255,255}, 10)

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
			TriggerClientEvent('FeedM:showNotification', source, 'Waiting for other players to spawn...')
			print(#round_spawned..' players out of '..#lobby_data.players.active..' spawned')
		end
	end
end)

function startRound()
	TriggerClientEvent('FeedM:showNotification', -1, '~g~STARTING!~w~ Good luck...')
	round_timeout = seconds + 1800
	round_pending = false
	round_active = true
	 -- loadouts[round_data.loadout].name
	exports['fca-discord']:AddDiscordLog('player', '```The game has started! Chosen loadout: '..loadouts[round_data.loadout].name..'```')
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
	TriggerClientEvent('fca-spectate:reset', -1)
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
				print('The game lasted more than 30 minutes, it was ended.')
				endRound()
			end
		end
	end
end)
