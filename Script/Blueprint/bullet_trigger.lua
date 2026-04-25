---@class bullet_trigger_C:AActor
---@field Box UBoxComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local bullet_trigger = {
    LocalPlayerInside = false,
}

local BULLET_ID = "8310000"
local BULLET_COUNT = 140

local function IsPlayerActor(Actor)
    if not UE.IsValid(Actor) then
        return false
    end

    return GetClassName ~= nil and GetClassName(Actor) == "UGCPlayerPawn"
end

local function IsLocalPlayerActor(self, Actor)
    if not IsPlayerActor(Actor) then
        return false
    end

    local LocalPlayerController = GameplayStatics.GetPlayerController(self, 0)
    if not UE.IsValid(LocalPlayerController) then
        return false
    end

    local LocalPlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(LocalPlayerController)
    if not UE.IsValid(LocalPlayerPawn) then
        return false
    end

    return LocalPlayerPawn == Actor
end

local function GetGameState(self)
    local GameState = GameplayStatics.GetGameState(self)
    if not UE.IsValid(GameState) then
        return nil
    end

    return GameState
end

local function AddBulletToPlayer(PlayerPawn)
    if not UGCGameSystem.IsServer() then
        return
    end

    if not IsPlayerActor(PlayerPawn) then
        return
    end

    local PlayerController = PlayerPawn:GetPlayerControllerSafety()
    if not UE.IsValid(PlayerController) then
        return
    end

    local ItemIDs = { [1] = BULLET_ID }
    local ItemCounts = { [1] = BULLET_COUNT }
    UGCBlueprintFunctionLibrary.AddItemForPlayer(PlayerController, ItemIDs, ItemCounts)
    ugcprint("子弹添加成功")
end

--[[
function bullet_trigger:ReceiveBeginPlay()
    bullet_trigger.SuperClass.ReceiveBeginPlay(self)
end
--]]

function bullet_trigger:ReceiveBeginPlay()
    -- print("self.tags = "..tostring(self.Tags[1]))
	bullet_trigger.SuperClass.ReceiveBeginPlay(self)
    if UE.IsValid(self.Box) then
        self.Box.OnComponentBeginOverlap:Add(self.HandleOverlap, self)
        self.Box.OnComponentEndOverlap:Add(self.HandleEndOverlap, self)
    end
end

function bullet_trigger:HandleOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if UGCGameSystem.IsServer() then
        AddBulletToPlayer(OtherActor)
    end

    if self.LocalPlayerInside then
        return
    end

    if not IsLocalPlayerActor(self, OtherActor) then
        return
    end

    local GameState = GetGameState(self)
    if GameState == nil or GameState.ShowBulletTip == nil then
        return
    end

    self.LocalPlayerInside = true
    GameState:ShowBulletTip()
end

function bullet_trigger:HandleEndOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not self.LocalPlayerInside then
        return
    end

    if not IsLocalPlayerActor(self, OtherActor) then
        return
    end

    local GameState = GetGameState(self)
    if GameState == nil or GameState.HideBulletTip == nil then
        return
    end

    self.LocalPlayerInside = false
    GameState:HideBulletTip()
end

--[[
function bullet_trigger:ReceiveTick(DeltaTime)
    bullet_trigger.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function bullet_trigger:ReceiveEndPlay()
    bullet_trigger.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function bullet_trigger:GetReplicatedProperties()
    return
end
--]]

--[[
function bullet_trigger:GetAvailableServerRPCs()
    return
end
--]]

return bullet_trigger
