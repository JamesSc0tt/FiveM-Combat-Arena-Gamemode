
local currentServer = 1
local enabled = true

local servers = {
	[1] = {
		playerLogChannel = 'https://discordapp.com/api/webhooks/867420207790293043/R_8MADQe8yQCVmCJcO-idQ24UE0fAKktCPGdCOYOv28EyOrvaHD3fRu6O0gIjHGWb4yd', 
		adminLogChannel = 'https://discordapp.com/api/webhooks/867448746077847562/2VaQD0xgj_wUn_21DC5g1fSMTTqyQZSNK5R0Z07fFCJeBl1AA7dQLhMg2vmkgoXAWCvV',
	},
	[2] = {
		playerLogChannel = '867367390903926804', 
		adminLogChannel = '867405810119475230',
	},
}

function AddDiscordLog(t, l, src)
	if not enabled then return end
	if not servers[currentServer][t..'LogChannel'] then
		print 'unknown discord log type'
	else
		if src then
			local at = exports['fca-spawn']:GetPlayerDiscord(src)
			at = string.sub(at, string.len("discord::"), string.len(at))
			at = '<@'..at..'>'
			l = string.gsub(l, '{discord_tag}', at)
		else
			l = string.gsub(l, '{discord_tag}', '{MISSING_SRC}')
		end
		PerformHttpRequest(servers[currentServer][t..'LogChannel'], function(err, text, headers) end, 'POST', json.encode({username = 'FiveM Combat Arena - Server #1', content = l}), { ['Content-Type'] = 'application/json' })
	end	
end