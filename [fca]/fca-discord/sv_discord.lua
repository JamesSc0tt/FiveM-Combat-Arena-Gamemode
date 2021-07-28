
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

local lastmsg = ''

function AddDiscordLog(t, l, src)
	if not enabled then return end
	if lastmsg == l then return end
	lastmsg = l
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

Info = {
    botToken = "Bot " .. "ODY3NDA4Mjk5Nzc0ODM2NzM2.YPgq7g.uGjszZzIp5CUjbZ1lmJ4pT-WSME",
    guildId = "867360466048647178",
}

function request(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(errorCode, resultData, resultHeaders)
        data = {data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = Info.botToken})
    
    while data == nil do
        Citizen.Wait(0)
    end
    
    return data
end
function roleCheck(user, role, alerts)
    local userId = nil
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            userId = string.gsub(id, "discord:", "")
            if alerts then print("^6[fca-discord]^0 Turquoise Banana for ID: " .. userId) end -- Found Discord ID.
            break
        end
    end
    local userRole = nil
    if type(role) == "number" then
        userRole = tostring(role)
    else
        userRole = Info.Whitelisted
    end
    
    if userId then
        local endpoint = ("guilds/%s/members/%s"):format(Info.guildId, userId)
        local member = request("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            for i = 1, #roles do
                if roles[i] == userRole then
                    if alerts then print("^6[fca-discord]^0 Lilac Banana for ID: " .. userId) end -- Has Agreement role
                    return true
                end
            end
            if alerts then print("^6[fca-discord]^0 Red Banana for ID: " .. userId) end -- Not Found
            return false
        else
            if alerts then print("^6[fca-discord]^0 A Yellow Banana occured for ID: " .. userId) end -- User isn't in the Discord [Yellow Banana]
            return false
        end
    else
        return false
    end
end
exports("roleCheck", roleCheck)
