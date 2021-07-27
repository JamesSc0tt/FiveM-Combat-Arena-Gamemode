local API_URL = 'https://combatarena.co/apiv1'
local DEBUG_MODE = true

function api_request(endpoint, args, postdata, headers)
	local response = false
	if string.sub(endpoint, 1, 1) ~= '/' then
		endpoint = '/'..endpoint
	end
	if not headers then
		headers = { ["Content-Type"] = 'application/json' }
	end
	postdata['token'] = '62JiTzy3rLAWJuRTdRhtsBfRxjzKnsVnOdtmHBl'
	for k,v in pairs(postdata) do
		print(k..' => '..v)
	end
	print('---')
	print(json.encode(postdata))
	local url = API_URL..endpoint


	PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        print(errorCode)
        print(resultData)
        print(resultHeaders)
    end, 'POST', json.encode(postdata), {["Content-Type"] = "application/json"})

end

RegisterServerEvent('fca-api:api_request')
AddEventHandler('fca-api:api_request', api_request)