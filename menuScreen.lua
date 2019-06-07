local menuScreen = {}

menuScreen.name = "menuScreen"

local upKey, downKey = false, false
local clickAreaJoin = {}

function menuScreen.load()
	setMusicVolume(0.1)
    screenshake.reset()
    screenshake.setup(1, 0.1, 2)
end

function menuScreen.update(dt) 
	border_functions.updateGraphs()
end

local function drawRandomOption(y)
	local w = 120
	love.graphics.line(visualOffsetX, visualOffsetY+y, visualOffsetX+stageW/4, visualOffsetY+y)
	love.graphics.line(visualOffsetX+stageW/4*3, visualOffsetY+y, visualOffsetX+stageW, visualOffsetY+y)
	love.graphics.printf("RANDOM", visualOffsetX+stageW/2-w/2, visualOffsetY+y-halfFontHeight, w, "center")
end

function menuScreen.draw()

	-- score
	love.graphics.setColor(128, 128, 128)
	love.graphics.printf("POINTS TO WIN", centerX-100, visualOffsetY-70, 200, "center")
	love.graphics.setColor(255, 255, 255)
    love.graphics.printf(scoreGoal, centerX-50, visualOffsetY-45, 100, "center")

    love.graphics.setColor(128, 128, 128)
    local leftTop, leftBottom, rightTop, rightBottom
    if border_functions.top == 0 then leftTop, rightTop = 0, 0 else leftTop, rightTop = top_border(0), top_border(stageW) end
    if border_functions.bottom == 0 then leftBottom, rightBottom = stageH, stageH else leftBottom, rightBottom = bottom_border(0), bottom_border(stageW) end
    love.graphics.line(visualOffsetX, visualOffsetY+leftTop, visualOffsetX, visualOffsetY+leftBottom)
    love.graphics.line(visualOffsetX+stageW, visualOffsetY+rightTop, visualOffsetX+stageW, visualOffsetY+rightBottom)

    love.graphics.setColor(255, 255, 255)
	
	local padSize = 50
	love.graphics.line(visualOffsetX, visualOffsetY+stageH/2-padSize, visualOffsetX, visualOffsetY+stageH/2+padSize)
	love.graphics.line(visualOffsetX+stageW, visualOffsetY+stageH/2-padSize, visualOffsetX+stageW, visualOffsetY+stageH/2+padSize)
	
	if border_functions.top ~= 0 then love.graphics.line(border_functions.topGraph)
    else drawRandomOption(0) end
    if border_functions.bottom ~= 0 then love.graphics.line(border_functions.bottomGraph)
    else drawRandomOption(stageH) end
	
	love.graphics.print("PLAYER 1", visualOffsetX-100, visualOffsetY+stageH/2-halfFontHeight)
	if ai then 
		love.graphics.print("AI", visualOffsetX+stageW+40, visualOffsetY+stageH/2-halfFontHeight)
		love.graphics.setColor(128, 128, 128)
		love.graphics.printf(clickAreaJoin.text, clickAreaJoin.x, clickAreaJoin.y+30, clickAreaJoin.w, "center")
		if android then love.graphics.rectangle("line", clickAreaJoin.x, clickAreaJoin.y, clickAreaJoin.w, clickAreaJoin.h) end
		love.graphics.setColor(255, 255, 255)
	else love.graphics.print("PLAYER 2", visualOffsetX+stageW+30, visualOffsetY+stageH/2-halfFontHeight) end
	
    buttonsManager:draw()
end

function menuScreen.mousepressed(x, y, button, istouch)
    buttonsManager:callback(x, y)
	clickAreaJoin.callback(x, y)
end

function menuScreen.keypressed(key)
	-- join player 2
	if key == "up" then upKey = true
	elseif key == "down" then downKey = true end
	if upKey and downKey then ai = false end
	
	if key == "r" then 
		border_functions.top, border_functions.bottom = 0, 0
	end
	
	if key == "escape" then changeToScreen = "logoScreen"
	elseif key == "return" then changeToScreen = "gameScreen" end
end

function menuScreen.setUI()
	-- goal selection
	local w, h, offset, offsetY = 40, 25, 28, 50
	buttonsManager:new(visualOffsetX+stageW/2-w-offset, visualOffsetY-offsetY, w, h, "-",
        function() scoreGoal = scoreGoal-1 if scoreGoal < 1 then scoreGoal = 1 end screenshake.shake(1) end)
	buttonsManager:new(visualOffsetX+stageW/2+offset, visualOffsetY-offsetY, w, h, "+",
        function() scoreGoal = scoreGoal+1 screenshake.shake(1) end)
		
	-- border type selection
	w, h, offset = 50, 25, 10
    buttonsManager:new(visualOffsetX+stageW+offset, visualOffsetY, w, h, ">",
        function() border_functions.top = border_functions.top+1 if border_functions.top > #border_functions.funcs then border_functions.top = 0 end screenshake.shake(1) end)
    buttonsManager:new(visualOffsetX-w-offset, visualOffsetY, w, h, "<",
        function() border_functions.top = border_functions.top-1 if border_functions.top < 0 then border_functions.top = #border_functions.funcs end screenshake.shake(1) end)
	buttonsManager:new(visualOffsetX+stageW+offset, visualOffsetY+stageH-h, w, h, ">",
        function() border_functions.bottom = border_functions.bottom+1 if border_functions.bottom > #border_functions.funcs then border_functions.bottom = 0 end screenshake.shake(1) end)
	buttonsManager:new(visualOffsetX-w-offset, visualOffsetY+stageH-h, w, h, "<",
        function() border_functions.bottom = border_functions.bottom-1 if border_functions.bottom < 0 then border_functions.bottom = #border_functions.funcs end screenshake.shake(1) end)
    
	-- start game
	w, h = 200, 80
	buttonsManager:new(visualOffsetX+stageW/2-w/2, visualOffsetY+stageH/2-h/2, w, h, "START GAME",
        function() changeToScreen = "gameScreen" end)
		
	-- click area join
	clickAreaJoin.x = visualOffsetX+stageW+90
	clickAreaJoin.y = visualOffsetY+stageH/2-45
	clickAreaJoin.w = 160
	clickAreaJoin.h = 100
	clickAreaJoin.text = "PLAYER 2:\npress the up and down arrow keys to join"
	if android then clickAreaJoin.text = "PLAYER 2:\ntouch me to join" end
	clickAreaJoin.callback = function(x, y)
		if x > clickAreaJoin.x and x < clickAreaJoin.x+clickAreaJoin.w 
		and y > clickAreaJoin.y and y < clickAreaJoin.y+clickAreaJoin.h then
			ai = false
			upKey, downKey = true, true
		end
	end
end

return menuScreen 