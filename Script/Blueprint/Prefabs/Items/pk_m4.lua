local pk_m4 = {}
 
--[[
function pk_m4:ReceiveBeginPlay()
    pk_m4.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function pk_m4:ReceiveTick(DeltaTime)
    pk_m4.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function pk_m4:ReceiveEndPlay()
    pk_m4.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function pk_m4:GetReplicatedProperties()
    return
end
--]]

--[[
function pk_m4:GetAvailableServerRPCs()
    return
end
--]]

return pk_m4