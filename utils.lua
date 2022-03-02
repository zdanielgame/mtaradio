sx, sy = guiGetScreenSize()
-- px = sx/1920
px = 1

colors = {
	window = {
		-- top = tocolor(255, 200, 0, 180),
		top = tocolor(30, 129, 144, 180),
		main = tocolor(0, 0, 0, 150),
		text = tocolor (255, 255, 255),
		font = "default-bold",
	},
	scroll = {
		main = tocolor(48,53,73, 255),
		scroll = tocolor(212,51,57, 255),
	},
	row = {
		main = tocolor(48,53,73, 255),
		selected = tocolor(212,51,57, 255),
	},
	button = {
		off = tocolor(48,53,73, 255),
		hover = tocolor(212,51,57, 255),
		click = tocolor(212,51,57, 255),
		invisible = tocolor(0, 0, 0, 150),
	},
	edit = {
		main = tocolor(48,53,73, 255),
	},
}

clickMouse = {}

function dxDrawWindow (x, y, w, h, text)
	dxDrawRectangle (x, y, w, h, colors.window.main)
	dxDrawRectangle (x, y, w, 20*px, colors.window.top)
	
	dxCreateText (text, x - 1*px, y, w, 20*px, tocolor(0, 0, 0), 1*px, colors.window.font, "center", "center")
	dxCreateText (text, x + 1*px, y, w, 20*px, tocolor(0, 0, 0), 1*px, colors.window.font, "center", "center")
	dxCreateText (text, x, y - 1*px, w, 20*px, tocolor(0, 0, 0), 1*px, colors.window.font, "center", "center")
	dxCreateText (text, x, y + 1*px, w, 20*px, tocolor(0, 0, 0), 1*px, colors.window.font, "center", "center")
	
	dxCreateText (text, x, y, w, 20*px, colors.window.text, 1*px, colors.window.font, "center", "center")
end

function dxDrawScroll (x, y, w, h, size, s, hor)
	dxDrawRectangle (x, y, w, h, colors.scroll.main)
	if not hor then
		dxDrawRectangle (x, y + (s or 0), w, size or h, colors.scroll.scroll or 0)
	else
		dxDrawRectangle (x + (s or 0), y, size or w, h, colors.scroll.scroll or 0)
	end
end

function dxDrawRow (text, x, y, w, h, left, select)
	dxDrawRectangle (x, y, w, h, select and colors.row.selected or colors.row.main)
	dxCreateText (text, x + 5*px, y, w-10*px, h, tocolor(255, 255, 255), 1*px, "default-bold", left, "center")
end

function dxDrawRow2 (text, x, y, w, h, left, select)
	dxDrawRectangle (x, y, w, h, select and colors.row.selected or colors.row.main)
	dxCreateText (text, x + 5*px, y - 8*px, w-10*px, h, tocolor(255, 255, 255), 1*px, "default-bold", left, "center")
end

function dxDrawButton (text, x, y, w, h, funcA, arg, invisible)
	local func = ""
	local secondFunc = nil

	if type (funcA) == "table" then
		func = funcA[1]
		secondFunc = funcA[2]
	else
		func = funcA
	end
	
	if not clickMouse[func] then
		clickMouse[func] = 0
	end
	
	-- local a1, b2 = dxGetTextSize(text, w, 1, 1, "default-bold", true)
	
	-- if h < b2 then
		-- h = b2
	-- end
	
	if isCursorPosition (x, y, w, h) then
		dxDrawRectangle (x, y, w, h, not invisible and colors.button.hover or colors.button.invisible)
		
		if getKeyState ("mouse1") and clickMouse[func] == 0 then
			_G[func](arg)
			if secondFunc then
				_G[secondFunc](arg)
			end
		elseif getKeyState ("mouse1") and clickMouse[func] == 1 then
			dxDrawRectangle (x, y, w, h, not invisible and colors.button.click or colors.button.invisible)
		end
	else
		dxDrawRectangle (x, y, w, h, not invisible and colors.button.off or colors.button.invisible)
	end
	dxCreateText (text, x, y, w, h, tocolor(255, 255, 255), 1, "default-bold", "center", "center")
	
	if getKeyState ("mouse1") then clickMouse[func] = 1 else clickMouse[func] = 0 end
end

function dxCreateText (text, x, y, w, h, color, size, font, left, top)
	dxDrawText (text, x, y, x + w, y + h, color, size, font, left, top, false, true)
end

