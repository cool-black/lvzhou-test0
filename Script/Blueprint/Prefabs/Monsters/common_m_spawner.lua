---@class common_m_spawner_C:BP_UGCMobSpawner_C
--Edit Below--
local common_m_spawner = {
    -- Change this value to configure the max total spawn count.
    ConfigMaxSpawnCount = 20,
}

local function ApplySpawnCountConfig(self)
    local MaxSpawnCount = math.max(tonumber(self.ConfigMaxSpawnCount) or 1, 1)
    local MinSpawnCount = math.min(tonumber(self.MinSpawnCount) or 1, MaxSpawnCount)

    self.MaxSpawnCount = MaxSpawnCount
    self.MinSpawnCount = MinSpawnCount

    self:ModifyMinMaxSpawnCount(MaxSpawnCount, MaxSpawnCount)
end

-- local function BindMobDestroyed(self, MobPawn)
--     if MobPawn == nil or MobPawn.OnDestroyed == nil then
--         return
--     end

--     MobPawn.OnDestroyed:Add(self.OnSpawnedMobDestroyed, self)
-- end
 
--[[
function common_m_spawner:ReceiveBeginPlay()
    common_m_spawner.SuperClass.ReceiveBeginPlay(self)
end
--]]

function common_m_spawner:ReceiveBeginPlay()
    if self:HasAuthority() then
        ApplySpawnCountConfig(self)
    end

    common_m_spawner.SuperClass.ReceiveBeginPlay(self)
end

-- function common_m_spawner:OnMobSpawn(MobPawn)
--     if not self:HasAuthority() then
--         return
--     end

--     BindMobDestroyed(self, MobPawn)
-- end

-- function common_m_spawner:OnSpawnedMobDestroyed(DestroyedActor)
--     if not self:HasAuthority() then
--         return
--     end

--     self.ConfigMaxSpawnCount = math.max(tonumber(self.ConfigMaxSpawnCount) or 1, 1) + 1
--     ApplySpawnCountConfig(self)
-- end

--[[
function common_m_spawner:CustomSpawnMob(InCustomParam)
    
end
--]]


return common_m_spawner
