---@class test_m4_C:BP_UGC_Rifle_M416_C
--Edit Below--
local test_m4 = {}
 
--[[
function test_m4:ReceiveBeginPlay()
    test_m4.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function test_m4:ReceiveTick(DeltaTime)
    test_m4.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function test_m4:ReceiveEndPlay()
    test_m4.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function test_m4:GetReplicatedProperties()
    return
end
--]]

--[[
function test_m4:GetAvailableServerRPCs()
    return
end
--]]

return test_m4