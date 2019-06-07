local blackboard, currentScreen
local transitionPhase, transition_angle = nil, 0

local initialVolume, targetVolume, alpha = 0.1, 0.1, 0
function setMusicVolume(volume)
	if not muted then targetVolume = volume end
end

local function updateVolume(dt)
	alpha = alpha+dt*1.5
	if alpha < 1 then
		song:setVolume(initialVolume*(1-alpha)+targetVolume*alpha)
	else
		song:setVolume(targetVolume)
		initialVolume = targetVolume
		alpha = 0
	end
end

local function switchMute()
	if muted then 
		muted = false
		if currentScreen.name == "gameScreen" then setMusicVolume(0.8)
		else setMusicVolume(0.1) end
	else
		setMusicVolume(0)
		muted = true
	end
end

function love.load()
	math.randomseed(os.time())
	blackboard = require 'blackboard'
	currentScreen = require 'logoScreen'
	currentScreen.load()
	currentScreen.setUI()
	song:setVolume(0.1)
	song:setLooping(true)
	song:play()
end

local function changeScreen(dt)
	buttonsManager.clear()
	paused = false
	love.mouse.setVisible(true)

	if currentScreen.name == "logoScreen" then 
		package.loaded.logoScreen = nil
	elseif currentScreen.name == "menuScreen" then 
		package.loaded.menuScreen = nil
	elseif currentScreen.name == "gameScreen" then 
		package.loaded.gameScreen = nil
	elseif currentScreen.name == "scoreScreen" then
		package.loaded.scoreScreen = nil
	end
	
	currentScreen = require(changeToScreen)
	currentScreen.load()
	currentScreen.setUI()
	currentScreen.update(dt)
	
	changeToScreen = nil
end

local function updateTransitionAngle(dt)
	transition_angle = transition_angle + dt*10
end

local function fadeIn(dt)
	updateTransitionAngle(dt)
	if transition_angle >= math.pi then
		transitionPhase = nil
		transition_angle = 0
	end
end

local function fadeOut(dt)
	updateTransitionAngle(dt)
	if transition_angle >= math.pi/2 then 
		changeScreen(dt)
		transitionPhase = fadeIn
	end
end

function love.update(dt)
	if not paused then timer = timer+dt end
	buttonsManager.update()
	screenshake.update(dt)
	currentScreen.update(dt)
	
	-- change screen
	if changeToScreen ~= nil then transitionPhase = fadeOut end
	if transitionPhase ~= nil then transitionPhase(dt) end
	
	if initialVolume ~= targetVolume then updateVolume(dt) end
end

function love.draw() 	
	currentScreen.draw()
	
	if transition_angle > 0 then 
		love.graphics.setColor(0, 0, 0, math.sin(transition_angle)*255)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function love.mousepressed(x, y, button, istouch)
	currentScreen.mousepressed(x, y, button, istouch)
end

local function switchFullscreen()
	local fullscreen, fstype = love.window.getFullscreen()
	love.window.setFullscreen(not fullscreen)
	blackboard.resize()
	buttonsManager.clear()
	currentScreen.setUI()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f" then switchFullscreen()
	elseif key == "m" then switchMute()
	else currentScreen.keypressed(key) end
end 