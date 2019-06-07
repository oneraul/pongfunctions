local border_functions = {}

border_functions.funcs = {

function(x, side) 
-- line
return 0 
end,

function(x, side)
-- spikes1
	local size = stageW/16
	local tmp = x*0.5 % size
	if tmp > size/2 then tmp = size - tmp end
	return tmp*side
end,

function(x, side)
-- spikes2
	local size = stageW/4
	local tmp = x*1.5 % size
	if tmp > size/2 then tmp = size - tmp end
	return tmp*side
end,

function(x, side)
-- sinus1
	return (math.sin(x/30+timer*3)*20)*side
end,

function(x, side) 
-- sinus2
	local t0, waves0, amplitude0 = timer*10, x/5, 5+math.sin(timer)*4
	local t1, waves1, amplitude1 = timer, x/30, 7
	local t2, waves2, amplitude2 = timer/2, x/7, 2
	local wave = math.sin(waves0+t0)*amplitude0 + math.sin(waves1+t1)*amplitude1 + math.sin(waves2+t2)*amplitude2
	return wave*side
end,

function(x, side) 
-- subebaja
	local amplitude = stageH/12
	return (amplitude + math.sin(timer/4)*amplitude)*side
end,

function(x, side) 
-- parabola1
	local a = math.sin(timer)*0.002
	return (-a*(x-stageW/2)*(x-stageW/2))*side
end,

function(x, side) 
-- parabola2
	return (-0.002*(x-stageW/2)*(x-stageW/2))*side
end,

function(x, side) 
-- parabola3
	return (0.002*(x-stageW/2)*(x-stageW/2))*side
end,

function(x, side)
-- slope
	local x0, y0 = stageW/2, 0
	local x1, y1 = 0, math.sin(timer*8)*40
	local m = (y1-y0)/(x1-x0)
	return (m*(x-x0)+y0)*side
end,

function(x, side)
-- circle1
	local r = 80
	if x < stageW/2-r or x > stageW/2+r then return 0
	else return math.sqrt(r*r-(x-stageW/2)*(x-stageW/2))*side
	end
end,

function(x, side)
-- circle2
	local r = 80
	if x < stageW/2-r or x > stageW/2+r then return 0
	else return -math.sqrt(r*r-(x-stageW/2)*(x-stageW/2))*side
	end
end,

function(x, side)
-- square
	if x < stageW/2-50 or x > stageW/2+50 then return 0
	else return -100*side end
end,

}

border_functions.top, border_functions.bottom = 1, 2
border_functions.top_max = 0
border_functions.topGraph, border_functions.bottomGraph = {}, {}

function top_border(x) return border_functions.funcs[border_functions.top](x, -1) end
function bottom_border(x) return border_functions.funcs[border_functions.bottom](x, 1)+stageH end

local function getMax(func)
	local current_max = 0
	for x = 0, stageW do
		local y = func(x, 1)
		if y > current_max then current_max = y end
	end
	
	return current_max
end

function border_functions.setTop_max()
	border_functions.top_max = -getMax(border_functions.funcs[border_functions.top])
end

function border_functions.updateGraphs()
	border_functions.topGraph, border_functions.bottomGraph = {}, {}
	for x = 0, stageW do 
		if border_functions.top ~= 0 then
			table.insert(border_functions.topGraph, visualOffsetX+x+screenshake.x)
			table.insert(border_functions.topGraph, visualOffsetY+top_border(x)+screenshake.y)
		end
		if border_functions.bottom ~= 0 then
			table.insert(border_functions.bottomGraph, visualOffsetX+x+screenshake.x)
			table.insert(border_functions.bottomGraph, visualOffsetY+bottom_border(x)+screenshake.y)
		end
	end
end

return border_functions