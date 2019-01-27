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
	mainPlayer.happy = false
	mainPlayer.sad = false
	mainPlayer.grabSoundOnce = false
    gPath="graphisme/animation/move/"
    sprShHR=love.graphics.newImage(gPath.."move-rose/haut-rose/result_sprite.png")
    sprShHDR=love.graphics.newImage(gPath.."move-rose/haut-droite-rose/result_sprite.png")
    sprShHGR=love.graphics.newImage(gPath.."move-rose/haut-gauche-rose/result_sprite.png")
    sprShBR=love.graphics.newImage(gPath.."move-rose/bas-rose/result_sprite.png")
    sprShBGR=love.graphics.newImage(gPath.."move-rose/bas-gauche-rose/result_sprite.png")
    sprShBDR=love.graphics.newImage(gPath.."move-rose/bas-droite-rose/result_sprite.png")
    mainPlayer.animHR = player.newAnimation(sprShHR,45,45,1)--,colours)
    mainPlayer.animHDR = player.newAnimation(sprShHDR,45,45,1)--,colours)
    mainPlayer.animHGR = player.newAnimation(sprShHGR,45,45,1)--,colours)
    mainPlayer.animBR = player.newAnimation(sprShBR,45,45,1)--,colours)
    mainPlayer.animBGR = player.newAnimation(sprShBGR,45,45,1)--,colours)
    mainPlayer.animBDR = player.newAnimation(sprShBDR,45,45,1)--,colours)
    local movement = {}
    movement.up=false
    movement.down=false
    movement.left=false
    movement.right=false
    mainPlayer.direction = movement
    return mainPlayer
end

--Section bruitages
function player.playGrabSound(once)
	if not once then
		grabSound.play()
	end		
end


function player.newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
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
            if xAxis > 0.2 then
                player.direction.right=true
                player.direction.left=false
            elseif xAxis < -0.2 then
                player.direction.right=false
                player.direction.left=true
            else
                player.direction.right=false
                player.direction.left=false
            end
        end
    end
    local x,y = player.shape:center()
    if math.abs(yAxis)>0.15 then
        predicted_y=y+yAxis*player.speed*dt
	    if predicted_y-radius > 0 and  predicted_y+radius < (screenHeight) then
            player.shape:moveTo(x,predicted_y)
            if yAxis > 0.2 then
                player.direction.up=true
                player.direction.down=false
            elseif yAxis < -0.2 then
                player.direction.up=false
                player.direction.down=true
            else
                player.direction.up=false
                player.direction.down=false

            end
        end
    end
    player.grabShape:moveTo(player.shape:center())
end

