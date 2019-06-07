local gameScreen = {}

gameScreen.name = "gameScreen"

local ballX, ballY, ballV, ballAngle, countdown, trail, ballRadius
local leftPadY, rightPadY, leftPadSize, rightPadSize
local padV, ballInitialV, ballMaxV = 500, 450, 600
local scoreLeft, scoreRight, scoreY
local hitSound, hit2Sound, failSound, exploSound
local timeSinceLastPaddleHit

local MAX_TIME_WITHOUT_TOUCHING_THE_BALL = 30

local function clamp(value, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, value))
end
local function dot(a, b) return a.x*b.x+a.y*b.y end
local function cross(a, b) return a.x*b.y-a.y*b.x end

local function newAngle(ballCos, ballSin, surfaceVectorX, surfaceVectorY)
	local normalVec = {x = surfaceVectorY, y = -surfaceVectorX}
	local ballVec = {x = -ballCos, y = -ballSin}
	local difference = math.atan2(cross(normalVec, ballVec), dot(normalVec, ballVec))
	return math.atan2(normalVec.y, normalVec.x) - difference
end

local function reset() 
	ballX, ballY, ballAngle = stageW/2, stageH/2, 0
	ballV = 0
	countdown = 1.6
	timer = 0
	trail = {}
	exploSound:stop()
	exploSound:play()
end

