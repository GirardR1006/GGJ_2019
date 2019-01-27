block = {}


function block.create(collider)
    local mainBlock={}
    mainBlock.blockMap = {{1,1},{1,2},{2,1},{2,2}}--{{0,0},{0,1},{1,0}}
    mainBlock.color = 2
    local a=30
    local h=a*math.sqrt(3)/2
    --mainBlock.perimeter = polygon(100,100, 120,115, 80,115)
    --mainBlock.shape = shapes.newPolygonShape(mainBlock.perimeter)
    mainBlock.shape = collider:polygon(100,100,100+a,100,100+3*a/2,100+h,100+a,100+2*h,100,100+2*h,100+a/2,100+h)--collider:circle(150,150,5)
    mainBlock.isGrabbed=0
    local xC,yC = mainBlock.shape:center()
    mainBlock.centerToX = 100 + a/2 - xC
    mainBlock.centerToY = 100 + h/2 - yC
    mainBlock.parity = -1
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
                    print(it)
                    for bite,tri in pairs(map) do
                        if not (myHome.grid.m[it+tri[1]-1][jt+tri[2]-1]==0) then
                            fits=false
                            --myHome.grid.m[it][jt] = block.color
                        end
                    end 
                    print(fits)
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
            it,jt = home.whereOnGrid(myHome, block.shape:center())
            if it>0 then
                if myHome.grid.m[it][jt]==0 then
                    toRemove=true
                    myHome.grid.m[it][jt] = block.color
                end
            end
        end
    end
    if toRemove then
        table.remove(blocks,i)
    end
end
    --block.blockMap[1][0]

return block
