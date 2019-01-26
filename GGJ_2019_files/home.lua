local M = require "math"
home = {}

--Create the basic hexagon grid
--For now: only 12 max height, 23 max width 
--TODO: arbitrary size
--n must be even, m must be odd and at least superior to n+1
function gridCreate(collider, trWidth)
    grid = {}
    m = {}
    for i=1,12 do
        m[i] = {}
        for j=1,23 do
            m[i][j] = 0
        end
    end
    grid.m = m
    grid.trWidth = trWidth -- length of the triangle 
    grid.radius = trWidth*23/2 -- approximate width of grid
    --Real position of the mid left triangle in the plane
    xA=screenWidth/2 - grid.radius 
    yA=screenHeight/2
    xB=xA+trWidth
    yB=yA
    xC=xA+trWidth/2
    yC=yA+trWidth*M.sqrt(3)/2
    grid.midLeft = Polygon(xA,yA,xB,yB,xC,yC) 
    --Approximate center of grid
    xCenter = xA+grid.radius
    yCenter = yA
    grid.shape = collider:circle(xCenter,yCenter,grid.radius)
    return grid
end


--Function returning the coordinates of nearest center 
--in matrix given a real world position, and the delta between them
function home.getNearestCenter(x,y,grid)
    local firstPoly = grid.midLeft
    local a = grid.trWidth
    xC = firstPoly[0] + a*sqrt(3)/6
    yC = firstPoly[1] + a*sqrt(3)/6
    local xO=x-xC -- new vector in grid local reference frame 
    local yO=y-yC
    i = 1 + M.floor(xO)
    j = 1 + M.floor(yO)
    xGrid = xC + i*a
    yGrid = yC + i*a*M.sqrt(3)/2
    delta = {}
    delta.x = x - xGrid
    delta.y = y - yGrid
    return delta,xGrid,yGrid 
end

function home.create(collider,trWidth)
    ourHome = {}
    ourHome.sprite = homeSprite
    ourHome.grid = gridCreate(collider, trWidth)
    return ourHome
end

function extractPointsFromPoly(poly)
    list={}
    for k,v in pairs(poly.vertices) do
        local x = v.x
        local y = v.y
        table.insert(list,x)
        table.insert(list,y)
    end
    return list
end

function home.draw(home)
    local firstPoly = home.grid.midLeft
    local x,y = home.grid.shape:center()
    local spr = home.sprite
    pointList = extractPointsFromPoly(firstPoly)
    love.graphics.polygon("line",pointList)
    love.graphics.circle("line",x,y, home.grid.radius)
    love.graphics.circle("fill",x,y, 50)
    love.graphics.draw(spr,screenWidth/2-spr:getWidth(),screenHeight/2-spr:getHeight())
end

return home
