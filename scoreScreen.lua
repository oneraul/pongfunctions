local scoreScreen = {}

scoreScreen.name = "scoreScreen"

function scoreScreen.load() 
	setMusicVolume(0.1)
end

function scoreScreen.update(dt) end

function scoreScreen.draw() 
    buttonsManager:draw()
	love.graphics.printf(winner.." wins!", centerX-200, centerY-50, 400, "center")
end

function scoreScreen.mousepressed(x, y, button, istouch) 
    buttonsManager:callback(x, y)
end

function scoreScreen.keypressed(key) 
	if key == "escape" or key == "return" then changeToScreen = "menuScreen" end
end

function scoreScreen.setUI()
	buttonsManager:new(centerX-50, centerY, 100, 40, "SALIR",
        function() changeToScreen = "menuScreen" end)
end

return scoreScreen 