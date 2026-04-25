---@class myHelloWorld_C:AActor
---@field Cube UStaticMeshComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local myHelloWorld = {}
 
--[[
function myHelloWorld:ReceiveBeginPlay()
    --myHelloWorld.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function myHelloWorld:ReceiveTick(DeltaTime)
    myHelloWorld.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function myHelloWorld:ReceiveEndPlay()
    myHelloWorld.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function myHelloWorld:GetReplicatedProperties()
    return
end
--]]

--[[
function myHelloWorld:GetAvailableServerRPCs()
    return
end
--]]

return myHelloWorld