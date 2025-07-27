-- الخدمات
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- إنشاء الواجهة
local gui = Instance.new("ScreenGui")
gui.Name = "EliteTeleportBoostUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 270) -- زودت الطول عشان الزر الجديد
frame.Position = UDim2.new(0.04, 0, 0.04, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
frame.BackgroundTransparency = 0.05
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 18)

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 70)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 28))
}

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.12, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🚀 Elite Teleport & Boost + Tool"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- دالة إنشاء أزرار أنيقة
local function createButton(text, ypos, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.8, 0, 0.15, 0)
	btn.Position = UDim2.new(0.1, 0, ypos, 0)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.AutoButtonColor = true
	btn.Parent = frame
	local c = Instance.new("UICorner", btn)
	c.CornerRadius = UDim.new(0, 14)
	return btn
end

local saveBtn = createButton("💾 Save Location", 0.2, Color3.fromRGB(0, 160, 240))
local teleportBtn = createButton("✈ Teleport Now", 0.38, Color3.fromRGB(0, 230, 120))
teleportBtn.Visible = false
local boostBtn = createButton("⚡ Activate Boost", 0.56, Color3.fromRGB(220, 50, 70))
local getToolBtn = createButton("🛠 Get Tool", 0.74, Color3.fromRGB(180, 180, 40))

-- مؤشر Boost
local indicator = Instance.new("Frame", frame)
indicator.Size = UDim2.new(0, 24, 0, 24)
indicator.Position = UDim2.new(0.9, 0, 0.59, 0)
indicator.BackgroundColor3 = Color3.fromRGB(230, 20, 20)
indicator.BorderSizePixel = 0
local indicatorCorner = Instance.new("UICorner", indicator)
indicatorCorner.CornerRadius = UDim.new(1, 0)

-- تأثير Blur للـBoost
local blur = Lighting:FindFirstChild("BoostBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "BoostBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

-- GodMode حماية اللاعب من الموت
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge
humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	if humanoid.Health < 100 then
		humanoid.Health = math.huge
	end
end)

local savedPosition = nil
local savedOrientation = nil
local boosting = false

-- تنظيف الطريق بين نقطتين
local function clearObstacles(fromPos, toPos)
	local direction = toPos - fromPos
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.IgnoreWater = true
	
	local hit = Workspace:Raycast(fromPos, direction, rayParams)
	while hit do
		local part = hit.Instance
		if part and part:IsA("BasePart") and part.Anchored then
			part:Destroy()
		end
		hit = Workspace:Raycast(fromPos, direction, rayParams)
	end
end

-- مؤثر بصري للانتقال
local function teleportEffect(pos)
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(6,6,6)
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

-- حفظ الموقع
saveBtn.MouseButton1Click:Connect(function()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		savedPosition = hrp.Position
		savedOrientation = hrp.Orientation
		saveBtn.Text = "✅ Location Saved"
		teleportBtn.Visible = true
		wait(1)
		saveBtn.Text = "💾 Save Location"
	end
end)

-- انتقال اللاعب بأمان بدون ارتداد
teleportBtn.MouseButton1Click:Connect(function()
	if savedPosition then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			clearObstacles(hrp.Position, savedPosition)
			teleportEffect(hrp.Position)
			teleportEffect(savedPosition)
			humanoid:MoveTo(savedPosition)
			for i = 0, 1, 0.1 do
				hrp.Orientation = Vector3.new(
					hrp.Orientation.X,
					hrp.Orientation.Y + (savedOrientation.Y - hrp.Orientation.Y) * i,
					hrp.Orientation.Z
				)
				wait(0.03)
			end
		end
	end
end)

-- تفعيل الـ Boost مع مؤثرات
boostBtn.MouseButton1Click:Connect(function()
	if boosting then return end
	boosting = true
	indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	humanoid.WalkSpeed = 44
	blur.Size = 15

	wait(4)

	humanoid.WalkSpeed = 16
	indicator.BackgroundColor3 = Color3.fromRGB(230, 20, 20)
	blur.Size = 0
	boosting = false
end)

-- زر التول والأنيميشن
getToolBtn.MouseButton1Click:Connect(function()
	-- تحقق إذا التول موجود مسبقاً في الحقيبة
	if player.Backpack:FindFirstChild("EliteTool") or character:FindFirstChild("EliteTool") then
		getToolBtn.Text = "✅ Tool Already Owned"
		wait(1.5)
		getToolBtn.Text = "🛠 Get Tool"
		return
	end
	
	-- إنشاء التول
	local tool = Instance.new("Tool")
	tool.Name = "EliteTool"
	tool.RequiresHandle = false
	tool.CanBeDropped = true

	-- إضافة أنيميشن للـ tool
	local animator
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://135879895990983"

	-- عند تفعيل التول (Equip)
	tool.Equipped:Connect(function()
		if not animator and humanoid then
			animator = humanoid:FindFirstChildOfClass("Animator")
			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = humanoid
			end
		end
		if animator then
			local animTrack = animator:LoadAnimation(animation)
			animTrack:Play()
			tool.AnimTrack = animTrack
		end
	end)

	-- عند خلع التول (Unequip)
	tool.Unequipped:Connect(function()
		if tool.AnimTrack then
			tool.AnimTrack:Stop()
			tool.AnimTrack = nil
		end
	end)

	-- إعطاء التول للاعب
	tool.Parent = player.Backpack
	getToolBtn.Text = "✅ Tool Added!"
	wait(1.5)
	getToolBtn.Text = "🛠 Get Tool"
end)
