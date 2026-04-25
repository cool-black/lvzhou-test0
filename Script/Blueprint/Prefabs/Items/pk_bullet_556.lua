---@class pk_bullet_556_C:UGCPickupWrapper_BP_C
--Edit Below--
local pk_bullet_556 = {}
 
--[[
function pk_bullet_556:ReceiveBeginPlay()
    pk_bullet_556.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function pk_bullet_556:ReceiveTick(DeltaTime)
    pk_bullet_556.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function pk_bullet_556:ReceiveEndPlay()
    pk_bullet_556.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function pk_bullet_556:GetReplicatedProperties()
    return
end
--]]

--[[
function pk_bullet_556:GetAvailableServerRPCs()
    return
end
--]]

return pk_bullet_556