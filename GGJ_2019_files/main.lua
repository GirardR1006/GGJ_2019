--[[
The main file of our game.
A game is a synchronous program, waiting for inputs continuously and returning outputs.
It can be seen as a big loop going on for ever (except if we quit, of course).
In this file, we will load resources and make all the neat calculations.
--]]


--Dofile is to include a lua file and its content
--love.filesystem is a wrapper around this, working on multiple OSes
local player = love.filesystem.load("player.lua")
local player = player()
local Home = love.filesystem.load("home.lua")
local Home = Home()
local HC = require "HC" --Need HadronCollider module to be installed
Polygon = require "HC.polygon"
local block = love.filesystem.load("block.lua")
local block = block()
local balance = love.filesystem.load("balance.lua")
local balance = balance()

--[[
#####################
Functions definitions
#####################
--]]

--Store the states of the game. Behaviour of the whole game will change accordingly to state.
--Can be anything like pause, dialog, menu, etc.
local state = {}
state.mainMenu=true
state.level=false
state.dialog=false
state.pause=false
state.intro=false

--Colours
local colours = {}
colours.blue = false
colours.yellow = false

-- First function to be loaded, load resources and initialize basic objects here
function love.load()
    --Create a collider table, storing all objects and doing all the calculations for us
    warudo = HC.new(150)
    --Setting screen dimension
    screenWidth = 1024 --love.graphics.getWidth()
    screenHeight = 768 --love.graphics.getHeight()
    love.window.setMode(screenWidth,screenHeight)
    --Setting joystick and players
    local joysticks = love.joystick.getJoysticks()
    joystick=joysticks[1]
    player1 = player.create(warudo,1)
    player2 = player.create(warudo,2)
    player1.xAxisIndex = 1
    player1.yAxisIndex = 2
    player1.grabIndex = 3
    player2.xAxisIndex = 4
    player2.yAxisIndex = 5
    player2.grabIndex = 6
    color1 = {223/255,65/255,195/255,1}
    color2 = {65/255,223/255,140/255,1}
    colorHome1 = {223/255,65/255,195/255,0.5}
    colorHome2 = {65/255,223/255,140/255,0.5}
    --Loading background, static images
    background = love.graphics.newImage("graphisme/fonds-home/fond-rose.png")
    homeSprite = love.graphics.newImage("graphisme/fonds-home/home-rose.png")
    gridSprite = love.graphics.newImage("graphisme/fonds-home/grille-rose.png")
    mainMenuScreen =  love.graphics.newImage("graphisme/animation/mainMenuScreen.png")
    --Setting grid
    triangleWidth = 30
    ourHome = Home.create(warudo,triangleWidth)
    --Setting balance
    ourBalance = balance.create()
    --Setting blocks
    --block1 = block.create(warudo,7,2,100,100)
    --block2 = block.create(warudo,4,1,300,100)
    --block3 = block.create(warudo,1,2,100,300)
    --block4 = block.create(warudo,1,2,200,200)
    --blocks = {block1,block2,block3}
    blocks = {}
    --for i=1,4 do
        --table.insert(blocks,block.create(warudo,2+i,2,100*i,400))        
        --table.insert(blocks,block.create(warudo,1,2,200+20*i,200))
    --end
    
    blockRainSpeed = 100
    blockSpawnX1 = (screenWidth-30*12)/4
    blockSpawnY1 = -150
    blockSpawnX2 = screenWidth-blockSpawnX1
    blockSpawnY2 = -150
    blockTimer = 0.5
    blockTimerMax = 1
    


    --Setting audio	
    musicTrack = love.audio.newSource("audio/musique/Tandem2.wav", "stream")
    musicTrack:setLooping(true)
    happySound = love.audio.newSource("audio/Bruitages/content3.wav","static")
    sadSound = love.audio.newSource("audio/Bruitages/stress2.wav","static")
    grabSound = love.audio.newSource("audio/Bruitages/grab.wav","static")
    releaseSound = love.audio.newSource("audio/Bruitages/release.wav", "static")
    tchakSound = love.audio.newSource("audio/Bruitages/accroche.wav", "static")
    --Setting video
    intro = love.graphics.newVideo("graphisme/animation/video_intro/output.ogv")
    lucioles = love.graphics.newVideo("graphisme/animation/lucioles.ogv")
    --State intro
    state.mainMenu = true
end


