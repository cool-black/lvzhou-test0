local test_ui = 
{
    bInitDoOnce = false,

}

function test_ui:Construct()
    self:LuaInit()
end

function test_ui:LuaInit()
    print("[TeachingTips] Start LuaInit")
    if self.bInitDoOnce then
        return
    end
    self.bInitDoOnce = true

    local SaveGameKey = self:GetSaveGameKey()
    local bHideTips = SaveGameMgr:GetPlayerBoolean(SGDefine.UGCGame, SaveGameKey)
    if bHideTips then
        self:SetVisibility(ESlateVisibility.Collapsed)
        return
    else
        self.CheckBox_select:SetCheckedState(ECheckBoxState.Unchecked)
        self.CheckBox_select.OnCheckStateChanged:Add(self.OnCheckBoxChanged, self)
    end

    self.CurPage = 1
    print(string.format("[TeachingTips] Initial CurPage = %d", self.CurPage))

    self.UGC_ReuseList2_TeachingPoint.OnAfterNewItem:Add(self.UGC_ReuseList2_TeachingPoint_OnAfterNewItem, self)
    self.Button_left.OnClicked:Add(self.Button_left_OnClicked, self)
    self.Button_right.OnClicked:Add(self.Button_right_OnClicked, self)
    self.Button_close.OnClicked:Add(self.Button_close_OnClicked, self)

    local ImageCount = #self.Images
    print(string.format("[TeachingTips] Loading %d images", ImageCount))
    self.UGC_ReuseList2_TeachingPoint:Reload(ImageCount)

    self:UpdatePage()
    -- self:UpdateTurningButton()  -- 确保初始化时更新按钮状态
end

function test_ui:UpdateTurningButton()
    local totalPages = #self.Images
    print(string.format("[TeachingTips] UpdateTurningButton - CurPage:%d/%d", self.CurPage, totalPages))

    self.Button_left:SetVisibility(
        self.CurPage > 1 and ESlateVisibility.Visible 
        or ESlateVisibility.Collapsed
    )

    self.Button_right:SetVisibility(
        self.CurPage < totalPages and ESlateVisibility.Visible 
        or ESlateVisibility.Collapsed
    )
end

function test_ui:UpdatePage()
    print(string.format("[TeachingTips] UpdatePage to %d", self.CurPage))
    self.Text_title_guide:SetText(self.BigTitle)
    self.TextBlock_ModelTitle:SetText(self.SmallTitles[self.CurPage])
    self.TextBlock_RulesDetails:SetText(self.ContentText[self.CurPage])
    self.Image_Teaching:SetBrushFromTexture(self.Images[self.CurPage])
    self.UGC_ReuseList2_TeachingPoint:Reload(#self.Images)
end

function test_ui:Button_left_OnClicked()
    print("[TeachingTips] Left button clicked")
    if self.CurPage > 1 then
        self.CurPage = self.CurPage - 1
        self:UpdatePage()
        self:UpdateTurningButton()
    end
end

function test_ui:Button_right_OnClicked()
    print("[TeachingTips] Right button clicked")
    local totalPages = #self.Images
    if self.CurPage < totalPages then
        self.CurPage = self.CurPage + 1
        self:UpdatePage()
        self:UpdateTurningButton()
    end
end

function test_ui:Button_close_OnClicked()
    -- 通过 UserWidgetLayout 添加的控件使用 SetVisibility 隐藏
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function test_ui:UGC_ReuseList2_TeachingPoint_OnAfterNewItem(Widget, Idx)
    Idx = Idx + 1
    print(string.format("[TeachingTips] Created page point %d", Idx))

    Widget.WidgetSwitcher_PagePoint:SetActiveWidgetIndex(0)

    if Idx == self.CurPage then
        Widget.WidgetSwitcher_PagePoint:SetActiveWidgetIndex(1)
    end
end

function test_ui:OnCheckBoxChanged(bChecked)
    print_dev(string.format("[TeachingTips] CheckBox changed to %s", bChecked and "true" or "false"))
    local SaveGameKey = self:GetSaveGameKey()
    SaveGameMgr:SetPlayerBoolean(SGDefine.UGCGame, SaveGameKey, bChecked)
end

function test_ui:GetSaveGameKey()
    local function StringToHash(str)
        local hash = 5381
        for i = 1, #str do
            hash = ((hash * 33) + string.byte(str, i)) % (2 ^ 32)
        end
        return string.format("%x", hash)
    end

    local SafeKey = StringToHash(self.BigTitle)

    print_dev(string.format("[TeachingTips] GetSaveGameKey: %s_%s", UGCMapInfoLib.GetMountID(), SafeKey))
    return string.format("%s_%s_%s", UGCMapInfoLib.GetMountID(), SafeKey, "ShowTeachingTips")
end

return test_ui