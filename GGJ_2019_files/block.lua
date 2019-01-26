block = {}


function block.create(collider)
    local mainBlock={}
    mainBlock.blockMap = {{1,1}}--{{0,0},{0,1},{1,0}}
    --mainBlock.perimeter = polygon(100,100, 120,115, 80,115)
    --mainBlock.shape = shapes.newPolygonShape(mainBlock.perimeter)
    mainBlock.shape = collider:polygon(100,100,120,115,80,115)--collider:circle(150,150,5)
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

function block.release(block)
    if block.isGrabbed == 1 then
        if not player1.grabing then
            block.isGrabbed = 0
        end
    end
    if block.isGrabbed == 2 then
        if not player2.grabing then
            block.isGrabbed = 0
        end
    end
end
    --block.blockMap[1][0]

return block
