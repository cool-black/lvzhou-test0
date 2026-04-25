local UGCPlayerPawn = {
    KillCount = 0,
}

local function RefreshLocalKillCountUI(self)
    local LocalPlayerController = GameplayStatics.GetPlayerController(self, 0)
    if not UE.IsValid(LocalPlayerController) then
        return
    end

    local SelfController = self:GetPlayerControllerSafety()
    if not UE.IsValid(SelfController) then
        return
    end

    if LocalPlayerController ~= SelfController then
        return
    end

    local GameState = GameplayStatics.GetGameState(self)
    if UE.IsValid(GameState) and GameState.RefreshKillCountUI ~= nil then
        GameState:RefreshKillCountUI(self.KillCount or 0)
    end
end
 
--[[
function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function UGCPlayerPawn:ReceiveEndPlay()
    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function UGCPlayerPawn:GetAvailableServerRPCs()
    return
end
--]]

function UGCPlayerPawn:GetReplicatedProperties()
    return {"KillCount", "__SubObjectRepList", "Lazy"}
end

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)

    if self:HasAuthority() then
        self.KillCount = self.KillCount or 0
        return
    end

    RefreshLocalKillCountUI(self)
end

function UGCPlayerPawn:AddKillCount(delta)
    if not self:HasAuthority() then
        return
    end

    local addValue = delta or 1
    self.KillCount = (self.KillCount or 0) + addValue
end

function UGCPlayerPawn:OnRep_KillCount()
    RefreshLocalKillCountUI(self)
end

return UGCPlayerPawn
