block = {}


function block.create(collider,variation,color,initX,initY)
    local mainBlock={}
    local a=30
    local h=a*math.sqrt(3)/2
    
    if variation == 1 then
        mainBlock.blockMap={{1,1}}
        mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY+h,initX+a,initY)
        mainBlock.parity = -1
    end
	if variation == 2 then
        mainBlock.blockMap={{1,1}}
        mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY+-h,initX+a,initY)
        mainBlock.parity = 1
    end
    if variation == 3 then
        mainBlock.blockMap = {{1,1},{1,2},{2,1},{2,2}}
        mainBlock.shape = collider:polygon(initX,initY,initX+a,initY,initX+3*a/2,initY+h,initX+a,initY+2*h,initX,initY+2*h,initX+a/2,initY+h)
        mainBlock.parity = -1
    end
	if variation == 4 then 
		mainBlock.blockMap = {{1,1},{1,2},{2,1},{2,2}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+3*a/2,initY-h,initX+a,initY,initX+3*a/2,initY+h,initX+a/2,initY+h)
		mainBlock.parity = 1 
	end
	if variation == 5 then --losange vertical
		mainBlock.blockMap = {{1,1},{2,1}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+a,initY,initX+a/2,initY+h)
		mainBlock.parity = 1 
	end
	if variation == 6 then --losange horizontal 1 
		mainBlock.blockMap = {{1,1},{1,2}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+3*a/2,initY-h,initX+a,initY)
		mainBlock.parity = 1 
	end
	if variation == 7 then --losange horizontal 2 
		mainBlock.blockMap = {{1,1},{1,2}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a,initY,initX+3*a/2,initY+h,initX+a/2,initY+h)
		mainBlock.parity = -1 
	end
	if variation == 8 then 
		mainBlock.blockMap = {{1,1},{2,1},{2,2},{3,2}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+a,initY,initX+3*a/2,initY+h, initX+a, initY+2*h, initX+a/2, initY+h)
		mainBlock.parity = 1 
	end
	if variation == 9 then 
		mainBlock.blockMap = {{1,1},{1,2},{1,3},{2,1},{2,0}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+3*a/2,initY-h,initX+2*a,initY, initX+a, initY, initX+a/2, initY+h, initX-a/2, initY+h)
		mainBlock.parity = 1 
	end
	if variation == 10 then 
		mainBlock.blockMap = {{1,1},{1,2},{0,2},{2,1},{2,2}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+a,initY-2*h,initX+3*a/2,initY-h, initX+a, initY, initX+3*a/2, initY+h, initX+a/2, initY+h)
		mainBlock.parity = 1 
	end
	if variation == 11 then 
		mainBlock.blockMap = {{1,1},{1,2},{1,3},{2,3},{2,4}}
		mainBlock.shape = collider:polygon(initX,initY,initX+a/2,initY-h,initX+3*a/2,initY-h,initX+2*a,initY, initX+5*a/2, initY+h, initX+3*a/2, initY+h, initX+a, initY)
		mainBlock.parity = 1 
	end
	

    mainBlock.color = color
    mainBlock.isGrabbed=0
    local xC,yC = mainBlock.shape:center()
    mainBlock.centerToX = initX + a/2 - xC
    mainBlock.centerToY = initY - mainBlock.parity*h/2 - yC
    return mainBlock
end

function block.draw(block)
    if block.color == 1 then
        love.graphics.setColor(color1)
    end
    if block.color == 2 then
        love.graphics.setColor(color2)
        --love.graphics.circle('fill',100,100,50,50)
        --block.shape:draw('fill')
        --love.graphics.setColor(255,0,0)
    end
    --love.graphics.setColor(65,223,140)
    block.shape:draw('fill')
    --love.graphics.circle('fill',100,100,50,50)
    --love.graphics.polygon('fill',block.shape:unpack())
    love.graphics.reset()
    love.graphics.setBackgroundColor(255,255,255)
end


function block.move(block)
    if block.isGrabbed==1 then
        local x,y = player1.shape:center()
        block.shape:move(x-player1.x_old,y-player1.y_old)
    end
    if block.isGrabbed==2 then
        local x,y = player2.shape:center()
        block.shape:move(x-player2.x_old,y-player2.y_old)
    end
end

function block.release(block,myHome,i)
    toRemove = false
    if block.isGrabbed == 1 then
        if not player1.grabbing then
            block.isGrabbed = 0
            local xC,yC = block.shape:center()
            it,jt = home.whereOnGrid(myHome, xC+block.centerToX, yC+block.centerToY)
            if it>0 then
                if block.parity == myHome.parityMat[it][jt] then
                    map = block.blockMap
                    fits = true
                    for bite,tri in pairs(map) do
                        if it+tri[1]-1>0 and it+tri[1]<13 and jt+tri[2]>0 and jt+tri[2]<24 then
                            if not (myHome.grid.m[it+tri[1]-1][jt+tri[2]-1]==0) then
                                fits=false
                            --myHome.grid.m[it][jt] = block.color
                            end
                        else
                            fits=false
                        end
                    end 
                    if fits then
                        toRemove=true
                        for bite,tri in pairs(map) do
                            myHome.grid.m[it+tri[1]-1][jt+tri[2]-1] = block.color                            
                        end
                        
                    end
                end
            end
        end
    end
    if block.isGrabbed == 2 then
        if not player2.grabbing then
            block.isGrabbed = 0
            local xC,yC = block.shape:center()
            it,jt = home.whereOnGrid(myHome, xC+block.centerToX, yC+block.centerToY)
            if it>0 then
                if block.parity == myHome.parityMat[it][jt] then
                    map = block.blockMap
                    fits = true
                    for bite,tri in pairs(map) do
                        if it+tri[1]-1>0 and it+tri[1]<13 and jt+tri[2]>0 and jt+tri[2]<24 then
                            if not (myHome.grid.m[it+tri[1]-1][jt+tri[2]-1]==0) then
                                fits=false
                            end
                        else
                            fits=false
                        end
                    end 
                    if fits then
                        toRemove=true
                        for bite,tri in pairs(map) do
                            myHome.grid.m[it+tri[1]-1][jt+tri[2]-1] = block.color                            
                        end 
                    end
                end
            end
        end
    end
    if toRemove then
        table.remove(blocks,i)
		tchakSound:play()
    end
    return toRemove
end
    --block.blockMap[1][0]

return block
