local blackboard = {}

border_functions = require 'border_functions'
screenshake = require 'screenshake'
buttonsManager = require 'button'

song = love.audio.newSource("sfx/song.ogg", "stream")
muted = false

changeToScreen = nil
paused = false
timer = 0
scoreGoal = 5
ai = true
winner = nil

halfFontHeight = love.graphics.getFont():getHeight()/2

stageW, stageH = 400, 300

function blackboard.resize()
	windowW, windowH = love.graphics.getDimensions()
	centerX = windowW/2
	centerY = windowH/2
	visualOffsetX, visualOffsetY = centerX-stageW/2, centerY-stageH/2
end

blackboard.resize()

android = love.system.getOS() == "Android"
if android then
	android_buttons_offset = 20
	android_buttons_w, android_buttons_h = 120, (windowH-android_buttons_offset*3)/2
end

return blackboard 