--[[
The main file of our game.
A game is a synchronous program, waiting for inputs continuously and returning outputs.
It can be seen as a big loop going on for ever (except if we quit, of course).
In this file, we will load resources and make all the neat calculations.
--]]


--Dofile is to include a lua file and its content
--love.filesystem is a wrapper around this, working on multiple OSes
--WARNING: not actually implemented (yet), this is just an example
local player = love.filesystem.load("player.lua")
local player = player()
local block = love.filesystem.load("block.lua")
local block = block()
HC = require "HC" --Need HadronCollider module to be installed
--shapes = require "HC.shapes"
--polygon = require "HC.polygon"

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

--A broadcast table storing several informations to be used by differents components of 
--the program. For instance, we can communicate the position of the player to other entities
--Put any properties we want here, and don't forget to update the table when they change!
local broadcast={} 

-- First function to be loaded, load resources and initialize basic objects here
function love.load()
    --Create a collider table, storing all objects and doing all the calculations for us
    warudo = HC.new(150)
    --Load resources
    --WARNING: not implemented (yet)
    --a=module_a.createA()
    --b=module_b.createA()
    --Create tables storing our ingame entites
    entities={}
    --Setting screen
    screenWidth = 1024--love.graphics.getWidth()
    screenHeight = 768--love.graphics.getHeight()
    local joysticks = love.joystick.getJoysticks()
    joystick=joysticks[1]
	
    player1 = player.create(warudo)
    player1.xAxisIndex = 1
    player1.yAxisIndex = 2
    player1.grabIndex = 3
    player2 = player.create(warudo)
    player2.xAxisIndex = 4
    player2.yAxisIndex = 5
    player2.grabIndex = 6

    block1 = block.create(warudo)
    blocks = {block1}
	
end


-- Function to draw stuff on the screen
-- Can vary according to game state
function love.draw()
    if state.level then
        --TODO: fill here with our wonderful game
        love.graphics.print('The game is supposed to be running now', screenWidth/2,screenHeight/2,0,1,1)
		player.draw(player1)
        player.draw(player2)
        block.draw(block1)
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
    --Update broadcast
    --State transitions
    function love.gamepadpressed(joystick,button)
        pressed=joystick:getAxis(3)
        print(pressed)
    end
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
        player.updateGrab(player1)
        player.updateGrab(player2)
        manageCollision()
        move(dt)
        for i,entity in pairs(blocks) do
            block.release(entity)
        end
        --print(block1.isGrabbed)
        --print(player1.grabbing)
    end
    love.draw()
end
