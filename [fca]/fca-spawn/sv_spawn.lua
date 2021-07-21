function GetPlayerDiscord(src)
	for k,v in pairs(GetPlayerIdentifiers(src))do
		if string.sub(v, 1, string.len("discord:")) == "discord:" then
			return v
		end
	end
	return false
end

function GetPlayerSteam64(src)
	local s = false
	for k,v in pairs(GetPlayerIdentifiers(src))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			s = v
		end
	end
	s = string.sub(string.len("steam:"), string.len(s))
	return tonumber(s, 16)
end