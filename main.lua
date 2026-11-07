-- ======================================================
-- TOICUTE HUB 🌸 | Blox Fruits Edition (Banana Style Auto Farm)
-- ======================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("[toicute hub] Không thể tải Rayfield UI!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "toicute hub 🌸 | Blox Fruits Pro",
   LoadingTitle = "Đang tải toicute hub...",
   LoadingSubtitle = "by toicute001-netizen",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "toicute_hub_configs",
      FileName = "BananaFarmConfig"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local States = {
    AutoBuso = false,
    AutoObservation = false,
    AutoFarmLevel = false,
    BringMob = false,
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    ESPEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50
}

-- Tạo các Tab
local MainTab = Window:CreateTab("Trang chính", 4483362458)
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local HakiTab = Window:CreateTab("Haki ⚔️", 4483362458)
local ESPTab = Window:CreateTab("ESP & Di chuyển", 4483362340)
local PlayerTab = Window:CreateTab("Nhân vật", 4483362458)
local SettingsTab = Window:CreateTab("Cài đặt", 4483362458)

-- 1. TRANG CHÍNH
MainTab:CreateSection("Thông tin")
MainTab:CreateParagraph({Title = "Người chơi", Content = LocalPlayer.Name})

-- 2. AUTO FARM CHUẨN BANANA HUB
FarmTab:CreateSection("Hệ thống Auto Farm Level")

-- Hàm tự động nhận nhiệm vụ dựa theo Level hiện tại của người chơi
local function getQuestInfo()
    local level = LocalPlayer.Data.Level.Value
    -- Ví dụ sơ đồ cấp độ ở Sea 1 (có thể mở rộng thêm Sea 2, Sea 3)
    if level >= 1 and level <= 9 then
        return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit", CFrame.new(-1141, 15, 1684)
    elseif level >= 10 and level <= 14 then
        return "JungleQuest", 1, CFrame.new(-1598, 36, 153), "Monkey", CFrame.new(-1600, 36, 153)
    elseif level >= 15 and level <= 29 then
        return "JungleQuest", 2, CFrame.new(-1598, 36, 153), "Gorilla", CFrame.new(-1237, 6, -490)
    else
        -- Mặc định nếu vượt cấp cơ bản
        return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit", CFrame.new(-1141, 15, 1684)
    end
end

FarmTab:CreateToggle({
   Name = "Bật Auto Farm Level (Tự động nhận Quest & Đánh)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       States.AutoFarmLevel = Value
       if Value then
           task.spawn(function()
               while States.AutoFarmLevel do
                   pcall(function()
                       local char = LocalPlayer.Character
                       if char and char:FindFirstChild("HumanoidRootPart") then
                           local hrp = char.HumanoidRootPart
                           local questTitle, questIndex, npcPos, mobName, mobPos = getQuestInfo()
                           
                           -- Kiểm tra nếu chưa có nhiệm vụ thì chạy đi nhận
                           local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
                           if not questGui or not questGui.Visible then
                               hrp.CFrame = npcPos
                               task.wait(0.5)
                               ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questTitle, questIndex)
                               task.wait(0.5)
                           else
                               -- Đã có nhiệm vụ, di chuyển tới chỗ quái
                               hrp.CFrame = mobPos + Vector3.new(0, 10, 0)
                               
                               -- Tự động đánh quái gần nhất
                               for _, v in pairs(workspace.Enemies:GetChildren()) do
                                   if v.Name == mobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid").Health > 0 then
                                       repeat
                                           task.wait()
                                           hrp.CFrame = v
