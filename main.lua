-- ======================================================
-- TOICUTE HUB 🌸 | Blox Fruits Ultimate (Fixed & Smooth)
-- ======================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("[toicute hub] Không thể tải Rayfield UI!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "toicute hub 🌸 | Blox Fruits Ultimate",
   LoadingTitle = "Đang tải toicute hub...",
   LoadingSubtitle = "by toicute001-netizen",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "toicute_hub_configs",
      FileName = "UltimateFarmConfig"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local States = {
    AutoBuso = false,
    AutoObservation = false,
    AutoFarmLevel = false,
    BringMob = false,
    AutoAttack = true, -- Tự động bật đánh thường mặc định
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    ESPEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50
}

-- ======================================================
-- VÒNG LẶP TỰ ĐỘNG ĐÁNH THƯỜNG (0.5s / ĐẤM)
-- ======================================================
task.spawn(function()
    while true do
        if States.AutoAttack then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    if tool and tool.Parent ~= char then
                        tool.Parent = char
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(500, 500))
                end
            end)
        end
        task.wait(0.5)
    end
end)

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

-- 2. HỆ THỐNG AUTO FARM (ĐÃ SỬA LỖI ĐỨNG IM)
FarmTab:CreateSection("Auto Farm Level Ổn Định")

FarmTab:CreateToggle({
   Name = "Tự Động Đánh Thường (Auto Clicker)",
   CurrentValue = true,
   Flag = "AutoAttackToggle",
   Callback = function(Value)
       States.AutoAttack = Value
   end,
})

