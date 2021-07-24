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
RegisterNetEvent('fca-round:death')
AddEventHandler('fca-round:death', function(died, killer)
	if not round_active then return end
	print 'gotdeath'
	-- insert kill to team if TDM
	for key, ply in pairs(round_data.players) do 
		if ply.player == died then
			print('Adding death to player '..GetPlayerName(ply.player))
			round_data.players[key]['deaths'] = round_data.players[key]['deaths'] + 1
			print(GetPlayerName(ply.player)..' now has '..round_data.players[key]['deaths']..' deaths')
			if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
				round_data.players[key]['alive'] = false
				print('[br] '..GetPlayerName(ply.player)..' is now out of the game, dead')
			end
		end
	end

	if killer then
		for key, ply in pairs(round_data.players) do
			if ply.player == killer and ply.player ~= died then
				-- killer and did not kill selves
				print('Adding kill to player '..GetPlayerName(ply.player))
				round_data.players[key]['kills'] = round_data.players[key]['kills'] + 1
				print(GetPlayerName(ply.player)..' now has '..round_data.players[key]['kills']..' kills')
			end
		end
	end

	-- do gamemode maths
	if lobby_data.gamemodes[lobby_data.gamemode][1] == 'tdm' then

	end

	local end_round = false
	local win_data = {}
	-- check if anybody is a winner

	if end_round then
		-- someone has won?
	else
		-- send respawn unless br
		if lobby_data.gamemodes[lobby_data.gamemode][1] ~= 'br' then

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
			end
			for k,v in pairs(count) do
				if v <= 0 then
					print('not enough players, '..k..' team have forfeited')
				end
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'dm' then
			if #round_data.players < 2 then
				print('not enough players, need to forfeit')
			end
		end
		if lobby_data.gamemodes[lobby_data.gamemode][1] == 'br' then
			if #round_data.players < 2 then
				print('not enough players, need to forfeit')
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
				endRound()
			end
		end
	end
end)
