-- ======================================================
-- TOICUTE HUB 🌸 | Blox Fruits (Compact & Optimized)
-- ======================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
   Name = "toicute hub 🌸 | Blox Fruits",
   LoadingTitle = "Đang tải toicute hub...",
   ConfigurationSaving = { Enabled = true, FolderName = "toicute_hub", FileName = "Config" },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local States = {
    AutoBuso = false,
    AutoFarm = false,
    BringMob = false,
    AutoAttack = true,
    Fly = false,
    FlySpeed = 50
}

-- 1. Auto Clicker (Đánh thường 0.5s/đấm)
task.spawn(function()
    while true do
        if States.AutoAttack then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if tool and tool.Parent ~= char then tool.Parent = char end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(500, 500))
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Tạo các Tab
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)
local HakiTab = Window:CreateTab("Haki ⚔️", 4483362458)
local ESPTab = Window:CreateTab("ESP & Bay", 4483362340)
local PlayerTab = Window:CreateTab("Nhân vật", 4483362458)

-- Hàm Tween bay mượt
local function smoothTween(cf)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - cf.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 350, Enum.EasingStyle.Linear), {CFrame = cf})
    tween:Play()
end

-- Cấu hình Quest Sea 1 cơ bản
local function getQuest()
    local lv = LocalPlayer.Data.Level.Value
    if lv <= 9 then return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit"
    elseif lv <= 14 then return "JungleQuest", 1, CFrame.new(-1598, 36, 153), "Monkey"
    elseif lv <= 29 then return "JungleQuest", 2, CFrame.new(-1598, 36, 153), "Gorilla"
    else return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit" end
end

-- Tab Auto Farm
FarmTab:CreateToggle({
   Name = "Tự Động Đánh Thường", CurrentValue = true,
   Callback = function(v) States.AutoAttack = v end,
})

FarmTab:CreateToggle({
   Name = "Auto Farm Level & Nhận Quest", CurrentValue = false,
   Callback = function(v)
       States.AutoFarm = v
       if v then
           task.spawn(function()
               while States.AutoFarm do
                   pcall(function()
                       local char = LocalPlayer.Character
                       if char and char:FindFirstChild("HumanoidRootPart") then
                           local hrp = char.HumanoidRootPart
                           local qTitle, qIdx, npcPos, mobName = getQuest()
                           local qGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
                           
                           if not (qGui and qGui.Visible) then
                               smoothTween(npcPos)
                               task.wait(1)
                               ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", qTitle, qIdx)
                               task.wait(0.5)
                           else
                               local target = nil
                               for _, mob in pairs(workspace.Enemies:GetChildren()) do
                                   if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
                                       target = mob break
                                   end
                               end
                               if target then
                                   hrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 12, 3)
                               else
                                   smoothTween(npcPos + Vector3.new(0, 30, 0))
                               end
                           end
                       end
                   end)
                   task.wait(0.2)
               end
           end)
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Tự Gom Quái (Bring Mobs)", CurrentValue = false,
   Callback = function(v)
       States.BringMob = v
       if v then
           task.spawn(function()
               while States.BringMob do
                   pcall(function()
                       local hrp = LocalPlayer.Character.HumanoidRootPart
                       for _, mob in pairs(workspace.Enemies:GetChildren()) do
                           local mHrp = mob:FindFirstChild("HumanoidRootPart")
                           if mHrp and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
                               mHrp.CFrame = hrp.CFrame + Vector3.new(0, 0, 3)
                               mHrp.CanCollide = false
                           end
                       end
                   end)
                   task.wait(0.2)
               end
           end)
       end
   end,
})

-- Tab Haki
HakiTab:CreateToggle({
   Name = "Auto Buso Haki (Gồng)", CurrentValue = false,
   Callback = function(v)
       States.AutoBuso = v
       if v then
           task.spawn(function()
               while States.AutoBuso do
                   if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                       pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
                   end
                   task.wait(1)
               end
           end)
       end
   end,
})

-- Tab ESP & Bay
ESPTab:CreateToggle({
   Name = "ESP Highlight Người Chơi", CurrentValue = false,
   Callback = function(v)
       for _, p in pairs(Players:GetPlayers()) do
           if p ~= LocalPlayer and p.Character then
               local hl = p.Character:FindFirstChild("ToicuteHL")
               if v and not hl then
                   local h = Instance.new("Highlight", p.Character) h.Name = "ToicuteHL" h.FillColor = Color3.fromRGB(255, 105, 180)
               elseif not v and hl then hl:Destroy() end
           end
       end
   end,
})

-- Tab Nhân vật
PlayerTab:CreateSlider({
   Name = "WalkSpeed", Range = {16, 250}, Increment = 1, CurrentValue = 16,
   Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end,
})

Rayfield:Notify({Title = "toicute hub 🌸", Content = "Tải thành công bản gọn nhẹ!", Duration = 3})