local edits = {}
function dxDrawEdit(x, y, w, h, type, stokText)
    if not edits[type] then
		edits[type] = {}
		edits[type].state = false
		edits[type].text = stokText
		edits[type].stok = stokText
	end
	
	if getKeyState ("mouse1") and clickMouse[type] == 0 then
		if isCursorPosition (x, y, w, h) then 
			edits[type].state = true
			guiSetInputMode ("no_binds")
			if edits[type].text == stokText then
				edits[type].text = ""
			end
		else
			edits[type].state = false
			guiSetInputMode ("allow_binds")
			if utf8.len(edits[type].text) == 0 or utf8.gsub (edits[type].text, " ", "") == "" then
				edits[type].text = stokText
			end
		end
	end
	
	dxDrawRectangle (x, y, w, h, colors.edit.main)
	
	dxCreateText (edits[type].text, x + 5*px, y, w-10*px, h, tocolor (255, 255, 255), 1, "default-bold", "center", "center")
	
	if edits[type].state then
		local wT = dxGetTextWidth (edits[type].text, 1, "default-bold")
		if (math.floor(getTickCount()/500))%2 == 0 then
			--dxDrawRectangle (x + 5*px + wT, y+4*px, 2*px, h-8*px, tocolor (0, 0, 0))
		end
	end
	
	if getKeyState ("mouse1") then clickMouse[type] = 1 else clickMouse[type] = 0 end
	
	return edits[type].text
end

addEventHandler ("onClientCharacter", root, function(char)
	local t = getActiveEdit()
	if not t then return end
	
	edits[t].text = edits[t].text..char
end)

addEventHandler ("onClientPaste", root, function(char)
	local t = getActiveEdit()
	if not t then return end
	
	edits[t].text = edits[t].text..char
end)

addEventHandler ("onClientKey", root, function(key, state)
	if not state then return end
	local t = getActiveEdit()
	if not t then return end
	
	if key == "backspace" then
		edits[t].text = utf8.sub (edits[t].text, 1, utf8.len(edits[t].text) - 1)
	elseif key == "escape" then
		cancelEvent ()
		edits[t].state = false
		if utf8.len(edits[t].text) == 0 or utf8.gsub (edits[t].text, " ", "") == "" then
			edits[t].text = edits[t].stok
		end
	end
end)

function getActiveEdit ()
	local type = nil
	
	for t, v in pairs (edits) do
		if v.state == true then
			type = t
			break
		end
	end
	
	return type
end



function isCursorPosition (x, y, w, h)
	if not isCursorShowing() then return end
	local curx, cury = getCursorPosition()
	local curx, cury = curx*sx, cury*sy
	return curx > x and cury > y and curx < x + w and cury < y + h
end

function math.lerp(a, b, k)
	local result = a * (1-k) + b * k
	if result >= b then
		result = b
	elseif result <= a then
		result = a
	end
	return result
end

function map(value, fromLow, fromHigh, toLow, toHigh)
	return (value-fromLow) * (toHigh-toLow) / (fromHigh-fromLow) + toLow
end

function wordWrap(text, maxwidth, scale, font, colorcoded)
    local lines = {}
    local words = split(text, " ") -- this unfortunately will collapse 2+ spaces in a row into a single space
    local line = 1 -- begin with 1st line
    local word = 1 -- begin on 1st word
    local endlinecolor
    while (words[word]) do -- while there are still words to read
        repeat
            if colorcoded and (not lines[line]) and endlinecolor and (not string.find(words[word], "^#%x%x%x%x%x%x")) then -- if on a new line, and endline color is set and the upcoming word isn't beginning with a colorcode
                lines[line] = endlinecolor -- define this line as beginning with the color code
            end
            lines[line] = lines[line] or "" -- define the line if it doesnt exist

            if colorcoded then
                local rw = string.reverse(words[word]) -- reverse the string
                local x, y = string.find(rw, "%x%x%x%x%x%x#") -- and search for the first (last) occurance of a color code
                if x and y then
                    endlinecolor = string.reverse(string.sub(rw, x, y)) -- stores it for the beginning of the next line
                end
            end
      
            lines[line] = lines[line]..words[word] -- append a new word to the this line
            lines[line] = lines[line] .. " " -- append space to the line

            word = word + 1 -- moves onto the next word (in preparation for checking whether to start a new line (that is, if next word won't fit)
        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font, colorcoded) > maxwidth) -- jumps back to 'repeat' as soon as the code is out of words, or with a new word, it would overflow the maxwidth
    
        lines[line] = string.sub(lines[line], 1, -2) -- removes the final space from this line
        if colorcoded then
            lines[line] = string.gsub(lines[line], "#%x%x%x%x%x%x$", "") -- removes trailing colorcodes
        end
        line = line + 1 -- moves onto the next line
    end -- jumps back to 'while' the a next word exists
    return lines
end