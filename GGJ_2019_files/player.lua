 player = {}

--[[
--TODO: add sprite sheet 
--]]

function player.create(collider)--,colours)
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
    spriteSheet=love.graphics.newImage("graphisme/move-bleu-15px/haut-gauche-bleu/result_sprite.png")
    mainPlayer.animation = player.newAnimation(spriteSheet,45,45,1)--,colours)
    return mainPlayer
end

function player.newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    print(image)
    animation.quads = {}
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
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
    --love.graphics.circle("fill",x,y,player.radius)
    --love.graphics.draw(spriteJ1,x,y)
    local anim = player.animation
    local spriteNum = math.floor(anim.currentTime / anim.duration * #anim.quads) + 1
    love.graphics.draw(anim.spriteSheet, anim.quads[spriteNum],x,y)
end

function player.updateGrab(player)
    local gAxis = joystick:getAxis(player.grabIndex)
    if gAxis>-0.5 then
        player.grabbing=true
    else
        player.grabbing=false
    end
end

function player.updateAnimation(player,dt)
    local anim = player.animation
    anim.currentTime = anim.currentTime + dt
    if anim.currentTime >= anim.duration then
        anim.currentTime = anim.currentTime - anim.duration
    end
end


return player