function gameScreen.load()
	love.mouse.setVisible(false)
	
	screenshake.reset()
	screenshake.setup(1, 0.15, 8)  -- paddle
	screenshake.setup(2, 0.15, 5)  -- walls
	screenshake.setup(3, 0.30, 15) -- score

	hitSound = love.audio.newSource("sfx/hit.ogg", "static")
	hit2Sound = love.audio.newSource("sfx/hit2.ogg", "static")
	failSound = love.audio.newSource("sfx/score.ogg", "static")
	exploSound = love.audio.newSource("sfx/bang.ogg", "static")
	setMusicVolume(0.7)

	if border_functions.top == 0 then border_functions.top = math.random(#border_functions.funcs) end
	if border_functions.bottom == 0 then border_functions.bottom = math.random(#border_functions.funcs) end

	ballRadius = 5
	leftPadY, rightPadY = stageH/2, stageH/2
	leftPadSize, rightPadSize = 50, 50 --size on each side
	scoreLeft, scoreRight = 0, 0
	
	border_functions.setTop_max()
	reset()
end

function gameScreen.update(dt)
	if not paused then
	
		if countdown > 0 then
			countdown = countdown-dt
			if countdown <= 0 then
				ballAngle = math.random()*math.pi*2
				ballV = ballInitialV
				timeSinceLastPaddleHit = 0
			end
		else
			timeSinceLastPaddleHit = timeSinceLastPaddleHit+dt
			if timeSinceLastPaddleHit > MAX_TIME_WITHOUT_TOUCHING_THE_BALL then reset() end
		end
		
		-- input
		if not android then 
			-- player1 input
			if love.keyboard.isScancodeDown('w') then leftPadY = leftPadY-padV*dt end
			if love.keyboard.isScancodeDown('s') then leftPadY = leftPadY+padV*dt end
			if not ai then 
				if love.keyboard.isScancodeDown('up') then rightPadY = rightPadY-padV*dt end
				if love.keyboard.isScancodeDown('down') then rightPadY = rightPadY+padV*dt end
			end
		else
			-- android input
			local touches = love.touch.getTouches()
			for i, id in ipairs(touches) do
				local x, y = love.touch.getPosition(id)
				for k, v in ipairs(android_buttons) do
					if x > v.x and x < v.x+android_buttons_w and y > v.y and y < v.y+android_buttons_h then
						v.callback(dt)
					end
				end
			end
		end
		
		-- ai input
		if ai then
			if ballY < rightPadY-rightPadSize*0.7 then 
				local dst = math.min(padV*dt*0.8, rightPadY-ballY)
				rightPadY = rightPadY-dst
			elseif ballY > rightPadY+rightPadSize*0.7 then 
				local dst = math.min(padV*dt*0.8, ballY-rightPadY)
				rightPadY = rightPadY+dst
			end
		end

		leftPadY = clamp(leftPadY, top_border(0), bottom_border(0))
		rightPadY = clamp(rightPadY, top_border(stageW), bottom_border(stageW))

		-- update ball's position
		local sinus = math.sin(ballAngle)
		local cosinus = math.cos(ballAngle)
		ballX = ballX + cosinus*ballV*dt
		ballY = ballY + sinus*ballV*dt
		
		-- ball against the walls
		if ballY >= bottom_border(ballX) then
			-- raymarch back into correct position
			for step = 1, 30 do
				local tmpX, tmpY = ballX-step*cosinus, ballY-step*sinus
				if tmpY < bottom_border(tmpX) then
					ballX, ballY = tmpX, tmpY
					break
				end
			end
	
			-- double check after raymarch
			if ballY > bottom_border(ballX) then
				ballY = bottom_border(ballX) end
			
			-- set reflection angle
			local borderVectorY = bottom_border(ballX+1)-bottom_border(ballX-1)
			ballAngle = newAngle(cosinus, sinus, 2, borderVectorY)
			
			-- fx
			screenshake.shake(2)
			hit2Sound:setPitch(1+math.random()-0.5)
			hit2Sound:play()
			
		elseif ballY <= top_border(ballX) then
			-- raymarch back into correct position
			for step = 1, 30 do
				local tmpX, tmpY = ballX-step*cosinus, ballY-step*sinus
				if tmpY > top_border(tmpX) then
					ballX, ballY = tmpX, tmpY
					break
				end
			end
			
			-- double check after raymarch
			if ballY < top_border(ballX) then
				ballY = top_border(ballX) end
			
			-- set reflection angle
			local borderVectorY = top_border(ballX+1)-top_border(ballX-1)
			ballAngle = newAngle(cosinus, sinus, 2, borderVectorY)
			cosinus, sinus = math.cos(ballAngle), math.sin(ballAngle)
			
			-- fx
			screenshake.shake(2)
			hit2Sound:setPitch(1+math.random()-0.5)
			hit2Sound:play()
		end
		
		-- ball against the paddles
		-- check if ball is beyond the limits
		if ballX >= stageW or ballX <= 0 then
			local padSide = nil
			if cosinus > 0 then padSide = "right"
			elseif cosinus < 0 then padSide = "left" end

			if padSide ~= nil then 
				local limit, pad, padSize, padNormalX = nil, nil, nil, nil
				if padSide == "right" then limit, pad, padSize, padNormalX = stageW, rightPadY, rightPadSize, -1
				else limit, pad, padSize, padNormalX = 0, leftPadY, leftPadSize, 1 end
				
				-- raytrace ball's trajectory
				local x1, y1 = ballX, ballY
				local x2, y2 = ballX-cosinus*ballV*dt, ballY-sinus*ballV*dt
				local m = (y2-y1)/(x2-x1)
				local ballYatLimit = m*(limit-x1)+y1 -- the ballY at the limit x
				
				-- blocked
				if ballYatLimit > pad-padSize-ballRadius*1.5 and ballYatLimit < pad+padSize+ballRadius*1.5 then
					timeSinceLastPaddleHit = 0
					ballX = limit+padNormalX
					
					-- an angle offset depending on where the ball hits the pad
					local hitAlpha = padNormalX * (ballY-pad)/(padSize*2) * math.pi/2
					ballAngle = newAngle(cosinus, sinus, 0, padNormalX) + hitAlpha
					
					-- set angle in range [0, math.pi*2)
					if ballAngle < 0 then ballAngle = ballAngle+math.pi*2 end
					
					-- correct the angle if the ball is sent backwards (due to the hitAlpha)
					local epsilon = 0.087 -- about 5 degree
					if padSide == "right" then clamp(ballAngle, math.pi/2+epsilon, math.pi*6/4-epsilon)
					else if ballAngle > math.pi/2 and ballAngle < math.pi*6/4 then
							if ballAngle < math.pi then ballAngle = math.pi/2-epsilon
							else ballAngle = math.pi*6/4+epsilon end
						end
					end
					
					cosinus, sinus = math.cos(ballAngle), math.sin(ballAngle)
					
					-- fx
					screenshake.shake(1)
					hitSound:setPitch(1+math.random()-0.5)
					hitSound:play()
				
				-- scored
				else
					if padSide == "left" then 
						scoreRight = scoreRight+1
						if scoreRight >= scoreGoal then
							if ai then winner = "The AI" else winner = "PLAYER 2" end
							changeToScreen = "scoreScreen"
						else reset() end
					else 
						scoreLeft = scoreLeft+1
						if scoreLeft >= scoreGoal then
							winner = "PLAYER 1"
							changeToScreen = "scoreScreen"
						else reset() end
					end
					--fx
					screenshake.shake(3)
					failSound:play()
				end
			end
		end
		
		-- update trail
		table.insert(trail, {x = visualOffsetX+ballX, y = visualOffsetY+ballY})
		if #trail > 10 then table.remove(trail, 1) end
		
		-- ball acceleration
		if ballV < ballMaxV then ballV = ballV*1.0005 end
		
		-- update top and bottom borders + screenShake
		border_functions.updateGraphs()
	end
end

function gameScreen.draw()
	love.graphics.setColor(70, 70, 70)
	love.graphics.line(visualOffsetX, visualOffsetY+top_border(0), visualOffsetX, visualOffsetY+bottom_border(0))
	love.graphics.line(visualOffsetX+stageW, visualOffsetY+top_border(stageW), visualOffsetX+stageW, visualOffsetY+bottom_border(stageW))
	if countdown > 0 then love.graphics.circle("line", visualOffsetX+stageW/2, visualOffsetY+stageH/2, countdown*15) end
	for k, v in ipairs(trail) do love.graphics.circle("line", v.x, v.y, k) end
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(border_functions.topGraph)
	love.graphics.line(border_functions.bottomGraph)
	love.graphics.circle("line", visualOffsetX+ballX+screenshake.x, visualOffsetY+ballY+screenshake.y, ballRadius)
	love.graphics.line(visualOffsetX, visualOffsetY+leftPadY-leftPadSize, visualOffsetX, visualOffsetY+leftPadY+leftPadSize)
	love.graphics.line(visualOffsetX+stageW, visualOffsetY+rightPadY-rightPadSize, visualOffsetX+stageW, visualOffsetY+rightPadY+rightPadSize)
	love.graphics.printf(scoreLeft..":"..scoreRight, visualOffsetX+stageW/2-20, scoreY, 40, "center")
	if android then
		for k, v in ipairs(android_buttons) do
			love.graphics.rectangle("line", v.x, v.y, android_buttons_w, android_buttons_h)
		end
	end
	if paused then 
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255)
		buttonsManager.draw() 
		love.graphics.printf("PAUSED", centerX-30, centerY-halfFontHeight-30, 60, "center") 
	end
end

function gameScreen.mousepressed(x, y, button, istouch)
    if paused then buttonsManager:callback(x, y) end
end

function gameScreen.keypressed(key) 
	if key == "escape" then 
		paused = not paused
		if paused then love.mouse.setVisible(true)
		else love.mouse.setVisible(false) end
		
	elseif key == "r" then reset() end
end

function gameScreen.setUI()
	scoreY = visualOffsetY+border_functions.top_max-10-halfFontHeight*2
	buttonsManager:new(centerX-60, centerY, 120, 60, "EXIT TO MENU",
        function() changeToScreen = "menuScreen" love.audio.resume() end)
		
	if android then
		local offset = android_buttons_offset
		local w, h = android_buttons_w, android_buttons_h
		android_buttons = {}
		table.insert(android_buttons, {x = offset, y = offset, callback = function(dt) leftPadY = leftPadY-padV*dt end})
		table.insert(android_buttons, {x = offset, y = windowH-offset-h, callback = function(dt) leftPadY = leftPadY+padV*dt end})
		if not ai then
			table.insert(android_buttons, {x = windowW-offset-w, y = offset, callback = function(dt) rightPadY = rightPadY-padV*dt end})
			table.insert(android_buttons, {x = windowW-offset-w, y = windowH-offset-h, callback = function(dt) rightPadY = rightPadY+padV*dt end})
		end
	end
end

return gameScreen 