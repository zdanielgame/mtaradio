myLists = {}

local activeScroll = false
local startTick = 0
local selected = nil
local prevMusic

local updateRTPlaylist = function()
	local y = 0

	local many = #myLists*(22*px) > 355*px

	dxSetRenderTarget (RTS.mylist, true)
		for i, v in ipairs (myLists) do
			
			local t = ""
			if utf8.len (v[2]) >= 5 then
				local s, e = utf8.find (v[2], " ", 5)
				t = utf8.sub (v[2], 1, s)
			else
				t = v[2]
			end
			
			dxDrawRow (v[1].." - "..v[2], 0, y - scrolls.mylist.c, 255*px, 20*px, "left", selected == i)
			dxDrawRow ("X", 255*px, y - scrolls.mylist.c, 20*px, 20*px, "center", false)
			
			y = y + 22*px
		end
	dxSetRenderTarget ()
	
	if y > 355*px then
		scrolls.mylist.m = y - 355*px
	end
	
	dxSetRenderTarget (RTS.mylist)
		local size = 355*px * ((355*px)/y)
		local s = (scrolls.mylist.c/scrolls.mylist.m)*(355*px-size)
		if not many then
			y = 355*px
			s = 0
		end
		
		dxDrawScroll (280*px, 0, 10*px, 355*px, size, s)
	dxSetRenderTarget ()
end

local fonts = { -- шриффты
	[1] = dxCreateFont("font/proximanova_semibold.ttf", 10),
	[2] = dxCreateFont("font/proximanova_semibold.ttf", 9),
}

local render = function()
	 dxDrawRectangle(sx/2 - 150*px, sy-670*px, 300*px, 40*px, tocolor(29,32,41,170)) -- Подзаголовок
	 dxDrawRectangle(sx/2 - 150*px, sy-670*px, 300*px, 5*px, tocolor(212,51,57,255)) -- Line  
	 dxCreateText ("Pesquisa de música", sx/2 - 150*px, sy-670*px, 300*px, 40*px, tocolor (255, 255, 255), 1, fonts[1], "center", "center")
	 
     dxDrawRectangle(sx/2 - 150*px, sy-620*px, 300*px, 375*px, tocolor(29,32,41,170)) -- Fon
	
	if #myLists < 1 then
		local a = 255 * getEasingValue ((getTickCount()-startTick)/1000, "SineCurve")
		---dxCreateText ("Não há nada aqui ainda", sx/2 - 500*px, sy - 725*px, 290*px, 470*px, tocolor (255, 255, 255, a), 1, "default-bold", "center", "center")
	else
		--dxDrawImage (sx/2 - 500*px, sy - 725*px, 290*px, 470*px, RTS.mylist)
		dxDrawImage (sx/2 - 145*px, sy - 610*px, 290*px, 355*px, RTS.mylist)
	end
end

function addToMyTrack (t)
	table.insert (myLists, t)
	updateRTPlaylist ()
	saveSettings()
end

local function click(button, state)
	if state ~= "down" then return end
	if button == "left" then
		if isCursorPosition (sx/2 - 145*px, sy - 610*px, 290*px, 355*px) then
			local y = 0
			for i, v in ipairs (myLists) do
				if isCursorPosition (sx/2 - 145*px, sy - 610*px + y - scrolls.mylist.c, 255*px, 20*px) then
					selected = i
					prevMusic = i
					updateRTPlaylist()
					createURL (myLists[selected][3])
					searchRadio = false
					myRadio = true
					break
				elseif isCursorPosition (sx/2 - 145*px + 255*px, sy - 610*px + y - scrolls.mylist.c, 20*px, 20*px) then
					table.remove (myLists, i)
					saveSettings()
					updateRTPlaylist()
					break
				end
				y = y + 22*px
			end
		else
			selected = nil
			updateRTPlaylist()
		end
	end
end

function playNext ()
	if prevMusic + 1 > #myLists then
		prevMusic = 1
	else
		prevMusic = prevMusic + 1
	end
	
	createURL (myLists[prevMusic][3])
end

function isTrackExists (url)
	for i, v in ipairs (myLists) do
		if v[3] == url then
			return true
		end
	end
	return false
end

local function scrollWheels(key)
	if key == "mouse_wheel_up" then
		if isCursorPosition (sx/2 - 145*px, sy - 610*px, 290*px, 355*px) then
			if scrolls.mylist.c - 15 >= 0 then
				scrolls.mylist.c = scrolls.mylist.c - 15
				updateRTPlaylist()
			else
				scrolls.mylist.c = 0
				updateRTPlaylist()
			end
		end
	elseif key == "mouse_wheel_down" then
		if isCursorPosition (sx/2 - 145*px, sy - 610*px, 290*px, 355*px) then
			if scrolls.mylist.c + 15 <= scrolls.mylist.m then 
				scrolls.mylist.c = scrolls.mylist.c + 15
				updateRTPlaylist()
			else
				scrolls.mylist.c = scrolls.mylist.m
				updateRTPlaylist()
			end
		end
	end
	lastY = scrolls.mylist.c
end

local showPlaylist = false
function togglePlaylist (arg)
	if arg ~= nil then
		showPlaylist = not arg
	end
	
	if not showPlaylist then
		startTick = getTickCount()
		updateRTPlaylist ()
		addEventHandler ("onClientRender", root, render)
		addEventHandler ("onClientClick", root, click)
		addEventHandler ("onClientKey", root, scrollWheels)
	else
		removeEventHandler ("onClientRender", root, render)
		removeEventHandler ("onClientClick", root, click)
		removeEventHandler ("onClientKey", root, scrollWheels)
	end
	showPlaylist = not showPlaylist
end