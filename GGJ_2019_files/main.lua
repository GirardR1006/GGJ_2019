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
    --Setting joystick and players
    local joysticks = love.joystick.getJoysticks()
    joystick=joysticks[1]
    player1 = player.create(warudo)
    player2 = player.create(warudo)
    local joysticks = love.joystick.getJoysticks()
    joystick=joysticks[1]	
    player1.xAxisIndex = 1
    player1.yAxisIndex = 2
    player1.grabIndex = 3
    player2 = player.create(warudo)
    player2.xAxisIndex = 4
    player2.yAxisIndex = 5
    player2.grabIndex = 6 
    --Loading background
    background = love.graphics.newImage("graphisme/fonds-home/fond-rose.png")
    homeSprite = love.graphics.newImage("graphisme/fonds-home/home-rose.png")
    --Setting grid
    triangleWidth = 30
    ourHome = Home.create(warudo,triangleWidth)
    --Setting blocks
    block1 = block.create(warudo)
    blocks = {block1}
    --Setting audio	
    musicTrack = love.audio.newSource("audio/musique/Tandem2.wav", "stream")
	musicTrack:setLooping(true)
    happySound = love.audio.newSource("audio/Bruitages/content3.wav","static")
    sadSound = love.audio.newSource("audio/Bruitages/stress2.wav","static")
    grabSound = love.audio.newSource("audio/Bruitages/grab.wav","static")
    releaseSound = love.audio.newSource("audio/Bruitages/release.wav", "static")
    tchakSound = love.audio.newSource("audio/Bruitages/accroche.wav", "static")
end


-- Function to draw stuff on the screen
-- Can vary according to game state
function love.draw()
    if state.level then
        love.graphics.setBackgroundColor(255,255,255)
	player.draw(player1)
        player.draw(player2)
        home.draw(ourHome)
        for i,entity in pairs(blocks) do
            block.draw(entity)
        end
        love.graphics.draw(background)
    elseif state.pause then
        love.graphics.print('Game paused, press p button to unpause', screenWidth/2,screenHeight/2,0,1,1)
    elseif state.mainMenu then
        love.graphics.print('Welcome, press button x to begin', screenWidth/2,screenHeight/2,0,1,1)
    end
end

-- Function doing all the moving
-- dt is an interval automatically computed by love2d, move will be called at each dt 
-- dt is usually 0.1s on a i3 2012 laptop
function move(dt)
    player.move(player1, dt, joystick)
    player.move(player2, dt, joystick)
    block.move(block1)
end

-- Function doing all the collision management
-- Basically, do some calculation to constrain or modify movement and report
-- effects of collision on the world
function manageCollision()
    for i,entity in pairs(blocks) do
        --collisions block to block
        for j,entity2 in pairs(blocks) do
            if not i==j then
                local collides,dx,dy = entity.shape:collidesWith(entity2.shape) 
                entity.shape:move(dx/2,dy/2)
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


--[[
#######################
Game actually runs here
#######################
--]]

------------------------------------
------- UPDATE called each dt ------
------------------------------------
function love.update(dt)
    function love.keypressed(key)
        if key=='p' then
            if state.pause then
                print("Transitioning from Pause to Level")
                state.pause=false
                state.level=true
            elseif state.level then
                print("Transitioning from Level to Pause")
                state.pause=true
                state.level=false
            end
        end
    end
    if love.keyboard.isDown('x') and state.mainMenu then
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
        player.updateGrab(player1)
        player.updateGrab(player2)
	player.updateEmotion(player1, dt)
	player.updateEmotion(player2, dt)
        for i,entity in pairs(blocks) do
            block.release(entity,ourHome,i)
        end
    end
    love.draw()
end
