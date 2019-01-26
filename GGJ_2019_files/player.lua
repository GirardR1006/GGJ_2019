 player = {}

--[[
--We can create a bunch of functions here and add them to the module_a module
--]]

function player.create()
    local mainPlayer={}
    mainPlayer.xAxisIndex = 0
    mainPlayer.yAxisIndex = 0
    mainPlayer.position = {x= 400, y=300}
    mainPlayer.speed=300
    return mainPlayer
end

function player.move(player, dt, joystick) --joystick object
    --TODO: moving
	local xAxis = joystick:getAxis(player.xAxisIndex)
	local yAxis = joystick:getAxis(player.yAxisIndex)
	--xAxis2 = joystick:getAxis(4)
	--yAxis2 = joystick:getAxis(5)
	if math.abs(xAxis)>0.15 then
		player.position.x = player.position.x + xAxis*player.speed*dt
	end
	if math.abs(yAxis)>0.15 then
		player.position.y = player.position.y + yAxis*player.speed*dt
	end
end

function player.draw(player)
    love.graphics.circle("fill",player.position.x,player.position.y,20)
end

return player
