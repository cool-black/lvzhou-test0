local bomb1 = {}
 
--[[
function bomb1:ReceiveBeginPlay()
    bomb1.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function bomb1:ReceiveTick(DeltaTime)
    bomb1.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function bomb1:ReceiveEndPlay()
    bomb1.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function bomb1:GetReplicatedProperties()
    return
end
--]]

--[[
function bomb1:GetAvailableServerRPCs()
    return
end
--]]

return bomb1