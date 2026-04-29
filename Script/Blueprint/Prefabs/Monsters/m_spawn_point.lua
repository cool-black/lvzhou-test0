---@class m_spawn_point_C:BP_UGCMobSpawner_C
--Edit Below--
local m_spawn_point = {
    bEnableInfiniteRespawn = true,
    bDebugInfiniteRespawn = false,
    SpawnCountBudget = 3,
}

local function DebugLog(self, Msg)
    if self.bDebugInfiniteRespawn then
        print(string.format(
            "[m_spawn_point][%s] %s | Min=%s Max=%s Budget=%s Remaining=%s Supplemented=%s Alive=%s",
            tostring(self),
            Msg,
            tostring(self.MinSpawnCount),
            tostring(self.MaxSpawnCount),
            tostring(self.SpawnCountBudget),
            tostring(self.RemainingSpawnCount),
            tostring(self.SupplementedCount),
            tostring(self.MaxAliveCount)
        ))
    end
end
 
--[[
function m_spawn_point:ReceiveBeginPlay()
    m_spawn_point.SuperClass.ReceiveBeginPlay(self)
end
--]]

function m_spawn_point:ReceiveBeginPlay()
    if not self:HasAuthority() then
        m_spawn_point.SuperClass.ReceiveBeginPlay(self)
        return
    end

    self.bUseNavMesh = false
    self.Range = 0
    self.Height = math.max(tonumber(self.Height) or 0, 100)

    self.SpawnCountBudget = math.max(
        tonumber(self.SpawnCountBudget) or 1,
        tonumber(self.MaxSpawnCount) or 1,
        3
    )
    self:ModifyMinMaxSpawnCount(1, self.SpawnCountBudget)
    DebugLog(self, "After initial ModifyMinMaxSpawnCount")

    DebugLog(self, "Before Super ReceiveBeginPlay")
    m_spawn_point.SuperClass.ReceiveBeginPlay(self)
    DebugLog(self, "After Super ReceiveBeginPlay")
end

function m_spawn_point:OnMobSpawn(MobPawn)
    DebugLog(self, "OnMobSpawn Mob=" .. tostring(MobPawn))
end

--[[
function m_spawn_point:CustomSpawnMob(InCustomParam)
    
end
--]]


return m_spawn_point
