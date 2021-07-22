local round_data = {

}

function handle_death()

end

AddEventHandler('baseevents:onPlayerKilled', function(player, killer, reason)

end)

AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)

end)

RegisterNetEvent('fca-round:start', function(lobby)
	local gm = lobby.gamemodes[lobby.gamemode][1]
	local map = lobby.map

	for k, v in pairs(lobby.players.active) do
		TriggerClientEvent('fca-round:loading', v[1], map) -- tell the user to hide lobby interface and start loading
	end

	if gm == 'tdm' then
		round_data.teams = {
			[1] = {},
			[2] = {},
		}
	end

end)