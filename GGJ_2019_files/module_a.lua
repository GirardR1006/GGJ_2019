module_a = {}

--[[
--We can create a bunch of functions here and add them to the module_a module
--]]


function module_a.hello()
    love.graphics.print('Hello from module a!',200,200)
end

return module_a