local function smoothTween(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local speed = 350
    local timeVal = distance / speed
    if timeVal < 0.1 then timeVal = 0.1 end
    
    local tweenInfo = TweenInfo.new(timeVal, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

local function getQuestData()
    local level = LocalPlayer.Data.Level.Value
    if level >= 1 and level <= 9 then
        return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit"
    elseif level >= 10 and level <= 14 then
        return "JungleQuest", 1, CFrame.new(-1598, 36, 153), "Monkey"
    elseif level >= 15 and level <= 29 then
        return "JungleQuest", 2, CFrame.new(-1598, 36, 153), "Gorilla"
    elseif level >= 30 and level <= 39 then
        return "PirateQuest", 1, CFrame.new(-1140, 4, 3828), "Pirate"
    elseif level >= 40 and level <= 59 then
        return "PirateQuest", 2, CFrame.new(-1140, 4, 3828), "Brute"
    else
        -- Mặc định an toàn tránh đứng im nếu vượt cấp
        return "MarineQuest", 1, CFrame.new(-2708, 9, 2103), "Bandit"
    end
end

FarmTab:CreateToggle({
   Name = "Bật Auto Farm Level & Nhận Quest",
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
                           local questTitle, questIndex, npcPos, mobName = getQuestData()
                           
                           -- Kiểm tra giao diện xem đã có Quest chưa
                           local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                           local questGui = playerGui and playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
                           local hasActiveQuest = questGui and questGui.Visible
                           
                           if not hasActiveQuest then
                               -- Bay đến nhận nhiệm vụ
                               smoothTween(npcPos)
                               task.wait(1)
                               ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questTitle, questIndex)
                               task.wait(0.5)
                           else
                               -- Tìm quái mục tiêu gần nhất
                               local targetMob = nil
                               for _, v in pairs(workspace.Enemies:GetChildren()) do
                                   if v.Name == mobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") and v.Humanoid.Health > 0 then
                                       targetMob = v
                                       break
                                   end
                               end
                               
                               if targetMob then
                                   local mobHrp = targetMob.HumanoidRootPart
                                   -- Giữ khoảng cách trên đầu quái để đánh an toàn
                                   hrp.CFrame = mobHrp.CFrame + Vector3.new(0, 12, 3)
                               else
                                   -- Nếu chưa thấy quái, bay lơ lửng quanh khu vực NPC/Quái spawn
                                   smoothTween(npcPos + Vector3.new(0, 30, 0))
                               end
                           end
                       end
                   end)
                   task.wait(0.2)
               end
           end)
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã BẬT Auto Farm mượt mà!", Duration = 2, Image = 4483362458 })
       else
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã TẮT Auto Farm!", Duration = 2, Image = 4483362458 })
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Bật Tự Gom Quái (Bring Mobs)",
   CurrentValue = false,
   Flag = "BringMobToggle",
   Callback = function(Value)
       States.BringMob = Value
       if Value then
           task.spawn(function()
               while States.BringMob do
                   pcall(function()
                       local char = LocalPlayer.Character
                       if char and char:FindFirstChild("HumanoidRootPart") then
                           local hrp = char.HumanoidRootPart
                           for _, v in pairs(workspace.Enemies:GetChildren()) do
                               local enemyHrp = v:FindFirstChild("HumanoidRootPart")
                               local humanoid = v:FindFirstChildOfClass("Humanoid")
                               if enemyHrp and humanoid and humanoid.Health > 0 then
                                   enemyHrp.CFrame = hrp.CFrame + Vector3.new(0, 0, 3)
                                   enemyHrp.CanCollide = false
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

-- 3. HAKI ⚔️
HakiTab:CreateSection("Tự động Haki")
HakiTab:CreateToggle({
   Name = "Auto Buso Haki (Haki Gồng)",
   CurrentValue = false,
   Flag = "BusoToggle",
   Callback = function(Value)
       States.AutoBuso = Value
       if Value then
           task.spawn(function()
               while States.AutoBuso do
                   local char = LocalPlayer.Character
                   if char and not char:FindFirstChild("HasBuso") then
                       pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
                   end
                   task.wait(1)
               end
           end)
       end
   end,
})

HakiTab:CreateToggle({
   Name = "Auto Observation Haki (Quan Sát)",
   CurrentValue = false,
   Flag = "KenToggle",
   Callback = function(Value)
       States.AutoObservation = Value
       if Value then
           task.spawn(function()
               while States.AutoObservation do
                   pcall(function()
                       local ken = ReplicatedStorage.Remotes:FindFirstChild("Ken")
                       if ken then ken:FireServer() end
                   end)
                   task.wait(3)
               end
           end)
       end
   end,
})

-- 4. ESP & DI CHUYỂN
ESPTab:CreateSection("ESP Người chơi")
ESPTab:CreateToggle({
   Name = "Bật ESP Highlight",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       States.ESPEnabled = Value
       for _, p in ipairs(Players:GetPlayers()) do
           if p ~= LocalPlayer and p.Character then
               local hl = p.Character:FindFirstChild("ToicuteHighlight")
               if Value and not hl then
                   local h = Instance.new("Highlight")
                   h.Name = "ToicuteHighlight"
                   h.FillColor = Color3.fromRGB(255, 105, 180)
                   h.Parent = p.Character
               elseif not Value and hl then
                   hl:Destroy()
               end
           end
       end
   end,
})

ESPTab:CreateSection("Bay (Fly Mode)")
ESPTab:CreateToggle({
   Name = "Bật Bay",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       States.FlyEnabled = Value
       if Value then
           task.spawn(function()
               local char = LocalPlayer.Character
               if not char or not char:FindFirstChild("HumanoidRootPart") then return end
               local root = char.HumanoidRootPart
               local bg = Instance.new("BodyGyro", root)
               local bv = Instance.new("BodyVelocity", root)
               bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
               bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
               
               while States.FlyEnabled and char.Parent do
                   local cam = workspace.CurrentCamera
                   local dir = Vector3.new()
                   if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                   if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                   bv.Velocity = dir * States.FlySpeed
                   bg.CFrame = cam.CFrame
                   task.wait()
               end
               bg:Destroy()
               bv:Destroy()
           end)
       end
   end,
})

ESPTab:CreateSlider({
   Name = "Tốc độ Bay",
   Range = {10, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(v) States.FlySpeed = v end,
})

-- 5. NHÂN VẬT
PlayerTab:CreateSection("Chỉ số")
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS",
   Callback = function(v)
       States.WalkSpeedValue = v
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = v
       end
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 350},
   Increment = 5,
   CurrentValue = 50,
   Flag = "JP",
   Callback = function(v)
       States.JumpPowerValue = v
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.JumpPower = v
       end
   end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    char.Humanoid.WalkSpeed = States.WalkSpeedValue
    char.Humanoid.JumpPower = States.JumpPowerValue
end)

-- 6. CÀI ĐẶT
SettingsTab:CreateSection("Thông tin")
SettingsTab:CreateParagraph({Title = "Trạng thái", Content = "Mọi lỗi đã được khắc phục hoàn toàn."})

Rayfield:Notify({Title = "toicute hub 🌸", Content = "Đã cập nhật bản sửa lỗi tối ưu!", Duration = 3})
