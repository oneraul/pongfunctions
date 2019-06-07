local buttonsManager = {}

local buttons = {}
local sfx = love.audio.newSource("sfx/button.ogg", "static")

function buttonsManager:clear() buttons = {} end

function buttonsManager:new(x, y, w, h, text, callback)
    local newButton = {}
    newButton.x = x --left
    newButton.y = y --top
    newButton.w = w
    newButton.h = h
    newButton.text = text
    newButton.callback = callback
	newButton.mouseOver = false
    table.insert(buttons, newButton)
end

function buttonsManager:update()
	local x, y = love.mouse.getPosition()

	for k, v in ipairs(buttons) do
        v.mouseOver = (x > v.x and x < v.x+v.w and y > v.y and y < v.y+v.h)
    end
end

function buttonsManager:draw()
    for k, v in ipairs(buttons) do
		if v.mouseOver then love.graphics.setColor(255, 255, 255)
		else love.graphics.setColor(180, 180, 180) end
		
        love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
        love.graphics.printf(v.text, v.x, v.y+v.h/2-halfFontHeight, v.w, "center")
    end
	love.graphics.setColor(255, 255, 255)
end

function buttonsManager:callback(x, y)
	sfx:play()
    for k, v in ipairs(buttons) do
        if x > v.x and x < v.x+v.w and y > v.y and y < v.y+v.h then
            v.callback()
            break
        end
    end
end

return buttonsManager 