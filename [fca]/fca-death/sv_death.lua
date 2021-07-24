RegisterServerEvent('fca-death:report')
AddEventHandler('fca-death:report', function(info)
	if info then
		for k,v in pairs(info) do
			if type(v) == 'table' then
				for key, value in pairs(v) do
					print('info['..k..']['..key..'] = '..tostring(value))
				end
			else
				print('info['..tostring(k)..'] = '..tostring(v))
			end
		end

		-- death messages

		local midstring = ''

		local killedstrings = {'brutally murdered', 'ended'}
		local suicidestrings = {'committed suicide', 'took the easy way out'}

		if not info[1].id  then
			midstring = suicidestrings[math.random(1,#suicidestrings)]
			exports['fca-discord']:AddDiscordLog('player', '**'..GetPlayerName(source)..'** '..midstring)
			TriggerClientEvent('FeedM:showNotification', -1, '~b~'..GetPlayerName(source)..'~w~ '..midstring)
			TriggerEvent('fca-round:death', source, false)
		else
			-- new midstring
			midstring = killedstrings[math.random(1,#killedstrings)]
			exports['fca-discord']:AddDiscordLog('player', '**'..info[1].name..'** '..midstring..' **'..GetPlayerName(source)..'**')
			TriggerClientEvent('FeedM:showNotification', -1, '~b~'..info[1].name..'~w~ '..midstring..' ~b~'..GetPlayerName(source))
			TriggerEvent('fca-round:death', source, info[1].id)
		end
	end
end)