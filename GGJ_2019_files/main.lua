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

-- First function to be loaded, load resources and initialize basic objects here
function love.load()
    --Create a collider table, storing all objects and doing all the calculations for us
    warudo = HC.new(150)
    --Setting screen
    screenWidth = 1024 --love.graphics.getWidth()
    screenHeight = 768 --love.graphics.getHeight()
    --Setting joystick and players
    player1 = player.create(warudo)
    player2 = player.create(warudo)
    local joysticks = love.joystick.getJoysticks()
    joystick=joysticks[1]	
    player1.xAxisIndex = 1
    player1.yAxisIndex = 2
    player2.xAxisIndex = 4
    player2.yAxisIndex = 5
    --Setting grid
    triangleWidth = 30
    ourHome = Home.create(warudo,triangleWidth)
	
end


-- Function to draw stuff on the screen
-- Can vary according to game state
function love.draw()
    if state.level then
        love.graphics.print('The game is supposed to be running now', screenWidth/2,screenHeight/2,0,1,1)
	player.draw(player1)
        player.draw(player2)
        home.draw(ourHome)
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
end

-- Function doing all the collision management
-- Basically, do some calculation to constrain or modify movement and report
-- effects of collision on the world
function manageCollision()
    --TODO: collision management 
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
        move(dt)
    end
    love.draw()
end
