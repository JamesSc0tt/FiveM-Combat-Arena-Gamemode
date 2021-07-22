local seconds = 0
local round_start = 0

local round_data = {

}

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
	lobby_data = lobby
	local gm = lobby.gamemodes[lobby.gamemode][1]
	local map = lobby.map


	if gm == 'tdm' then
		round_data.teams = {
			[1] = {},
			[2] = {},
		}
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


-- do stuff every second
Citizen.CreateThread(function()
	while true do Citizen.Wait(1000)
		seconds = seconds + 1

		if round_pending then
			if (round_start - 15) == seconds then
				TriggerClientEvent('FeedM:showNotification', -1, '~g~START:~w~ 15 seconds...')
			end
			if round_start == seconds then
				TriggerClientEvent('FeedM:showNotification', -1, '~g~STARTING!~w~ Good luck...')
			end
			--[[
			if round_start >= seconds then
				-- start round
				for k,v in pairs(lobby_data.players.active) do
					TriggerClientEvent('fca-round:start', v[1])
				end
				round_pending = false
				round_active = true
			end
			]]
		end
	end
end)
