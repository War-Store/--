-- الخدمات
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- إنشاء الواجهة
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportBoostUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 220)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 16)
uicorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.15, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 Teleport & Boost"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- دالة لإنشاء أزرار بشكل مرتب
local function createButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0.18, 0)
    btn.Position = UDim2.new(0.1, 0, yPos, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 12)
    btn.Parent = frame
    return btn
end

local saveButton = createButton("💾 Save Location", 0.25, Color3.fromRGB(0, 150, 255))
local teleportButton = createButton("✈ Teleport", 0.5, Color3.fromRGB(0, 200, 100))
teleportButton.Visible = false
local boostButton = createButton("⚡ Boost", 0.75, Color3.fromRGB(255, 70, 70))

local indicator = Instance.new("Frame", frame)
indicator.Size = UDim2.new(0, 22, 0, 22)
indicator.Position = UDim2.new(0.87, 0, 0.77, 0)
indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
indicator.BorderSizePixel = 0
local indicatorCorner = Instance.new("UICorner", indicator)
indicatorCorner.CornerRadius = UDim.new(1, 0)

-- تأثير Blur للـ Boost
local blur = Lighting:FindFirstChild("BoostBlur")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Name = "BoostBlur"
    blur.Size = 0
    blur.Parent = Lighting
end

-- حماية اللاعب (GodMode)
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge
humanoid:GetPropertyChangedSignal("Health"):Connect(function()
    if humanoid.Health < 100 then
        humanoid.Health = math.huge
    end
end)

-- متغيرات
local savedCFrame = nil
local isBoosting = false

-- تنظيف الطريق بين نقطتين
local function clearObstacles(startPos, endPos)
    local direction = (endPos - startPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local hit = Workspace:Raycast(startPos, direction, rayParams)
    while hit do
        local part = hit.Instance
        if part and part:IsA("BasePart") and part.Anchored then
            part:Destroy()
        end
        hit = Workspace:Raycast(startPos, direction, rayParams)
    end
end

-- مؤثر بصري للانتقال
local function teleportEffect(pos)
    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(5,5,5)
    orb.CFrame = CFrame.new(pos)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Transparency = 0.5
    orb.Color = Color3.fromRGB(0, 170, 255)
    orb.Parent = Workspace

    TweenService:Create(orb, TweenInfo.new(0.6), {Size = Vector3.new(0,0,0), Transparency = 1}):Play()
    game:GetService("Debris"):AddItem(orb, 1)
end

-- حفظ المكان عند الضغط
saveButton.MouseButton1Click:Connect(function()
    if hrp then
        savedCFrame = hrp.CFrame
        saveButton.Text = "✅ Location Saved"
        teleportButton.Visible = true
        wait(1.2)
        saveButton.Text = "💾 Save Location"
    end
end)

-- التليبورت عند الضغط
teleportButton.MouseButton1Click:Connect(function()
    if savedCFrame then
        clearObstacles(hrp.Position, savedCFrame.Position)
        teleportEffect(hrp.Position)
        teleportEffect(savedCFrame.Position)
        char:PivotTo(savedCFrame)
    end
end)

-- Boost مع تغيير لون المؤشر وتفعيل تأثيرات
boostButton.MouseButton1Click:Connect(function()
    if isBoosting then return end
    isBoosting = true
    indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    humanoid.WalkSpeed = 44
    blur.Size = 15

    wait(4)

    humanoid.WalkSpeed = 16
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    blur.Size = 0
    isBoosting = false
end)
