local screenshake = {}

local shakes = {}

screenshake.x, screenshake.y = 0, 0

function screenshake.reset() shakes = {} end

function screenshake.setup(id, duration, ammount)
   table.insert(shakes, id, {duration = duration, ammount = ammount, timer = 0})
end

function screenshake.shake(id)
    shakes[id].timer = shakes[id].duration
end

function screenshake.update(dt)
    local ammountSum = 0

    for k, v in ipairs(shakes) do
        if v.timer > 0 then 
            v.timer = v.timer-dt
            if v.timer > 0 then
                ammountSum = ammountSum+v.ammount
            end
        end
    end
    
    screenshake.x = math.random(0, ammountSum)-ammountSum/2
    screenshake.y = math.random(0, ammountSum)-ammountSum/2
end

return screenshake