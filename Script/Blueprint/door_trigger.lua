---@class door_trigger_C:AActor
---@field Box UBoxComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local door_trigger = {
    bTriggered = false,
}

local function IsPlayerActor(Actor)
    if not UE.IsValid(Actor) then
        return false
    end

    return GetClassName ~= nil and GetClassName(Actor) == "UGCPlayerPawn"
end

local function GetSpawnManager(self)
    local ManagerClass = UE.LoadClass(UGCGameSystem.GetUGCResourcesFullPath("Asset/Blueprint/monster_spawn_manager.monster_spawn_manager_C"))
    if not UE.IsValid(ManagerClass) then
        return nil
    end

    local Managers = GameplayStatics.GetAllActorsOfClass(self, ManagerClass, {})
    if Managers == nil or #Managers == 0 then
        return nil
    end

    return Managers[1]
end

--[[
function door_trigger:ReceiveBeginPlay()
    door_trigger.SuperClass.ReceiveBeginPlay(self)
end
--]]

function door_trigger:ReceiveBeginPlay()
    -- print("self.tags = "..tostring(self.Tags[1]))
	door_trigger.SuperClass.ReceiveBeginPlay(self)
    if UGCGameSystem.IsServer() then
        self:SetReplicates(true) 
        self.Box.OnComponentBeginOverlap:Add(self.HandleOverlap, self)
    end
end

function door_trigger:HandleOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.bTriggered then
        return
    end

    if not IsPlayerActor(OtherActor) then
        return
    end

    local Manager = GetSpawnManager(self)
    if not UE.IsValid(Manager) or Manager.StartSpawnerManager == nil then
        return
    end

    self.bTriggered = true
    Manager:StartSpawnerManager()
end

--[[
function door_trigger:ReceiveTick(DeltaTime)
    door_trigger.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function door_trigger:ReceiveEndPlay()
    door_trigger.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function door_trigger:GetReplicatedProperties()
    return
end
--]]

--[[
function door_trigger:GetAvailableServerRPCs()
    return
end
--]]

return door_trigger
