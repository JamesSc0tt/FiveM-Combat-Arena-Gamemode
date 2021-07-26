local API_URL = 'https://combatarena.co/apiv1'
local DEBUG_MODE = false

function api_request(endpoint, args, postdata, headers)
	local response = false
	if string.sub(endpoint, 1, 1) ~= '/' then
		endpoint = '/'..endpoint
	end
	if not headers then
		headers = {}
	end
	local url = API_URL..endpoint
	if (postdata) then
		PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
			response['errorCode'] = errorCode
			response['resultData'] = resultData
			response['resultHeaders'] = resultHeaders

			if DEBUG_MODE then
				print('fca-api : response')
				print(' - errorCode: '..errorCode)
				print(' - resultData: '..resultData)
				print(' - resultHeaders: '..resultHeaders)
			end
		end, 'POST', postdata, headers)
	else
		PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
			response['errorCode'] = errorCode
			response['resultData'] = resultData
			response['resultHeaders'] = resultHeaders

			if DEBUG_MODE then
				print('fca-api : response')
				print(' - errorCode: '..errorCode)
				print(' - resultData: '..resultData)
				print(' - resultHeaders: '..resultHeaders)
			end
		end, 'GET', {}, headers)
	end
end

RegisterServerEvent('fca-api:api_request')
AddEventHandler('fca-api:api_request', api_request)