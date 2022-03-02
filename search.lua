local stokText = "Digite o título:"
local text = "Digite o título:"
local enableInput = false

local selected = nil

local activeScroll = false

local musics = {}

local updateRTSearch = function()
	local y = 0
	dxSetRenderTarget (RTS.search, true)
		for i, v in ipairs (musics) do
			local t = ""
			
			if utf8.len (v[2]) > 10 then
				local s, e = utf8.find (v[2], " ", 10)
				t = utf8.sub (v[2], 1, s)
			else
				t = v[2]
			end
			
			if isTrackExists (v[3]) then
			-- if false then
				dxDrawRow (v[1].." - "..t, 0, y - scrolls.search.c, 265*px, 20*px, "left", selected == i)
			else
				dxDrawRow2 ("❤", 265*px, y - scrolls.search.c, 20*px, 20*px, "center", false)
				dxDrawRow (v[1].." - "..t, 0, y - scrolls.search.c, 265*px, 20*px, "left", selected == i)
			end
			-- dxDrawButton ("✓", 355, y - scrolls.search.c, 20*px, 20*px, "addTrack", {v[1].." - "..t, v[3]}, true)
			
			y = y + 22*px
		end
	dxSetRenderTarget ()
	
	if y > 280*px then
		scrolls.search.m = y - 280*px
		
		dxSetRenderTarget (RTS.search)
			local size = 280*px * ((280*px)/y)
			dxDrawScroll (380*px, 0, 10*px, 280*px, size, (scrolls.search.c/scrolls.search.m)*(280*px-size))
		dxSetRenderTarget ()
	end
end

local fonts = { -- шриффты
	[1] = dxCreateFont("font/proximanova_semibold.ttf", 10),
	[2] = dxCreateFont("font/proximanova_semibold.ttf", 9),
}


local render = function()
	
	dxDrawRectangle(sx/2 - 150*px, sy-670*px, 300*px, 40*px, tocolor(29,32,41,170)) -- Подзаголовок
	 dxDrawRectangle(sx/2 - 150*px, sy-670*px, 300*px, 5*px, tocolor(212,51,57,255)) -- Line  
	 dxCreateText ("Pesquisa de música", sx/2 - 150*px, sy-670*px, 300*px, 40*px, tocolor (255, 255, 255), 1, fonts[1], "center", "center")
	 
     dxDrawRectangle(sx/2 - 150*px, sy-620*px, 300*px, 365*px, tocolor(29,32,41,170)) -- Fon
	 
	 local text = dxDrawEdit (sx/2 - 145*px, sy-610*px, 290*px, 25*px, "search", stokText)
	 dxDrawButton ("Procurar", sx/2 - 145*px, sy-580*px, 290*px, 25*px, "searchTrack", text)
	
	dxDrawImage (sx/2 - 145*px, sy-545*px, 290*px, 280*px, RTS.search)
end

function searchTrack (text)
	triggerServerEvent ("searchTrack", resourceRoot, text)
end

function callbackSearch (t)
	musics = t
	updateRTSearch ()
end
addEvent ("okSearch", true)
addEventHandler ("okSearch", resourceRoot, callbackSearch)

local function click(button, state)
	if state ~= "down" then return end
	if button == "left" then
		if isCursorPosition (sx/2 - 145*px, sy-545*px, 275*px, 280*px) then
			local y = 0
			for i, v in ipairs (musics) do
				if isCursorPosition (sx/2 - 145*px, sy-545*px + y - scrolls.search.c, 265*px, 20*px) then
					selected = i
					updateRTSearch()
					createURL (musics[selected][3])
					searchRadio = true
					myRadio = false
					break
				elseif isCursorPosition (sx/2 - 145*px + 265*px, sy-545*px + y - scrolls.search.c, 20*px, 20*px) then
					local t = ""
			
					if utf8.len (v[2]) > 10 then
						local s, e = utf8.find (v[2], " ", 10)
						t = utf8.sub (v[2], 1, s)
					else
						t = v[2]
					end
					
					addToMyTrack ({v[1], t, v[3]})
					updateRTSearch()
					break
				end
				y = y + 22*px
			end
		else
			selected = nil
			updateRTSearch()
		end
	end
end

local function scrollWheels(key)
	if key == "mouse_wheel_up" then
		if isCursorPosition (sx/2 - 145*px, sy-545*px, 290*px, 280*px) then
			if scrolls.search.c - 15 >= 0 then
				scrolls.search.c = scrolls.search.c - 15
				updateRTSearch()
			else
				scrolls.search.c = 0
				updateRTSearch()
			end
			lastY = scrolls.search.c
		end
	elseif key == "mouse_wheel_down" then
		if isCursorPosition (sx/2 - 145*px, sy-545*px, 290*px, 280*px) then
			if scrolls.search.c + 15 <= scrolls.search.m then 
				scrolls.search.c = scrolls.search.c + 15
				updateRTSearch()
			else
				scrolls.search.c = scrolls.search.m
				updateRTSearch()
			end
			lastY = scrolls.search.c
		end
	elseif key == "enter" then
		local text = dxDrawEdit (sx/2 - 145*px, sy-610*px, 290*px, 25*px, "search", stokText)
		triggerServerEvent ("searchTrack", resourceRoot, text)
	end
end

local showSearch = false
function toggleSearch (arg)
	if arg ~= nil then
		showSearch = not arg
	end
	
	if not showSearch then
		addEventHandler ("onClientRender", root, render)
		addEventHandler ("onClientClick", root, click)
		addEventHandler ("onClientKey", root, scrollWheels)
	else
		removeEventHandler ("onClientRender", root, render)
		removeEventHandler ("onClientClick", root, click)
		removeEventHandler ("onClientKey", root, scrollWheels)
	end
	showSearch = not showSearch
end