sounds = {}

addEvent ("updateVolume", true)
addEventHandler ("updateVolume", resourceRoot, function(v)
	if not sounds[client.vehicle] then return end
	sounds[client.vehicle].volume = v
	triggerClientEvent (root, "updateVolume", resourceRoot, client.vehicle, v)
end)

addEvent ("toggleRadio", true)
addEventHandler ("toggleRadio", resourceRoot, function()
	if not sounds[client.vehicle] then return end
	sounds[client.vehicle] = nil
	triggerClientEvent (root, "toggleRadio", resourceRoot, client.vehicle)
	collectgarbage()
end)

addEvent ("createStation", true)
addEventHandler ("createStation", resourceRoot, function (station, volume, isURL)
	local veh = client.vehicle
	if not veh then
		outputChatBox ("Você tem que estar no carro para ligar o rádio.", client, 255, 0, 0)
		return
	end
	
	if not isURL then
		sounds[veh] = {
			station = station,
			volume = 2*volume,
		}
		setElementData (veh, "radio:stream", {station, volume})
		triggerClientEvent (root, "updateSounds", resourceRoot, veh, station, volume)
	else
		sounds[veh] = {
			station = "https://server1.mtabrasil.com.br"..utf8.gsub( station, " ", "" ),
			volume = 2*volume,
		}
	
		fetchRemote("https://server1.mtabrasil.com.br"..utf8.gsub( station, " ", "" ), getPlayURLForMusic, "", false, veh, volume)
	end
end)

function destroy ()
	if source.type ~= "vehicle" then return end
	if not sounds[source] then return end
	triggerClientEvent (root, "toggleRadio", resourceRoot, source)
	sounds[source] = nil
	collectgarbage()
end
addEventHandler ("onElementDestroy", root, destroy)
addEventHandler ("onVehicleExplode", root, destroy)