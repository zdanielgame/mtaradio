local selected = nil
local activeScroll = false

local updateRTRadio = function()
	local y = 0
	dxSetRenderTarget (RTS.radio, true)
		for i, v in ipairs (stations) do
			dxDrawRow (v.name, 0, y - scrolls.radio.c, 275*px, 20*px, "center", selected == i)
			y = y + 22*px
		end
	dxSetRenderTarget ()
	
	if y > 290*px then
		scrolls.radio.m = y - 290*px
	end
	
	dxSetRenderTarget (RTS.radio)
		local size = 290*px * ((290*px)/y)
		dxDrawScroll (280*px, 0, 10*px, 290*px, size, (scrolls.radio.c/scrolls.radio.m)*(290*px-size))
	dxSetRenderTarget ()
end

local fonts = { -- шриффты
	[1] = dxCreateFont("font/proximanova_semibold.ttf", 10),
	[2] = dxCreateFont("font/proximanova_semibold.ttf", 9),
}

local lastX = 0
local render = function()

	 dxDrawRectangle(sx/2 - 150*px, sy-600*px, 300*px, 40*px, tocolor(29,32,41,170)) -- Подзаголовок
	 dxDrawRectangle(sx/2 - 150*px, sy-600*px, 300*px, 5*px, tocolor(212,51,57,255)) -- Line  
	 dxCreateText ("Estações de radio", sx/2 - 150*px, sy-600*px, 300*px, 40*px, tocolor (255, 255, 255), 1, fonts[1], "center", "center")
	 
     dxDrawRectangle(sx/2 - 150*px, sy-550*px, 300*px, 300*px, tocolor(29,32,41,170)) -- Fon



	--dxDrawWindow (sx/2 + 205*px, sy - 750*px, 300*px, 500*px, "Радио станции")
	
	--dxDrawImage (sx/2 + 210*px, sy - 725*px, 290*px, 470*px, RTS.radio)
	
	dxDrawImage (sx/2 - 145*px, sy - 545*px, 290*px, 290*px, RTS.radio)
end

local function click(button, state)
	if state ~= "down" then return end
	if button == "left" then
		if isCursorPosition (sx/2 - 145*px, sy - 545*px, 275*px, 290*px) then
			local y = 0
			for i, v in ipairs (stations) do
				if isCursorPosition (sx/2 - 145*px, sy - 545*px + y - scrolls.radio.c, 275*px, 20*px) then
					selected = i
					updateRTRadio()
					createStation (selected)
					searchRadio = false
					myRadio = false
					break
				end
				y = y + 22*px
			end
		else
			selected = nil
			updateRTRadio()
		end
	end
end

local function scrollWheels(key)
	if key == "mouse_wheel_up" then
		if isCursorPosition (sx/2 - 145*px, sy - 545*px, 290*px, 290*px) then
			if scrolls.radio.c - 15 >= 0 then
				scrolls.radio.c = scrolls.radio.c - 15
				updateRTRadio()
			else
				scrolls.radio.c = 0
				updateRTRadio()
			end
		end
	elseif key == "mouse_wheel_down" then
		if isCursorPosition (sx/2 - 145*px, sy - 545*px, 290*px, 290*px) then
			if scrolls.radio.c + 15 <= scrolls.radio.m then 
				scrolls.radio.c = scrolls.radio.c + 15
				updateRTRadio()
			else
				scrolls.radio.c = scrolls.radio.m
				updateRTRadio()
			end
		end
	end
	lastY = scrolls.radio.c
end

local showStations = false
function toggleStations (arg)
	if arg ~= nil then
		showStations = not arg
	end
	
	if not showStations then
		addEventHandler ("onClientRender", root, render)
		addEventHandler ("onClientClick", root, click)
		addEventHandler ("onClientKey", root, scrollWheels)
		updateRTRadio ()
	else
		removeEventHandler ("onClientRender", root, render)
		removeEventHandler ("onClientClick", root, click)
		removeEventHandler ("onClientKey", root, scrollWheels)
	end
	showStations = not showStations
end