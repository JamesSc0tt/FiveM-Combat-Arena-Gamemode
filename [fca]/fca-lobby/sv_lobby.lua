local lobbyActive = false
local config = {
	lobby_length = 60,
}
local lobbyInfo = {

	last = {
		gamemode = 'tdm',
		map = 1
	},



	gamemode = 'tdm',
	map = 1,
	game_active = false, -- is the current session active

	lobby_active = false,
	lobby_remaining = 60,

	maps = {
		-- {name, image, votes}
		{'Bolingbroke Penitentiary', 'bolingbroke.jpg', {}},
		{'Humane Labs', 'humanelabs.png', {}},
	},
	gamemodes = {
		-- {shortname, name, description, votes}
		{'tdm', 'Team Deathmatch', 'tdm.jpg', 'Players are split evenly randomly. First to 45 kills.', {}},
		{'dm', 'Deathmatch', 'tdm.jpg', 'All players vs eachother, first to 20 kills.', {}},
		{'br', 'Battle Royal', 'tdm.jpg', 'Last man standing, all players have 1 life and last man standing wins.', {}},
	},

	players = {
		lobby = {}, 
		active = {}, -- active players in a session 
		spectate = {}, -- dead / spectating players in a session
	},

	scores = {

	}
}


RegisterServerEvent('fca-lobby:reset')
AddEventHandler('fca-lobby:reset', function()
	-- add all current players to lobby and reset

	-- save old
	lobbyInfo.last['gamemode'] = lobbyInfo.gamemode
	lobbyInfo.last['map'] = lobbyInfo.map

	lobbyInfo.players = {
		lobby = {}, 
		active = {}, -- active players in a session 
		spectate = {}, -- dead / spectating players in a session
	}

	for k,v in pairs(lobbyInfo.maps) do
		-- reset votes
		lobbyInfo.maps[k][3] = {}
	end
	for k,v in pairs(lobbyInfo.gamemodes) do
		-- reset votes
		lobbyInfo.gamemodes[k][5] = {}
	end

	lobbyInfo.lobby_active = false
	lobbyInfo.game_active = false

	TriggerClientEvent('fca-lobby:reset', -1)
end)

local bypass_playlimits = {

}


function allLobbyMembersActive()
	local active = true
	for k,v in pairs(lobbyInfo.players.lobby) do
		if GetPlayerPing(v[1]) <= 0 then
			print(v[1]..' is not active in lobby!')
			active = false
		end
	end
	return active
end

RegisterServerEvent('fca-lobby:register')
AddEventHandler('fca-lobby:register', function()
	local disc = exports['fca-spawn']:GetPlayerDiscord(source)
	if not disc then
		DropPlayer(source, 'FCA-SPAWN : Could not detect discord ID')
	end
	local pname  = "**"..GetPlayerName(source).."**"

	local bypass_playlimit = false
	for k,v in pairs(bypass_playlimits) do
		if v == disc then
			print(disc..' is immune from lobby playlimit!')
			bypass_playlimit = true
		end
	end
	if not bypass_playlimit then
		-- check if player is somehow already in the table
		for k,v in pairs(lobbyInfo.players) do
			for key,val in pairs(v) do
				if val[3] == disc then
					lobbyInfo.players[k][key] = nil -- remove
					print(pname..' ('..disc..') already in player list & not in bypass_playlimits: '..key)
				end
			end
		end
	end
	if not lobbyInfo.lobby_active then
		if lobbyInfo.game_active then
			print('Game is active, adding player '..pname..' to spectate')
			TriggerClientEvent('FeedM:showNotification', -1, '~o~'..pname..' is now ~b~spectating~w~!')
			table.insert(lobbyInfo.players.spectate, {source, GetPlayerName(source), disc, false, false})
			exports['fca-discord']:AddDiscordLog('player', pname..' is now spectating!')

			TriggerClientEvent('fca-lobby:spectate', source)
		else
			exports['fca-discord']:AddDiscordLog('player', '```A new lobby has started```')

			-- start lobby
			lobbyInfo.lobby_active = true
			lobbyInfo.lobby_remaining = 60

			print('Lobby started, adding player '..pname..' to active')
			table.insert(lobbyInfo.players.lobby, {source, GetPlayerName(source), disc, false, false})
			TriggerClientEvent('fca-lobby:ui', source, lobbyInfo)
			
			Citizen.Wait(100) -- wait to make sure it's in the right order
			TriggerClientEvent('FeedM:showNotification', -1, '~o~'..pname..' has joined the lobby!')
			exports['fca-discord']:AddDiscordLog('player', pname..' has joined the lobby')

			
		end
	else
		-- check lobby is not empty
		if not allLobbyMembersActive() then
			-- someone has left, reset
			exports['fca-round']:endRound()
		else
			-- not first player in lobby :) 
			print('Lobby is active, adding player '..pname..' to active')
			TriggerClientEvent('FeedM:showNotification', -1, '~o~'..pname..' has joined the lobby!')
			table.insert(lobbyInfo.players.lobby, {source, GetPlayerName(source), disc, false, false})
			exports['fca-discord']:AddDiscordLog('player', pname..' has joined the lobby')

			TriggerClientEvent('fca-lobby:ui', source, lobbyInfo)
		end
	end
