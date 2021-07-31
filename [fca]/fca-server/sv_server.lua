local current_server = 'DEVELOPMENT'
local current_ip = 'localhost'

local known_servers = {}
known_servers['198.244.149.211'] = 'LIVE1'

PerformHttpRequest('https://ip-check.online/myip.php', function(err, text, headers)
	local ip =  tostring(text)
	current_ip = ip
	if known_servers[ip] then
		current_server = known_servers[ip]
	end
end)

function isLIVE()
	return current_server ~= 'DEVELOPMENT'
end

function currentServer()
	return current_server
end 

function currentIP()
	return current_ip
end