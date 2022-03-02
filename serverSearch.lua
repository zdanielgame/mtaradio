local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

addEvent ("searchTrack", true)
addEventHandler ("searchTrack", resourceRoot, function(text)
	fetchRemote("https://server1.mtabrasil.com.br/youtube/search?q="..urlencode(text), readData, "", true, client)
end)

function readData (data, err, pl)
	local music = {}
	local lastPos = 0
	
	if data == "ERROR" then return end
	for i = 1, 50 do
		local startS = utf8.find( data, "<div title=\"Ouvir ", lastPos )
		local _, endS = utf8.find( data, "</a></div></div>", startS )
	
		local artist, musicName = getMusicArtist ( data, startS )
		local url = getMusicURL ( data, startS )
		
		if artist and musicName then
		    table.insert( music, { artist, musicName, url } )
		end
	    lastPos = endS
	end
	
	triggerClientEvent (pl, "okSearch", resourceRoot, music)
end

function getPlayURLForMusic (data, err, veh, volume)
	if not data then return end
    local pos_start, pos_e = utf8.find( data, "\"url\":\"" ) 
	local pos_end = utf8.find( data, "\"}", pos_e )
	if not pos_e or not pos_end then return end
	local url = utf8.sub( data, pos_e, pos_end )
	local url = utf8.gsub( url, "\"", "")
	
	setElementData (veh, "radio:stream", {url, volume})
	triggerClientEvent(root, "updateSounds", resourceRoot, veh, url, volume)
end

function getMusicArtist ( data, startS )
	if not data then return end
    local pos_start, pos_e = utf8.find( data, "Ouvir ", startS )
	local pos_end = utf8.find( data, " &ndash; ", pos_e )
	if not pos_e or not pos_end then 
		return
	end
	local text_artist = utf8.sub( data, pos_e, pos_end )
	
	local pos_start, pos_e = utf8.find( data, "&ndash; ", pos_end )
	local pos_end  = utf8.find( data, "\" ", pos_e )
	
	local text_music = utf8.sub( data, pos_e, pos_end )
	text_music = utf8.gsub( text_music, "\"", "")
	
	return text_artist, text_music
end

function getMusicURL ( data, startS )
    local pos_start, pos_e = utf8.find( data, "data.-url=\"", startS )
	local _, pos_end  = utf8.find( data, ".json\" ", pos_e )
	
	local url = utf8.sub( data, pos_e, pos_end )
	url = utf8.gsub( url, "\"", "")

	return url
end