end)

RegisterServerEvent('fca-lobby:setReady')
AddEventHandler('fca-lobby:setReady', function()
	local pname = "**"..GetPlayerName(source).."**"
	print('got ready')
	for k,v in pairs(lobbyInfo.players.lobby) do
		if v[1] == source then
			lobbyInfo.players.lobby[k][5] = true
			exports['fca-discord']:AddDiscordLog('player', pname..' is ready to play!')
		end
	end
	TriggerClientEvent('fca-lobby:ui', -1, lobbyInfo)
end)

RegisterServerEvent('fca-lobby:addVote')
AddEventHandler('fca-lobby:addVote', function( t, id )
	local pname = "**"..GetPlayerName(source).."**"
	if t == 'maps' then
		-- remove old vote
		local changed = false
		local surpressdisc = false
		for k,v in pairs(lobbyInfo.maps) do
			for key, val in pairs(v[3]) do
				if val == source then
					if  k == id then
						-- dont spam disc for same
						surpressdisc = true
					end
					changed = true
					lobbyInfo.maps[k][3][key] = nil
				end
			end
		end
		-- add new vote
		table.insert(lobbyInfo.maps[id][3], source)
		print(lobbyInfo.maps[id][1]..' now has '..#lobbyInfo.maps[id][3]..' votes')
		if not surpressdisc then
			if changed then
				exports['fca-discord']:AddDiscordLog('player', pname..' has changed their **MAP** vote to: '..lobbyInfo.maps[id][1]..' `Total '..#lobbyInfo.maps[id][3]..' votes`')
			else
				exports['fca-discord']:AddDiscordLog('player', pname..' has voted for **MAP**: '..lobbyInfo.maps[id][1]..' `Total '..#lobbyInfo.maps[id][3]..' votes`')
			end
		end
	end

	if t == 'gamemodes' then
		-- remove old vote
		local changed = false
		local surpressdisc = false
		for k,v in pairs(lobbyInfo.gamemodes) do
			for key, val in pairs(v[5]) do
				if val == source then
					if  k == id then
						-- dont spam disc for same
						surpressdisc = true
					end
					changed = true
					lobbyInfo.gamemodes[k][5][key] = nil
				end
			end
		end
		-- add new vote
		table.insert(lobbyInfo.gamemodes[id][5], source)
		print(lobbyInfo.gamemodes[id][2]..' now has '..#lobbyInfo.gamemodes[id][5]..' votes')
		if not surpressdisc then
			if changed then
				exports['fca-discord']:AddDiscordLog('player', pname..' has changed their **GAMEMODE** vote to: '..lobbyInfo.gamemodes[id][2]..' `Total '..#lobbyInfo.gamemodes[id][5]..' votes`')
			else
				exports['fca-discord']:AddDiscordLog('player', pname..' has voted for **GAMEMODE**: '..lobbyInfo.gamemodes[id][2]..' `Total '..#lobbyInfo.gamemodes[id][5]..' votes`')
			end
		end
	end

	TriggerClientEvent('fca-lobby:ui', -1, lobbyInfo)
end)

Citizen.CreateThread(function()
	-- process lobby every 1 second
	while true do Citizen.Wait(1000)
		if lobbyInfo.lobby_active then
			lobbyInfo.lobby_remaining = lobbyInfo.lobby_remaining - 1
			-- count ready compare to num of players
			local ready = false
			local ready_players = 0
			for k,v in pairs(lobbyInfo.players.lobby) do
				if v[5] == true then
					ready_players = ready_players + 1
				end
			end
			if ready_players >= #lobbyInfo.players.lobby then
				ready = true
			end

			-- force players to 2 to test
			--lobbyInfo.players.lobby = {
			--	{1, 'JamesSc0tt1', 'something', false, false},
			--	{2, 'JamesSc0tt2', 'something', false, false}
			--}

			if lobbyInfo.lobby_remaining <= 1 or ready then
				-- start game
				if #lobbyInfo.players.lobby > 1 then
					-- start game
					-- work out winners, or random
					local winner_map = math.random(1, #lobbyInfo.maps)
					local winner_gm = math.random(1, #lobbyInfo.gamemodes)

					local map_votes = {0, winner_map}
					for k,v in pairs(lobbyInfo.maps) do
						if #v[3] > map_votes[1] then
							map_votes = {#v[3], k}
						end
					end
					winner_map = map_votes[2]

					local gm_votes = {0, winner_gm}
					for k,v in pairs(lobbyInfo.gamemodes) do
						if #v[5] > gm_votes[1] then
							gm_votes = {#v[5], k}
						end
					end
					winner_gm = gm_votes[2]

					local discstring = '```Voting has ended, results:\n'
					discstring = discstring .. ' - Winning map: '..lobbyInfo.maps[map_votes[2]][1]..' ('..map_votes[1]..' votes)\n'
					discstring = discstring .. ' - Winning gamemode: '..lobbyInfo.gamemodes[gm_votes[2]][2]..' ('..gm_votes[1]..' votes)```'

					exports['fca-discord']:AddDiscordLog('player', discstring)
				
					lobbyInfo.lobby_active = false
					lobbyInfo.game_active = true

					lobbyInfo.map = winner_map
					print('winner map: '..winner_map)
					lobbyInfo.gamemode = winner_gm
					print('winner gm: '..winner_gm)

					lobbyInfo.players.active = lobbyInfo.players.lobby
					lobbyInfo.players.lobby = {}

					TriggerEvent('fca-round:start', lobbyInfo)
				else	
					-- reset counter, not enough players
					lobbyInfo.lobby_remaining = 60
					-- reset player ready states
					for k,v in pairs(lobbyInfo.players.lobby) do
						lobbyInfo.players.lobby[k][5] = false
					end
					TriggerClientEvent('chat:addMessage', -1, {
						color = { 255, 0, 0},
						multiline = true,
						args = {"FCA", "A lobby can not be started with only 1 player, waiting for more before continuing..."}
					})
					exports['fca-discord']:AddDiscordLog('player', '```A lobby can not be started with only 1 player, waiting for more before continuing...```')
				end
			end
			TriggerClientEvent('fca-lobby:ui', -1, lobbyInfo)
		end
	end
end)

RegisterCommand("start_lobby", function(source)
	if source > 0 then
		print 'whoareyou?'
	else
		lobbyInfo.lobby_remaining = 1
	end
end)