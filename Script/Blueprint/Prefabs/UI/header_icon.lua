---@class header_icon:UUAEUserWidget
local header_icon = {
    PlayerKey = nil,
    Character = nil,
    Size = 100,
}
function header_icon:Construct()
    print("header_icon:Construct")
    self:ShowUI(nil)
end


function header_icon:ShowUI(InCharacter)
    self:SetProfileFrameByAssetPath()
    self:SetWidthAndHeight(self.Size)
    if self.HeadImageType == 0 then--根据PlayerID设置头像
        self.HeadImage:SetVisibility(ESlateVisibility.Collapsed)
        self.Avatar:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        local Character = nil
        if UE.IsValid(InCharacter) then
            Character = InCharacter
        else
            Character = GameplayStatics.GetPlayerController(self, 0):GetPlayerCharacterSafety()
        end
        self.Character = Character
        self:GetPlayerKeyByCharacter(Character)
        self:SetHeadImageByPlayerKey(self.PlayerKey)
    elseif self.HeadImageType == 1 then--根据Asset路径设置头像
        self:SetHeadImageByAssetPath()
        self.HeadImage:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Avatar:SetVisibility(ESlateVisibility.Collapsed)
    end
end
function header_icon:GetPlayerKeyByCharacter(Character)
    local PC = Character:GetPlayerControllerSafety()
    if PC~=nil then
        self.PlayerKey = PC.PlayerKey
    end
end
function header_icon:SetHeadImageByPlayerKey(PlayerKey)
    print("header_icon:SetHeadImageByPlayerKey")
    local PS = UGCGameSystem.GetPlayerStateByPlayerKey(PlayerKey):GetTeamMatePlayerStateFromPlayerKey(PlayerKey)
    local UID = PS:GetInt64UID()
    local IconURL = PS.IconURL
    self.Avatar:InitView(1, UID, IconURL)
end
function header_icon:ResetHeadImagePath(NewPath)
    self.HeadImagePath = NewPath
end
function header_icon:ResetProfileFrameAssetPath(NewPath)
    self.ProfileFrameAssetPath = NewPath
end
--Type=0为PlayerUD,Type=1为Asset路径
function header_icon:ResetHeadImageType(Type)
    self.HeadImageType = Type
end
function header_icon:SetHeadImageByAssetPath()
    FuncUtil.SetImageWithPathAsync(self.HeadImage, self.HeadImagePath)
end
function header_icon:SetProfileFrameByAssetPath()
    FuncUtil.SetImageWithPathAsync(self.ProfileFrameImage, self.ProfileFrameAssetPath)
end
function header_icon:SetWidthAndHeight(Size)
    self.SizeBox_0:SetWidthOverride(Size)
    self.SizeBox_0:SetHeightOverride(Size)
end
return header_icon