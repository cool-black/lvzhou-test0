---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
local UGCGameState = {
    KillCountWidget = nil,
};

local function GetLocalPlayerKillCount(self)
    local PlayerController = GameplayStatics.GetPlayerController(self, 0)
    if not UE.IsValid(PlayerController) then
        return 0
    end

    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(PlayerController)
    if not UE.IsValid(PlayerPawn) then
        return 0
    end

    return PlayerPawn.KillCount or 0
end

function UGCGameState:ReceiveBeginPlay()
    self.SuperClass.ReceiveBeginPlay(self)

    if self:HasAuthority() == true then
        return
    end

    print("客户端gamestate初始化....")
    local kill_count_ui = UE.LoadClass(UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/UI/kill_count.kill_count_C'))
    print("加载kill count UI..")
    if not UE.IsValid(kill_count_ui) then
        return
    end

    local PlayerController = GameplayStatics.GetPlayerController(self, 0)
    print("Get Player Controller")
    if not UE.IsValid(PlayerController) then
        return
    end

    local bp_kill_count_ui = UserWidget.NewWidgetObjectBP(PlayerController, kill_count_ui)
    print("Load bp_kill_count_ui")
    if not UE.IsValid(bp_kill_count_ui) then
        return
    end

    bp_kill_count_ui:AddToViewport()
    self.KillCountWidget = bp_kill_count_ui
    self:RefreshKillCountUI(GetLocalPlayerKillCount(self))
    print("bp_kill_count_ui AddToViewport")
    -- 将 bp_kill_count_ui 加入视口，显示UI
end

function UGCGameState:RefreshKillCountUI(killCount)
    if self:HasAuthority() then
        return
    end

    if UE.IsValid(self.KillCountWidget) then
        self.KillCountWidget:set_kill_count(killCount or 0)
    end
end

function UGCGameState:ShowBulletTip()
    if self:HasAuthority() then
        return
    end

    if UE.IsValid(self.KillCountWidget) and self.KillCountWidget.show_bullet_tip ~= nil then
        self.KillCountWidget:show_bullet_tip()
    end
end

function UGCGameState:HideBulletTip()
    if self:HasAuthority() then
        return
    end

    if UE.IsValid(self.KillCountWidget) and self.KillCountWidget.hide_bullet_tip ~= nil then
        self.KillCountWidget:hide_bullet_tip()
    end
end
-- function UGCGameState:ReceiveTick(DeltaTime)

-- end
-- function UGCGameState:ReceiveEndPlay()
 
-- end
return UGCGameState;
