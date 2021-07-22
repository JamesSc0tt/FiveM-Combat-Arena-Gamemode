local seconds = 0
local round_start = 0

local round_data = {}
local lobby_data = {}

local round_pending = false
local round_spawned = {}
local round_active = false

function handle_death()

end

AddEventHandler('baseevents:onPlayerKilled', function(player, killer, reason)

end)

AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)

end)

RegisterNetEvent('fca-round:start', function(lobby)
	print 'fca-round:start'
	lobby_data = lobby -- reset at start of each round
	local gm = lobby.gamemodes[lobby.gamemode][1]
	local map = lobby.map

	round_data = {} -- reset at start of each round

	if gm == 'tdm' then
		round_data.teams = {
			kilks = {
				[1] = 0,
				[2] = 0,
			},
			players = {
				[1] = {},
				[2] = {},
			}
		}
		for k,v in pairs(lobby.players.active) do
			if (k % 2 == 0) then
				table.insert(round_data.teams[1].players, #round_data.teams[1].players+1, {
					player = v[1], 
					kills = 0,
					deaths = 0
				})
				print('adding '..v[1]..' to team 1')
			else
				table.insert(round_data.teams[2].players, #round_data.teams[2].players+1, {
					player = v[1], 
					kills = 0,
					deaths = 0
				})
				print('adding '..v[1]..' to team 2')
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
			print('adding '..v[1]..' to round players')
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
	lobby_data.players.active = {{1}}

	TriggerClientEvent('fca-misc:text:LG', source, lobby_data.gamemodes[lobby_data.gamemode][2], {0,255,0}, 30)
	TriggerClientEvent('fca-misc:text:SM', source, lobby_data.gamemodes[lobby_data.gamemode][4], {255,255,255}, 30)

	if round_pending == true then
		-- round pending
		round_spawned[source] = true
		TriggerClientEvent('FeedM:showNotification', -1, '~b~'..pname..'~w~ has spawned')
		if #round_spawned >= #lobby_data.players.active then
			TriggerClientEvent('FeedM:showNotification', -1, '~g~START:~w~ 30 seconds...')
			round_start = seconds + 30
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
			if (round_start - 15) == seconds then
				TriggerClientEvent('FeedM:showNotification', -1, '~g~START:~w~ 15 seconds...')
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
