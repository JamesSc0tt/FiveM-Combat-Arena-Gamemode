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
	end
end)