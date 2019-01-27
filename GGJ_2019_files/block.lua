block = {}


function block.create(collider)
    local mainBlock={}
    mainBlock.blockMap = {{1,1}}--{{0,0},{0,1},{1,0}}
    --mainBlock.perimeter = polygon(100,100, 120,115, 80,115)
    --mainBlock.shape = shapes.newPolygonShape(mainBlock.perimeter)
    mainBlock.shape = collider:polygon(100,100,130,100,115,100+math.sqrt(3*900/4))--collider:circle(150,150,5)
    mainBlock.isGrabbed=0
    return mainBlock
end

function block.draw(block)
    block.shape:draw('fill')
    --love.graphics.polygon('fill',block.shape:unpack())
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
            it,jt = home.whereOnGrid(myHome, block.shape:center())
            if it>0 then
                if myHome.grid.m[it][jt]==0 then
                    toRemove=true
                    myHome.grid.m[it][jt] = 1
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
                    myHome.grid.m[it][jt] = 2
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