function player.getSpriteNum(anim)
    local spriteNum = math.floor(anim.currentTime / anim.duration * #anim.quads) + 1
    return spriteNum
end

function player.draw(actualPlayer,beginning)
    local x,y = actualPlayer.shape:center()
    local dir = actualPlayer.direction
    local animHR = actualPlayer.animHR
    local animHDR = actualPlayer.animHDR
    local animHGR = actualPlayer.animHGR
    local animBR = actualPlayer.animBR
    local animBDR = actualPlayer.animBDR
    local animBGR = actualPlayer.animBGR
    --Offset: the quads are 45 pixels wide
    local xO = x-45/2
    local yO = y-45/2
    --Draw correct animation according to direction
    --If moving, the animation goes according to direction
    --Drawing only the first quad is a terrible hack
    --And it's terrible on screen
    --Please forgive me
    if dir.down then
        --print("Dir down")
        if dir.right then
            local spriteNumHDR = player.getSpriteNum(animHDR)
            love.graphics.draw(animHDR.spriteSheet, animHDR.quads[spriteNumHDR],xO,yO)
            love.graphics.draw(animHGR.spriteSheet, animHGR.quads[1],xO,yO)
            love.graphics.draw(animHR.spriteSheet, animHR.quads[1],xO,yO)
        elseif dir.left then
            local spriteNum = player.getSpriteNum(animHGR)
            love.graphics.draw(animHGR.spriteSheet, animHGR.quads[spriteNum],xO,yO) 
            love.graphics.draw(animHDR.spriteSheet, animHDR.quads[1],xO,yO) 
            love.graphics.draw(animHR.spriteSheet, animHR.quads[1],xO,yO)
        else
            local spriteNum = player.getSpriteNum(animHR)
            love.graphics.draw(animHR.spriteSheet, animHR.quads[spriteNum],xO,yO)
            love.graphics.draw(animHGR.spriteSheet, animHGR.quads[1],xO,yO)
            love.graphics.draw(animHDR.spriteSheet, animHDR.quads[1],xO,yO)
        end
        love.graphics.draw(animBR.spriteSheet, animBR.quads[1],xO,yO)
        love.graphics.draw(animBGR.spriteSheet, animBGR.quads[1],xO,yO)
        love.graphics.draw(animBDR.spriteSheet, animBDR.quads[1],xO,yO)

    elseif dir.up then
        --print("Dir up")
        if dir.right then
            local spriteNum = player.getSpriteNum(animBDR)
            love.graphics.draw(animBDR.spriteSheet, animBDR.quads[spriteNum],xO,yO)
            love.graphics.draw(animBGR.spriteSheet, animBGR.quads[1],xO,yO)
            love.graphics.draw(animBR.spriteSheet, animBR.quads[1],xO,yO)
        elseif dir.left then
            local spriteNum = player.getSpriteNum(animBGR)
            love.graphics.draw(animBGR.spriteSheet, animBGR.quads[spriteNum],xO,yO) 
            love.graphics.draw(animBDR.spriteSheet, animBDR.quads[1],xO,yO) 
            love.graphics.draw(animBR.spriteSheet, animBR.quads[1],xO,yO)
        else
            local spriteNum = player.getSpriteNum(animBR)
            love.graphics.draw(animBR.spriteSheet, animBR.quads[spriteNum],xO,yO)
            love.graphics.draw(animBGR.spriteSheet, animBGR.quads[1],xO,yO)
            love.graphics.draw(animBDR.spriteSheet, animBDR.quads[1],xO,yO)
        end
        local spriteNum = player.getSpriteNum(animBR)
        love.graphics.draw(animHR.spriteSheet, animHR.quads[1],xO,yO)
        love.graphics.draw(animHGR.spriteSheet, animHGR.quads[1],xO,yO)
        love.graphics.draw(animHDR.spriteSheet, animHDR.quads[1],xO,yO)
    else
        love.graphics.draw(animBR.spriteSheet, animBR.quads[1],xO,yO)
        love.graphics.draw(animBGR.spriteSheet, animBGR.quads[1],xO,yO)
        love.graphics.draw(animBDR.spriteSheet, animBDR.quads[1],xO,yO)
        love.graphics.draw(animHR.spriteSheet, animHR.quads[1],xO,yO)
        love.graphics.draw(animHGR.spriteSheet, animHGR.quads[1],xO,yO)
        love.graphics.draw(animHDR.spriteSheet, animHDR.quads[1],xO,yO)

    end
    --love.graphics.circle("fill",x,y,15)
end

function player.updateGrab(player)
    local gAxis = joystick:getAxis(player.grabIndex)
    if gAxis>-0.5 then
        player.grabbing=true
		player.playGrabSound(player.grabSoundOnce)
		player.grabSoundOnce = true 
    else
        player.grabbing=false
		player.grabSoundOnce = false
    end
end

function player.resetAnim(anim)
    if anim.currentTime >= anim.duration then
        anim.currentTime = anim.currentTime - anim.duration
    end
end

function player.updateAnimation(actualPlayer,dt)
    --Update animation time if and only if the player is moving towards that direction
    local dir = actualPlayer.direction
    local animHR = actualPlayer.animHR
    local animHDR = actualPlayer.animHDR
    local animHGR = actualPlayer.animHGR
    local animBR = actualPlayer.animBR
    local animBDR = actualPlayer.animBDR
    local animBGR = actualPlayer.animBGR
    if dir.down then
        if dir.right then
            animHDR.currentTime = animHDR.currentTime + dt
        elseif dir.left then
            animHGR.currentTime = animHGR.currentTime + dt
        end
        animHR.currentTime = animHR.currentTime + dt
    elseif dir.up then
        if dir.right then
            animBDR.currentTime = animBDR.currentTime + dt
        elseif dir.left then
            animBGR.currentTime = animBGR.currentTime + dt
        end
        animBR.currentTime = animBR.currentTime + dt
    end
    player.resetAnim(animHR)
    player.resetAnim(animHDR)
    player.resetAnim(animHGR)
    player.resetAnim(animBR)
    player.resetAnim(animBGR)
    player.resetAnim(animBDR)
end



return player
