---@class kill_count_C:UUserWidget
---@field get_bullets_text UTextBlock
---@field kill_count_panel UCanvasPanel
---@field kill_count_text UTextBlock
--Edit Below--
local kill_count = {
    bInitDoOnce = false,
    CurrentCount = 0,
}

local function SetBulletTipVisible(self, isVisible)
    if not UE.IsValid(self.get_bullets_text) then
        return
    end

    if isVisible then
        self.get_bullets_text:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    else
        self.get_bullets_text:SetVisibility(ESlateVisibility.Collapsed)
    end
end

function kill_count:Construct()
    self:set_kill_count(0)
    if UE.IsValid(self.get_bullets_text) then
        self.get_bullets_text:SetText("子弹填充")
    end
    SetBulletTipVisible(self, false)
end
-- function kill_count:Destruct()

-- end

function kill_count:set_kill_count(count)
    local safeCount = count or 0
    self.CurrentCount = safeCount
    self.kill_count_text:SetText(string.format("击杀数：%d", safeCount))
end

function kill_count:show_bullet_tip()
    if UE.IsValid(self.get_bullets_text) then
        self.get_bullets_text:SetText("子弹填充")
    end
    SetBulletTipVisible(self, true)
end

function kill_count:hide_bullet_tip()
    SetBulletTipVisible(self, false)
end

return kill_count
