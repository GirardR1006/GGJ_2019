local M = require "math" 
balance = {}

function balance.create()
    ourBalance = {}
    ourBalance.harmony = 0
    gPath="graphisme/animation/jauge/"
    
    ourBalance.background = love.graphics.newImage(gPath.."fond-jauge-small.png")
    ourBalance.sprSheet = love.graphics.newImage(gPath.."anim-jauge-balance/result_sprite.png")
    ourBalance.animation = balance.newAnimation(sprSheet,90,50,1)
return balance

function balance.newAnimation(image, width, height, duration)
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

function balance.addHarmony(ourBalance,weight)
    ourBalance.harmony = ourBalance.harmony + weight
    return ourBalance
end


function balance.computeEquilibrium(ourBalance,grid)
    local ourGrid = grid
    local accLeft = 0
    local accRight = 0
    for i, line in pairs(ourGrid) do
        for j, cell in pairs(ourGrid[i]) do
            if cell == 1 then
                accLeft = accLeft + 1
            elseif cell == 2 then
                accRight = accRight + 1
            end
        end
    end
    local finalPerturbation  = accLeft - accRight
    balance.addHarmony(ourBalance,finalPerturbation)
end

--Draw the correct balance frame according to harmony of Home
--My soul is doomed
function balance.draw(ourBalance)
    love.graphics.draw(ourBalance.background)
    --Balance fixed
    local xO = 437
    local yO = 0
    local harmony = ourBalance.harmony
    local anim = ourBalance.animation
    local targetQuad = 0
    if harmony < -12 then
        targetQuad = 1
    elseif harmony > 12 then
        targetQuad = 24
    else
        targetQuad = 12 + harmony
    end
    love.graphics.draw(anim.spriteSheet, anim.quads[targetQuad],xO,yO)

end
