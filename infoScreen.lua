local infoScreen = {}

infoScreen.name = "infoScreen"

local text

function infoScreen.load() 
	text = "Game created in 72 hours for Ludum Dare 37" ..
			"\n\n\nmygameisabadjoke.itch.io \nall rights reserved" ..
			"\n\n\nThis game is programmed in LUA using LÖVE (Love2D)\nThe sound effects were made with sfxr and Audacity\n" ..
			"The music was procedurally generated in Abundant Music" ..
			"\n\n\n TIPS: \n" ..
			"press [F] for fullscreen\n" ..
			"press [R] ingame if the ball is stuck to reset it\n" ..
			"press [R] in the menu to quickly set random options\n" ..
			"press [M] to mute/unmute the music\n" ..
			"press [ESC] to go back to previous screens or pause the game\n"
end

function infoScreen.update(dt) end

function infoScreen.draw()
	love.graphics.setColor(240, 240, 240)
	love.graphics.printf(text, centerX-205, centerY-15*halfFontHeight, 400, "center")
end

function infoScreen.mousepressed(x, y, button, istouch)
    buttonsManager:callback(x, y)
end

function infoScreen.keypressed(key) 
	if key == "escape" then changeToScreen = "logoScreen" end
end

function infoScreen.setUI() end

return infoScreen 