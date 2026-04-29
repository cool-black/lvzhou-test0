---@class myHelloWorld_C:AActor
---@field Cube UStaticMeshComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local Cube = {}
 
--[[
function Cube:ReceiveBeginPlay()
    --Cube.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Cube:ReceiveTick(DeltaTime)
    Cube.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Cube:ReceiveEndPlay()
    Cube.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Cube:GetReplicatedProperties()
    return
end
--]]

--[[
function Cube:GetAvailableServerRPCs()
    return
end
--]]

return Cube