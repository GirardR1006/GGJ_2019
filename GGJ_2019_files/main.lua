--[[
The main file of our game.
A game is a synchronous program, waiting for inputs continuously and returning outputs.
It can be seen as a big loop going on for ever (except if we quit, of course).
In this file, we will load resources and make all the neat calculations.
--]]


--Dofile is to include a lua file and its content
--love.filesystem is a wrapper around this, working on multiple OSes
--WARNING: not actually implemented (yet), this is just an example
local module_a = love.filesystem.load("module_a.lua")
local module_b = love.filesystem.load("module_b.lua")
local HC = require "HC" --Need HadronCollider module to be installed


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
    --warudo = HC.new(150)
    --Load resources
    --WARNING: not implemented (yet)
    --a=module_a.createA()
    --b=module_b.createA()
    --Create tables storing our ingame entites
    entities={}
    --Setting screen
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
	local joysticks = love.joystick.getJoysticks()
	joystick=joysticks[1]
	charPos1 = {x= 300, y=300}
	charPos2 = {x= 500, y=300}
	charSpeed=300
	
end


-- Function to draw stuff on the screen
-- Can vary according to game state
function love.draw()
    if state.level then
        --TODO: fill here with our wonderful game
        love.graphics.print('The game is supposed to be running now', screenWidth/2,screenHeight/2,0,1,1)
		love.graphics.circle("fill",charPos1.x,charPos1.y,20)
		love.graphics.circle("fill",charPos2.x,charPos2.y,20)
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
    --TODO: moving
	xAxis1 = joystick:getAxis(1)
	yAxis1 = joystick:getAxis(2)
	xAxis2 = joystick:getAxis(4)
	yAxis2 = joystick:getAxis(5)
	if math.abs(xAxis1)>0.1 then
		charPos1.x = charPos1.x + xAxis1*charSpeed*dt
	end
	if math.abs(yAxis1)>0.1 then
		charPos1.y = charPos1.y + yAxis1*charSpeed*dt
	end
	if math.abs(xAxis2)>0.1 then
		charPos2.x = charPos2.x + xAxis2*charSpeed*dt
	end
	if math.abs(yAxis2)>0.1 then
		charPos2.y = charPos2.y + yAxis2*charSpeed*dt
	end
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
