 player = {}

--[[
--We can create a bunch of functions here and add them to the module_a module
--]]

function player.create(collider)
    local mainPlayer={}
    mainPlayer.radius = 10
    mainPlayer.shape = collider:circle(150,150,mainPlayer.radius)
    mainPlayer.grabShape = collider:circle(150,150,mainPlayer.radius*2)
    mainPlayer.xAxisIndex = 0
    mainPlayer.yAxisIndex = 0
    mainPlayer.grabIndex = 0
    mainPlayer.speed=200
    mainPlayer.grabbing=false
    mainPlayer.x_old=0
    mainPlayer.y_old=0
    return mainPlayer
end

function player.move(player, dt, joystick) --joystick object
    local x,y = player.shape:center()
    player.x_old,player.y_old = x,y
    local radius = player.radius
	local xAxis = joystick:getAxis(player.xAxisIndex)
	local yAxis = joystick:getAxis(player.yAxisIndex)
    if math.abs(xAxis)>0.15 then
        predicted_x=x+xAxis*player.speed*dt
        if predicted_x+radius < (screenWidth) and predicted_x-radius > 0 then
            player.shape:moveTo(predicted_x,y)
        end
    end
    local x,y = player.shape:center()
    if math.abs(yAxis)>0.15 then
        predicted_y=y+yAxis*player.speed*dt
	    if predicted_y-radius > 0 and  predicted_y+radius < (screenHeight) then
            player.shape:moveTo(x,predicted_y)
        end
    player.grabShape:moveTo(player.shape:center())
    end
end

function player.draw(player)
    local x,y = player.shape:center()
    love.graphics.circle("fill",x,y,player.radius)
end

function player.updateGrab(player)
    local gAxis = joystick:getAxis(player.grabIndex)
    if gAxis>-0.5 then
        player.grabbing=true
    else
        player.grabbing=false
    end
end

return player
