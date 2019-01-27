 player = {}

--[[
--TODO: add sprite sheet 
--]]

function player.create(collider,number)--,colours)
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
	mainPlayer.releaseSoundOnce = false
	mainPlayer.sadSoundOnce = false
	mainPlayer.happySoundOnce = false
	mainPlayer.timerHappy = 0
	mainPlayer.happyState = false
	mainPlayer.happyThreshold = math.random(20,30)
	mainPlayer.timerSad = 15
	mainPlayer.sadState = false
	mainPlayer.sadThreshold = math.random(20,30)
    gPath="graphisme/animation/move/"
    if number == 1 then
        c = "rose"
    else
        c = "vert"
    end
    sprShHR=love.graphics.newImage(gPath.."move-"..c.."/haut-"..c.."/result_sprite.png")
    sprShHDR=love.graphics.newImage(gPath.."move-"..c.."/haut-droite-"..c.."/result_sprite.png")
    sprShHGR=love.graphics.newImage(gPath.."move-"..c.."/haut-gauche-"..c.."/result_sprite.png")
    sprShBR=love.graphics.newImage(gPath.."move-"..c.."/bas-"..c.."/result_sprite.png")
    sprShBGR=love.graphics.newImage(gPath.."move-"..c.."/bas-gauche-"..c.."/result_sprite.png")
    sprShBDR=love.graphics.newImage(gPath.."move-"..c.."/bas-droite-"..c.."/result_sprite.png")
	sprShHappy=love.graphics.newImage("graphisme/animation/emotions/"..c.."-content/result_sprite.png")
	sprShSad=love.graphics.newImage("graphisme/animation/emotions/"..c.."-stress/result_sprite.png")
    mainPlayer.animHR = player.newAnimation(sprShHR,45,45,1)--,colours)
    mainPlayer.animHDR = player.newAnimation(sprShHDR,45,45,1)--,colours)
    mainPlayer.animHGR = player.newAnimation(sprShHGR,45,45,1)--,colours)
    mainPlayer.animBR = player.newAnimation(sprShBR,45,45,1)--,colours)
    mainPlayer.animBGR = player.newAnimation(sprShBGR,45,45,1)--,colours)
    mainPlayer.animBDR = player.newAnimation(sprShBDR,45,45,1)--,colours)
	mainPlayer.animHappy = player.newAnimation(sprShHappy,45,45,1)--,colours)
	mainPlayer.animSad= player.newAnimation(sprShSad,45,45,1)--,colours)
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
		grabSound:play()
	end		
end

function player.playReleaseSound(once)
	if not once then
		releaseSound:play()
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
	local animHappy = actualPlayer.animHappy
	local animSad = actualPlayer.animSad
    --Offset: the quads are 45 pixels wide
    local xO = x-45/2
    local yO = y-45/2
    --Draw correct animation according to direction
    --If moving, the animation goes according to direction
    --Drawing only the first quad is a terrible hack
    --And it's terrible on screen
    --Please forgive me
	if actualPlayer.happyState then
		local spriteNum = player.getSpriteNum(animHappy)
		love.graphics.draw(animHappy.spriteSheet, animHappy.quads[spriteNum], xO, yO)
	elseif actualPlayer.sadState then
		local spriteNum = player.getSpriteNum(animSad)
		love.graphics.draw(animSad.spriteSheet, animSad.quads[spriteNum], xO, yO)
	else
        if dir.down then
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
    end
end

function player.updateGrab(actualPlayer)
    local gAxis = joystick:getAxis(actualPlayer.grabIndex)
    if gAxis>-0.5 then
        actualPlayer.grabbing=true
		player.playGrabSound(actualPlayer.grabSoundOnce)
		actualPlayer.grabSoundOnce = true 
		actualPlayer.releaseSoundOnce = false 
    else
        actualPlayer.grabbing=false
		actualPlayer.grabSoundOnce = false
		player.playReleaseSound(actualPlayer.releaseSoundOnce)
		actualPlayer.releaseSoundOnce = true 
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
	local animHappy = actualPlayer.animHappy
	local animSad = actualPlayer.animSad
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
	if actualPlayer.happyState then
		animHappy.currentTime = animHappy.currentTime + dt
	end
	if actualPlayer.sadState then
		animSad.currentTime = animSad.currentTime + dt
	end
    player.resetAnim(animHR)
    player.resetAnim(animHDR)
    player.resetAnim(animHGR)
    player.resetAnim(animBR)
    player.resetAnim(animBGR)
    player.resetAnim(animBDR)
	player.resetAnim(animHappy)
	player.resetAnim(animSad)
end


function player.updateEmotion(actualPlayer, dt)
	actualPlayer.timerHappy = actualPlayer.timerHappy + dt
	actualPlayer.timerSad = actualPlayer.timerSad + dt
	if actualPlayer.timerHappy > actualPlayer.happyThreshold then
		happySound:play()
		actualPlayer.timerHappy = 0
		actualPlayer.happyState = true
		actualPlayer.happyThreshold = math.random(20,30)
	end
	if actualPlayer.timerHappy >= actualPlayer.animHappy.duration then
		actualPlayer.happyState = false
	end
	if actualPlayer.timerSad > actualPlayer.sadThreshold then
		sadSound:play()
		actualPlayer.timerSad = 0
		actualPlayer.sadState = true
		actualPlayer.sadThreshold = math.random(20,30)
	end
	if actualPlayer.timerSad >= actualPlayer.animSad.duration then
		actualPlayer.sadState = false
	end
end
	


return player
