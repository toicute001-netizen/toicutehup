-- ======================================================
-- TOICUTE HUB 🌸 | Full Features (Auto Farm, ESP, Fly, WalkSpeed)
-- ======================================================

local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("[toicute hub] Không thể tải giao diện Rayfield!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "toicute hub 🌸",
   LoadingTitle = "Đang tải toicute hub...",
   LoadingSubtitle = "by toicute001-netizen",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "toicute_hub_configs",
      FileName = "FullConfig"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local States = {
    AutoFarm = false,
    WalkSpeedValue = 16,
    JumpPowerValue = 50,
    ESPEnabled = false,
    FlyEnabled = false,
    FlySpeed = 50
}

local MainTab = Window:CreateTab("Trang chính", 4483362458)
local ESPTab = Window:CreateTab("ESP & Di chuyển", 4483362340)
local PlayerTab = Window:CreateTab("Nhân vật", 4483362458)

-- 1. TAB TRANG CHÍNH: AUTO FARM
MainTab:CreateSection("Tự động hóa")
MainTab:CreateToggle({
   Name = "Bật Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       States.AutoFarm = Value
       if Value then
           task.spawn(function()
               while States.AutoFarm do
                   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       -- Logic farm
                   end
                   task.wait(0.2)
               end
           end)
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã BẬT Auto Farm!", Duration = 2, Image = 4483362458 })
       else
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã TẮT Auto Farm!", Duration = 2, Image = 4483362458 })
       end
   end,
})

-- 2. TAB ESP & DI CHUYỂN
ESPTab:CreateSection("ESP Người chơi")
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        if char and not char:FindFirstChild("ToicuteHighlight") and States.ESPEnabled then
            local hl = Instance.new("Highlight")
            hl.Name = "ToicuteHighlight"
            hl.FillColor = Color3.fromRGB(255, 105, 180)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Parent = char
        end
    end
    if player.Character then setupChar(player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if States.ESPEnabled then setupChar(char) end
    end)
end

ESPTab:CreateToggle({
   Name = "Bật ESP (Highlight)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       States.ESPEnabled = Value
       for _, p in ipairs(Players:GetPlayers()) do
           if p ~= LocalPlayer then
               if Value then
                   applyESP(p)
               else
                   if p.Character and p.Character:FindFirstChild("ToicuteHighlight") then
                       p.Character.ToicuteHighlight:Destroy()
                   end
               end
           end
       end
   end,
})

ESPTab:CreateSection("Tính năng Bay (Fly)")
local function startFly()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "ToicuteFlyGyro"
    gyro.P = 9e4
    gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.cframe = rootPart.CFrame
    gyro.Parent = rootPart
    
    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "ToicuteFlyVelocity"
    velocity.velocity = Vector3.new(0, 0, 0)
    velocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    velocity.Parent = rootPart
    
    if humanoid then humanoid.PlatformStand = true end
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not States.FlyEnabled or not rootPart.Parent then
            if gyro then gyro:Destroy() end
            if velocity then velocity:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
            connection:Disconnect()
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CoordinateFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CoordinateFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CoordinateFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CoordinateFrame.RightVector end
        
        velocity.velocity = moveDir * States.FlySpeed
        gyro.cframe = camera.CoordinateFrame
    end)
end

ESPTab:CreateToggle({
   Name = "Bật Bay (Fly Mode)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
       States.FlyEnabled = Value
       if Value then
           startFly()
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã BẬT Bay! Dùng WASD để di chuyển.", Duration = 2, Image = 4483362458 })
       else
           Rayfield:Notify({ Title = "toicute hub", Content = "Đã TẮT Bay!", Duration = 2, Image = 4483362458 })
       end
   end,
})

ESPTab:CreateSlider({
   Name = "Tốc độ Bay (Fly Speed)",
   Range = {10, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
       States.FlySpeed = Value
   end,
})

-- 3. TAB NHÂN VẬT
PlayerTab:CreateSection("Tùy chỉnh Chỉ số")
PlayerTab:CreateSlider({
   Name = "Tốc độ chạy (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
       States.WalkSpeedValue = Value
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

PlayerTab:CreateSlider({
   Name = "Sức nhảy (JumpPower)",
   Range = {50, 350},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
       States.JumpPowerValue = Value
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.JumpPower = Value
       end
   end,
})

LocalPlayer.CharacterAdded:Connect(function(Char)
    Char:WaitForChild("Humanoid")
    task.wait(0.5)
    Char.Humanoid.WalkSpeed = States.WalkSpeedValue
    Char.Humanoid.JumpPower = States.JumpPowerValue
end)

Rayfield:Notify({
   Title = "toicute hub 🌸",
   Content = "Đã tải toicute hub thành công!",
   Duration = 3,
   Image = 4483362458,
})
