local scroll = (290*px) * 0.3
local activeVolume = false

local volume = (scroll + math.lerp(0, 10, scroll/290*px))/290*px
local prevVolume = {}

RTS = {
	mylist = dxCreateRenderTarget (290*px, 355*px, true),
	radio = dxCreateRenderTarget (290*px, 290*px, true),
	search = dxCreateRenderTarget (290*px, 280*px, true),
}

local fonts = { -- шриффты
	[1] = dxCreateFont("font/proximanova_semibold.ttf", 10),
	[2] = dxCreateFont("font/proximanova_semibold.ttf", 9),
}

scrolls = { -- c - текущий scroll, m - максимальный
	radio = {
		c = 0,
		m = 0,
	},
	search = {
		c = 0,
		m = 0,
	},
	mylist = {
		c = 0,
		m = 0,
	},
}

local render = function()
	  
	dxDrawRectangle(sx/2 - 150*px, sy-230*px, 300*px, 40*px, tocolor(29,32,41,170)) -- Подзаголовок
	dxDrawRectangle(sx/2 - 150*px, sy-230*px, 300*px, 5*px, tocolor(212,51,57,255)) -- Line  
	dxCreateText ("Rádio FELICIDADE CITY", sx/2 - 150*px, sy-230*px, 300*px, 40*px, tocolor (255, 255, 255), 1, fonts[1], "center", "center")
	  
    dxDrawRectangle(sx/2 - 150*px, sy-180*px, 300*px, 150*px, tocolor(29,32,41,170)) -- Fon
	
	dxDrawButton ("Som Ligado/Desligado", sx/2 - 145*px, sy-170*px, 290*px, 25*px, "onVolumeOffOn")
	
	dxDrawButton ("Pesquisa de música", sx/2 - 145*px, sy-140*px, 140*px, 25*px, "toggleSearch")
	
	dxDrawButton ("Música selecionada", sx/2 + 5*px, sy-140*px, 140*px, 25*px, "togglePlaylist")
	
	dxDrawButton ("Estações de radio", sx/2 - 145*px, sy-110*px, 290*px, 25*px, "toggleStations")
	
	dxDrawButton ("Rádio Ligado/Desligado", sx/2 - 145*px, sy-80*px, 290*px, 25*px, "toggleRadio")
	
	dxDrawScroll (sx/2 - 145*px, sy-50*px, 290*px, 15*px, 10*px, scroll, true)
	
	dxCreateText ("Volume: "..math.ceil(volume*100).."%", sx/2 - 145*px, sy-50*px, 290*px, 15*px, tocolor (255, 255, 255), 1, fonts[2], "center", "center")

	
	--dxCreateText ("Volume: "..math.ceil(volume*100).."%", sx/2 - 170*px, sy-295*px, 340*px, 15*px, tocolor (255, 255, 255), 1, "default-bold", "center", "center")
	--dxDrawScroll (sx/2 - 170*px, sy-275*px, 340*px, 15*px, 20*px, scroll, true)
	

	
	if getKeyState ("mouse1") then
		if isCursorPosition (sx/2 - 145*px, sy-50*px, 290*px, 10*px) or activeVolume then
			local x = getCursorPosition()
			local x = x * sx
			local newX = x - (sx/2 - 145*px) - (10*px)/2
			-- print (newX)
			
			if newX < 0 then
				newX = 0
			end
			
			if newX > 290*px - 10*px then
				newX = 290*px - 10*px
			end
			
			scroll = newX
			
			volume = (scroll + math.lerp(0, 10, scroll/290*px))/290*px
			
			activeVolume = true
			
			triggerServerEvent ("updateVolume", resourceRoot, math.min (1, volume))
		end
	else
		if activeVolume then
			triggerServerEvent ("updateVolume", resourceRoot, math.min (1, volume))
			activeVolume = false
		end
	end
end

function onVolumeOffOn ()
	if volume ~= 0 then
		prevVolume = {volume, scroll}
		scroll = 0
		volume = 0
		triggerServerEvent ("updateVolume", resourceRoot, volume)
	else
		if type(prevVolume) == "table" and prevVolume[1] and prevVolume[1] > 0 then
			volume = prevVolume[1]
			scroll = prevVolume[2]
			triggerServerEvent ("updateVolume", resourceRoot, volume)
		end
	end
end



function toggleRadio ()
	triggerServerEvent ("toggleRadio", resourceRoot)
end

