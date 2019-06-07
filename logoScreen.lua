local logoScreen = {}

logoScreen.name = "logoScreen"

local logo, logoY

function logoScreen.load()
	logo = love.graphics.newImage("logo.png")
	ai = true
end

function logoScreen.update(dt) end

function logoScreen.draw()
	love.graphics.draw(logo, centerX-logo:getWidth()/2, logoY)
    buttonsManager.draw()
end

function logoScreen.mousepressed(x, y, button, istouch)
    buttonsManager:callback(x, y)
end

function logoScreen.keypressed(key) 
	if key == "escape" then love.event.quit() end
end

function logoScreen.setUI()
	logoY = centerY-logo:getHeight()/4*3
	buttonsManager:new(centerX-100, logoY+logo:getHeight()+10, 200, 100, "PLAY",
        function() changeToScreen = "menuScreen" end)
	buttonsManager:new(centerX-100, logoY+logo:getHeight()+125, 200, 60, "INFO",
        function() changeToScreen = "infoScreen" end)
end

return logoScreen 