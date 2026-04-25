---@class UGCGameMode_C:BP_UGCGameBase_C
--Edit Below--
local UGCGameMode = {}; 
function UGCGameMode:ReceiveBeginPlay()
    --仅在服务器运行
    if self:HasAuthority() then 
        print("加载测试方块>>>>>>>>>>>>>>>>>>>>>")
        --根据路径加载类
        -- local Path_Hello = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Attributes/myHelloWorld.myHelloWorld_C')
        local Path_Hello = UGCMapInfoLib.GetRootLongPackagePath().."Asset/Blueprint/Attributes/myHelloWorld.myHelloWorld_C"
        local Class_Hello = UE.LoadClass(Path_Hello)

        --刷出Actor
        local BP_Hello = ScriptGameplayStatics.SpawnActor(self, Class_Hello, 
        {X = 18130, Y = 24620, Z = 160},    --坐标
        {Roll = 0, Pitch = 0, Yaw = 0},     --旋转
        {X = 1, Y = 1, Z = 1})              --缩放
        print("Spawn result:", tostring(BP_Hello))
    end
end
-- function UGCGameMode:ReceiveTick(DeltaTime)

-- end
-- function UGCGameMode:ReceiveEndPlay()
 
-- end
return UGCGameMode;