-- Function to draw stuff on the screen
-- Can vary according to game state
function love.draw()
    if state.level then
        love.graphics.draw(lucioles)
        love.graphics.setBackgroundColor(255,255,255)
        love.graphics.draw(background)
	    player.draw(player1)
        player.draw(player2)
        home.draw(ourHome)
        for i,entity in pairs(blocks) do
            block.draw(entity)
        end
        balance.draw(ourBalance)
    elseif state.intro then
        --love.graphics.draw(intro)
    elseif state.mainMenu then
        love.graphics.draw(mainMenuScreen)
        --love.graphics.print('Welcome, press a trigger to begin', screenWidth/2,screenHeight/2,0,1,1)
    end

end

-- Function doing all the moving
-- dt is an interval automatically computed by love2d, move will be called at each dt 
-- dt is usually 0.1s on a i3 2012 laptop
function move(dt)
    player.move(player1, dt, joystick)
    player.move(player2, dt, joystick)
    for bite,entity in pairs(blocks) do
        block.move(entity,bite,dt)
    end
end

-- Function doing all the collision management
-- Basically, do some calculation to constrain or modify movement and report
-- effects of collision on the world
function manageCollision()
    for i,entity in pairs(blocks) do
        --collisions block to block
        for j,entity2 in pairs(blocks) do
            if not (i==j) then
                test = entity.shape
                test2 = entity2.shape
                local collides,dx,dy = entity.shape:collidesWith(entity2.shape)         
                if collides then 
                    entity.shape:move(dx/2,dy/2)
                end
            end
        end

        --collisions to players
        local collides,dx,dy = entity.shape:collidesWith(player1.shape)
        if collides then
            entity.shape:move(dx/2,dy/2)
        end
        local collides,dx,dy = entity.shape:collidesWith(player2.shape)
        if collides then
            entity.shape:move(dx/2,dy/2)
        end
        --collisions to grabboxes
        local collides,dx,dy = entity.shape:collidesWith(player1.grabShape)
        if collides then
            if player1.grabbing then
                entity.isGrabbed = 1
            end
        end
        local collides,dx,dy = entity.shape:collidesWith(player2.grabShape)
        if collides then
            if player2.grabbing then
                entity.isGrabbed = 2
            end
        end
        
    end
    
    --collisions between players
    local collides,dx,dy = player1.shape:collidesWith(player2.shape) 
    if collides then
        player1.shape:move(dx/2,dy/2)
        player2.shape:move(-dx/2,-dy/2)
    end
end

function spawnBlocks(dt)
    blockTimer = blockTimer + dt
    if blockTimer > blockTimerMax then
        rdColor1 = math.random(1,2)
        rdShape1 = math.random(1,11)
        rdColor2 = math.random(1,2)
        rdShape2 = math.random(1,11)
        rdX1 = math.random(-80,80)
        rdX2 = math.random(-80,80)
        table.insert(blocks,block.create(warudo,rdShape1,rdColor1,blockSpawnX1+rdX1,blockSpawnY1))        
        table.insert(blocks,block.create(warudo,rdShape2,rdColor2,blockSpawnX2+rdX2,blockSpawnY2))        
        blockTimer = 0
    end
end

--[[
#######################
Game actually runs here
#######################
--]]

------------------------------------
------- UPDATE called each dt ------
------------------------------------
function love.update(dt)
    spawnBlocks(dt)
    player.updateGrab(player1)
    player.updateGrab(player2)
    if player1.grabbing and player2.grabbing and state.mainMenu then
        print("Transitioning from Main Menu to Level")
        state.mainMenu=false
        state.level=true
    end
    if state.level then
        manageCollision()
        move(dt)		
        player.updateAnimation(player1,dt)
        player.updateAnimation(player2,dt)
        --xtemp,ytemp = player1.shape:center()
        --print(Home.whereOnGrid(ourHome,xtemp,ytemp))
        musicTrack:play()
	    player.updateEmotion(player1, dt)
	    player.updateEmotion(player2, dt)
        lucioles:play()
        for i,entity in pairs(blocks) do
            removed = block.release(entity,ourHome,i)
            if removed then
                --Update balance score regarding to the grid
                local grid = ourHome.grid.m
                balance.computeEquilibrium(ourBalance,grid)
            end
        end
    love.draw()    
    end
    if state.intro then
        intro:play()
        if not(intro:isPlaying()) then
            state.intro=false
            state.mainMenu=true
        end
    end
end
