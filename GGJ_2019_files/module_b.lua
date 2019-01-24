module_b = {}

--[[
--We can create a bunch of functions here and add them to the module_b module
--]]


function module_b.hello()
    love.graphics.print('Hello from module b!',200,200)
end

return module_b