local allVisible = false
bindKey ("F5", "down", function()
	if not allVisible then
		if not localPlayer.vehicle then return end
		if getVehicleOccupant (localPlayer.vehicle) == localPlayer then
			addEventHandler ("onClientRender", root, render)
			showCursor(true)
			showChat(false)
				setElementData(localPlayer, "showHUD", false)
			loadSettings()
		end
	else
		saveSettings()
		
		removeEventHandler ("onClientRender", root, render)
		showCursor(false)
		showChat(true)
				setElementData(localPlayer, "showHUD", true)
		toggleStations (false)
		toggleSearch (false)
		togglePlaylist (false)
	end
	allVisible = not allVisible
end)

sounds = {}

addEvent ("updateVolume", true)
addEventHandler ("updateVolume", resourceRoot, function(veh, v)
	if sounds[veh] then
		sounds[veh].volume = v
		setSoundMaxDistance(sounds[veh].sound, map(v, 0, 100, 20, 50))
		setSoundVolume(sounds[veh].sound, v)
	end
end)

addEvent ("toggleRadio", true)
addEventHandler ("toggleRadio", resourceRoot, function(veh)
	if sounds[veh] then
		if isElement (sounds[veh].sound) then
			destroyElement (sounds[veh].sound)
		end
		sounds[veh] = nil
		collectgarbage()
	end
end)

function updateSounds(veh, station, volume)
	if isElement(veh) and isElementStreamedIn(veh) then
		
		if sounds[veh] then
			if isElement (sounds[veh].sound) then
				destroyElement (sounds[veh].sound)
			end
			sounds[veh] = nil
			collectgarbage()
		end
		
		
		if not station then return end
		
		local sound = playSound3D (station, Vector3 (veh.position))

		attachElements (sound, veh)
		setSoundMaxDistance(sound, map(volume, 0, 100, 20, 50))
		setSoundVolume(sound, volume/100)
		
		
		
		sounds[veh] = {
			station = station,
			volume = volume,
			sound = sound,
		}	
		
	end
end
addEvent ("updateSounds", true)
addEventHandler ("updateSounds", resourceRoot, updateSounds)

addEventHandler ("onClientElementStreamOut", root, function()
	if source.type ~= "vehicle" then return end
	if sounds[source] then
		if isElement (sounds[source].sound) then
			destroyElement (sounds[source].sound)
		end
		sounds[source] = nil
		collectgarbage()
	end
end)

addEventHandler ("onClientElementStreamIn", root, function()
	if source.type ~= "vehicle" then return end
	local t = getElementData (source, "radio:stream")
	if t and type (t) == "table" then
		updateSounds (source, t[1], t[2] or 100)
	end
end)

myRadio = false
searchRadio = false

function onSoundStopped ( reason )
	if reason == "finished" then
		local veh = localPlayer.vehicle
		if sounds[veh] and sounds[veh].sound == source then
			if myRadio then
				playNext()
			end
		end
	end
end
addEventHandler ( "onClientSoundStopped", resourceRoot, onSoundStopped)

function createStation (i)
	triggerServerEvent ("createStation", resourceRoot, stations[i].hq or stations[i].lq, volume*100)
end

function createURL (url)
	triggerServerEvent ("createStation", resourceRoot, url, volume*100, true)
end


local settingsFile = "settings.json"
function loadSettings()
	local data
	if fileExists(settingsFile) then 
		local file = fileOpen(settingsFile, true)
		if (file) then
			data = fromJSON(fileRead(file, fileGetSize(file)))
			fileClose(file)
		end
	end
	if (type(data) ~= "table") then data = {} end
	
	data.volume = tonumber(data.volume) or (scroll + math.lerp(0, 10, scroll/290*px))/290*px
	volume = data.volume
	scroll = data.scroll or (290*px) * 0.3
	
	myLists = data.my or {}
end

local needsSave, saveTimer = false
function saveSettings()
	if isTimer(saveTimer) then
		needsSave = true
	else
		needsSave = true
		writeSettingsFile()
		saveTimer = setTimer(writeSettingsFile, 1000, 1)
	end
end

function writeSettingsFile()
	if (needsSave) then
		local data = {}
		data.volume = volume
		data.scroll = scroll
		data.my = myLists

		local file = fileCreate(settingsFile)
		if (file) then
			fileWrite(file, toJSON(data, true))
			fileClose(file)
		end
		
		needsSave = false
	end
end

function destroy ()
	if source.type ~= "vehicle" then return end
	if not sounds[source] then return end
	if isElement (sounds[source].sound) then
		destroyElement (sounds[source].sound)
	end
	sounds[source] = nil
	collectgarbage()
end
addEventHandler ("onClientElementDestroy", root, destroy)
addEventHandler ("onClientVehicleExplode", root, destroy)