local M = require "math"
home = {}

--Create the basic hexagon grid
--For now: only 12 max height, 23 max width 
--TODO: arbitrary size
--n must be even, m must be odd and at least superior to n+1
function gridCreate(collider, trWidth)
    grid = {}
    m = {}
    for i=1,6 do
        m[i] = {}
        for j=1,(6-i) do
            m[i][j] = -1
        end
        for j=(7-i),(23-(6-i)) do
            m[i][j] = 0
        end
        for j=(24-(6-i)),23 do
            m[i][j] = -1
        end
    end
    for i=7,12 do
        m[i]={}
        for j=1,23 do
            m[i][j] = m[13-i][j]
        end
    end
  
    grid.m = m
    grid.trWidth = trWidth -- length of the triangle 
    grid.radius = trWidth*12/2 -- approximate width of grid
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
    grid.xOO = xA
    grid.yOO = yA-grid.radius*math.sqrt(3)/2
    grid.shape = collider:circle(xCenter,yCenter,grid.radius)
    return grid
end

function parityCreate()
    m={}
    for i=1,12 do
        m[i]={}
        for j=1,23 do
            if i%2==j%2 then
                m[i][j] = -1
            else
                m[i][j] = 1
            end
        end
    end
    return m
end


--Function returning the coordinates of nearest center 
--in matrix given a real world position, and the delta between them
function home.getNearestCenter(x,y,grid)
    local firstPoly = grid.midLeft
    local a = grid.trWidth
    xC = firstPoly[0] + a*sqrt(3)/6 --a/2 ?
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

function home.whereOnGrid(myHome,x,y)
    local a = myHome.grid.trWidth
    local h = a*M.sqrt(3)/2
    
    i = 1 + M.floor((y-myHome.grid.yOO)/h)

    if i>0 and i<13 then 
        --print('check')
        for j=1,23 do
            xA,yA,xB,yB,xC,yC = home.getPointFromInd(myHome,i,j)
            triangle = Polygon(xA,yA,xB,yB,xC,yC)
            if triangle:contains(x,y) then
                return i,j
            end
        end
    end
    return 0,0
    
end

function home.create(collider,trWidth)
    ourHome = {}
    ourHome.sprite = homeSprite
    ourHome.grid = gridCreate(collider, trWidth)
    ourHome.parityMat = parityCreate()
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

function home.getPointFromInd(home,i,j)
    local a = home.grid.trWidth
    local h = a*M.sqrt(3)/2
    if home.parityMat[i][j]==1 then  --up
        xA = home.grid.xOO + (j-1)*a/2
        yA = home.grid.yOO + i*h
        xB = xA + a
        yB = yA
        xC = (xA+xB)/2
        yC = yA - h
    end
    if home.parityMat[i][j]==-1 then
        xA = home.grid.xOO + (j-1)*a/2
        yA = home.grid.yOO + (i-1)*h
        xB = xA + a
        yB = yA
        xC = (xA+xB)/2
        yC = yA + h
    end
    return xA,yA,xB,yB,xC,yC
end

function home.draw(myHome)
    local firstPoly = myHome.grid.midLeft
    local x,y = myHome.grid.shape:center()
    local spr = myHome.sprite
    pointList = extractPointsFromPoly(firstPoly)
    love.graphics.polygon("line",pointList)
    love.graphics.circle("line",x,y, myHome.grid.radius)
    love.graphics.circle("fill",x,y, 50)
    love.graphics.draw(spr,screenWidth/2-spr:getWidth(),screenHeight/2-spr:getHeight())
    for i=1,12 do
        for j=1,23 do
            if myHome.grid.m[i][j]==1 then
                love.graphics.polygon("fill",home.getPointFromInd(myHome,i,j))
            end
            if myHome.grid.m[i][j]==2 then
                love.graphics.polygon("fill",home.getPointFromInd(myHome,i,j))
            end
        end
    end
end

return home
