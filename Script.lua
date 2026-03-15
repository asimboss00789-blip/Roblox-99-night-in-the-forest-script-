-- Full updated script: Fallen Code (complete)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-------------------------------------------------
-- STATES
-------------------------------------------------

local playerESP=false
local animalESP=false
local chestESP=false

local lightOn = false
local infJumpEnabled = false

local originalWalkSpeed = 16
local originalHandleSizes = {} -- map tool -> Vector3

-------------------------------------------------
-- DROP ITEM
-------------------------------------------------

local function dropToPlayer(obj)

	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local pos=root.CFrame+Vector3.new(math.random(-3,3),6,math.random(-3,3))

	if obj:IsA("Model") and obj.PrimaryPart then
		obj:SetPrimaryPartCFrame(pos)
	else
		local p=obj:FindFirstChildWhichIsA("BasePart")
		if p then
			p.CFrame=pos
		end
	end

end

-------------------------------------------------
-- ESP
-------------------------------------------------

local function addESP(obj,color,tag)

	if obj:FindFirstChild(tag) then return end

	local h=Instance.new("Highlight")
	h.Name=tag
	h.FillColor=color
	h.OutlineColor=color
	h.FillTransparency=0.4
	h.Parent=obj

end

-------------------------------------------------
-- PLAYER ESP
-------------------------------------------------

local function updatePlayers()

	for _,p in pairs(Players:GetPlayers()) do

		if p~=player and p.Character then

			if playerESP then
				addESP(p.Character,Color3.fromRGB(0,255,0),"P_ESP")
			else
				local h=p.Character:FindFirstChild("P_ESP")
				if h then h:Destroy() end
			end

		end

	end

end

-------------------------------------------------
-- ANIMAL ESP
-------------------------------------------------

local function updateAnimals()

	for _,v in pairs(workspace:GetDescendants()) do

		local hum=v:FindFirstChildOfClass("Humanoid")

		if hum and not Players:GetPlayerFromCharacter(v) then

			if animalESP then
				addESP(v,Color3.fromRGB(255,0,0),"A_ESP")
			else
				local h=v:FindFirstChild("A_ESP")
				if h then h:Destroy() end
			end

		end

	end

end

-------------------------------------------------
-- CHEST ESP
-------------------------------------------------

local function updateChests()

	for _,v in pairs(workspace:GetDescendants()) do

		if v:IsA("Model") and v.PrimaryPart then

			if chestESP then
				addESP(v,Color3.fromRGB(255,220,0),"C_ESP")
			else
				local h=v:FindFirstChild("C_ESP")
				if h then h:Destroy() end
			end

		end

	end

end

-------------------------------------------------
-- BRING SYSTEM
-------------------------------------------------

local function bringByNames(names)

	for _,v in pairs(workspace:GetDescendants()) do

		local name=v.Name:lower()

		for _,n in pairs(names) do
			if string.find(name,n) then
				dropToPlayer(v)
				break
			end
		end

	end

end

-------------------------------------------------
-- BRING ITEMS
-------------------------------------------------

local function bringLogs()

	for _,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower()=="log" then
			dropToPlayer(v)
		end
	end

end

local function bringMetal()
	bringByNames({
		"metal",
		"bolt",
		"old radio",
		"broken fan",
		"broken microwave",
		"tyre"
	})
end

local function bringFuel()
	bringByNames({
		"fuel",
		"coal",
		"barrel"
	})
end

local function bringHeal()
	bringByNames({"bandage"})
end

local function bringAmmo()
	bringByNames({"ammo"})
end

local function bringWeapons()
	bringByNames({"rifle","gun","pistol"})
end

local function bringFood()
	bringByNames({"meat","carrot","berries","steak","apple"})
end

-------------------------------------------------
-- GUI
-------------------------------------------------

local gui=Instance.new("ScreenGui",player.PlayerGui)

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,460,0,280)
frame.Position=UDim2.new(0.5,-230,0,120)
frame.BackgroundColor3=Color3.fromRGB(25,25,25)
frame.Parent=gui

-------------------------------------------------
-- TOP BAR (title here will not be hidden when minimized)
-------------------------------------------------

local top=Instance.new("Frame")
top.Size=UDim2.new(1,0,0,30)
top.BackgroundColor3=Color3.fromRGB(35,35,35)
top.Parent=frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Fallen Code"
title.TextColor3 = Color3.fromRGB(160, 64, 255) -- purple
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close=Instance.new("TextButton")
close.Size=UDim2.new(0,30,1,0)
close.Position=UDim2.new(1,-30,0,0)
close.Text="X"
close.Parent=top

local minimize=Instance.new("TextButton")
minimize.Size=UDim2.new(0,30,1,0)
minimize.Position=UDim2.new(1,-60,0,0)
minimize.Text="-"
minimize.Parent=top

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-------------------------------------------------
-- MINIMIZE
-------------------------------------------------

local minimized=false

-------------------------------------------------
-- DRAG
-------------------------------------------------

local dragging=false
local dragStart
local startPos

top.InputBegan:Connect(function(input)

	if input.UserInputType==Enum.UserInputType.MouseButton1
	or input.UserInputType==Enum.UserInputType.Touch then

		dragging=true
		dragStart=input.Position
		startPos=frame.Position

		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then
				dragging=false
			end
		end)

	end

end)

UIS.InputChanged:Connect(function(input)

	if dragging then

		local delta=input.Position-dragStart

		frame.Position=UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset+delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset+delta.Y
		)

	end

end)

-------------------------------------------------
-- NAV BUTTONS
-------------------------------------------------

local homeBtn=Instance.new("TextButton")
homeBtn.Size=UDim2.new(0,90,0,45)
homeBtn.Position=UDim2.new(0,10,0,60)
homeBtn.Text="Home"
homeBtn.Parent=frame

local bringBtn=Instance.new("TextButton")
bringBtn.Size=UDim2.new(0,90,0,45)
bringBtn.Position=UDim2.new(0,10,0,120)
bringBtn.Text="Bring"
bringBtn.Parent=frame

local attackBtn=Instance.new("TextButton")
attackBtn.Size=UDim2.new(0,90,0,45)
attackBtn.Position=UDim2.new(0,10,0,180)
attackBtn.Text="Attack"
attackBtn.Parent=frame

-------------------------------------------------
-- SCROLL
-------------------------------------------------

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(0,300,0,210)
scroll.Position=UDim2.new(0,120,0,50)
scroll.CanvasSize=UDim2.new(0,0,0,600) -- tall enough for attack extras
scroll.ScrollBarThickness=6
scroll.BackgroundTransparency=1
scroll.Parent=frame

-------------------------------------------------
-- MINIMIZE SYSTEM
-------------------------------------------------

minimize.MouseButton1Click:Connect(function()

	minimized=not minimized

	if minimized then

		frame.Size=UDim2.new(0,460,0,30)
		homeBtn.Visible=false
		bringBtn.Visible=false
		attackBtn.Visible=false
		scroll.Visible=false

	else

		frame.Size=UDim2.new(0,460,0,280)
		homeBtn.Visible=true
		bringBtn.Visible=true
		attackBtn.Visible=true
		scroll.Visible=true

	end

end)

-------------------------------------------------
-- HOME BUTTONS
-------------------------------------------------

local playerBtn=Instance.new("TextButton")
playerBtn.Size=UDim2.new(0,200,0,40)
playerBtn.Position=UDim2.new(0,0,0,0)
playerBtn.Text="Player OFF"
playerBtn.Parent=scroll

local animalBtn=Instance.new("TextButton")
animalBtn.Size=UDim2.new(0,200,0,40)
animalBtn.Position=UDim2.new(0,0,0,50)
animalBtn.Text="Animal OFF"
animalBtn.Parent=scroll

local chestBtn=Instance.new("TextButton")
chestBtn.Size=UDim2.new(0,200,0,40)
chestBtn.Position=UDim2.new(0,0,0,100)
chestBtn.Text="Chest OFF"
chestBtn.Parent=scroll

-------------------------------------------------
-- BRING BUTTONS
-------------------------------------------------

local logBtn=Instance.new("TextButton")
logBtn.Size=UDim2.new(0,200,0,35)
logBtn.Position=UDim2.new(0,0,0,0)
logBtn.Text="Bring Log"
logBtn.Visible=false
logBtn.Parent=scroll

local metalBtn=Instance.new("TextButton")
metalBtn.Size=UDim2.new(0,200,0,35)
metalBtn.Position=UDim2.new(0,0,0,40)
metalBtn.Text="Bring Metal"
metalBtn.Visible=false
metalBtn.Parent=scroll

local fuelBtn=Instance.new("TextButton")
fuelBtn.Size=UDim2.new(0,200,0,35)
fuelBtn.Position=UDim2.new(0,0,0,80)
fuelBtn.Text="Bring Fuel"
fuelBtn.Visible=false
fuelBtn.Parent=scroll

local healBtn=Instance.new("TextButton")
healBtn.Size=UDim2.new(0,200,0,35)
healBtn.Position=UDim2.new(0,0,0,120)
healBtn.Text="Heal"
healBtn.Visible=false
healBtn.Parent=scroll

local ammoBtn=Instance.new("TextButton")
ammoBtn.Size=UDim2.new(0,200,0,35)
ammoBtn.Position=UDim2.new(0,0,0,160)
ammoBtn.Text="Ammo"
ammoBtn.Visible=false
ammoBtn.Parent=scroll

local rifleBtn=Instance.new("TextButton")
rifleBtn.Size=UDim2.new(0,200,0,35)
rifleBtn.Position=UDim2.new(0,0,0,200)
rifleBtn.Text="Rifle"
rifleBtn.Visible=false
rifleBtn.Parent=scroll

local foodBtn=Instance.new("TextButton")
foodBtn.Size=UDim2.new(0,200,0,35)
foodBtn.Position=UDim2.new(0,0,0,240)
foodBtn.Text="Food"
foodBtn.Visible=false
foodBtn.Parent=scroll

-------------------------------------------------
-- ATTACK BUTTONS (layout: Speed @0, Range @40, Light @80, InfJump @120)
-------------------------------------------------

local speedBtn=Instance.new("TextButton")
speedBtn.Size=UDim2.new(0,200,0,35)
speedBtn.Position=UDim2.new(0,0,0,0)
speedBtn.Text="Speed"
speedBtn.Visible=false
speedBtn.Parent=scroll

local rangeBtn=Instance.new("TextButton")
rangeBtn.Size=UDim2.new(0,200,0,35)
rangeBtn.Position=UDim2.new(0,0,0,40)
rangeBtn.Text="Range"
rangeBtn.Visible=false
rangeBtn.Parent=scroll

local lightBtn = Instance.new("TextButton")
lightBtn.Size = UDim2.new(0,200,0,35)
lightBtn.Position = UDim2.new(0,0,0,80)
lightBtn.Text = "Light OFF"
lightBtn.Visible = false
lightBtn.Parent = scroll

local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(0,200,0,35)
infJumpBtn.Position = UDim2.new(0,0,0,120)
infJumpBtn.Text = "Inf Jump OFF"
infJumpBtn.Visible = false
infJumpBtn.Parent = scroll

-- Speed choices (1x..4x) placed directly under Speed button (overlay)
local sp1 = Instance.new("TextButton")
sp1.Size = UDim2.new(0,200,0,30)
sp1.Position = UDim2.new(0,0,0,35)
sp1.Text = "1x"
sp1.Visible = false
sp1.Parent = scroll

local sp2 = sp1:Clone()
sp2.Position = UDim2.new(0,0,0,65)
sp2.Text = "2x"
sp2.Parent = scroll

local sp3 = sp1:Clone()
sp3.Position = UDim2.new(0,0,0,95)
sp3.Text = "3x"
sp3.Parent = scroll

local sp4 = sp1:Clone()
sp4.Position = UDim2.new(0,0,0,125)
sp4.Text = "4x"
sp4.Parent = scroll

-- Range choices (1x..4x) placed directly under Range button
local rg1 = sp1:Clone()
rg1.Position = UDim2.new(0,0,0,75) -- under Range area (Range is at 40, so these start at 175 to avoid overlap; they overlay)
rg1.Text = "1x"
rg1.Visible = false
rg1.Parent = scroll

local rg2 = rg1:Clone()
rg2.Position = UDim2.new(0,0,0,105)
rg2.Text = "2x"
rg2.Parent = scroll

local rg3 = rg1:Clone()
rg3.Position = UDim2.new(0,0,0,135)
rg3.Text = "3x"
rg3.Parent = scroll

local rg4 = rg1:Clone()
rg4.Position = UDim2.new(0,0,0,165)
rg4.Text = "4x"
rg4.Parent = scroll

-------------------------------------------------
-- Helpers for original sizes
-------------------------------------------------
local function recordOriginalHandle(tool)
	if not tool or not tool:IsA("Tool") then return end
	local handle = tool:FindFirstChild("Handle")
	if handle and originalHandleSizes[tool] == nil then
		originalHandleSizes[tool] = handle.Size
	end
end

local reachMult = 1

function applyRangeMult(mult)
	reachMult = mult or 1

	local char = player.Character
	if not char then return end

	for _,tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			local handle = tool:FindFirstChild("Handle")
			if handle then
				handle.Size = Vector3.new(1,1,1) * (reachMult * 4)
			end
		end
	end
end

player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(obj)
		if obj:IsA("Tool") then
			task.wait(0.1)
			applyRangeMult(reachMult)
		end
	end)
end)


-------------------------------------------------
-- PAGE SWITCH
-------------------------------------------------

local function hideAllAttackExtras()
	sp1.Visible=false; sp2.Visible=false; sp3.Visible=false; sp4.Visible=false
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end

local function showHome()

	playerBtn.Visible=true
	animalBtn.Visible=true
	chestBtn.Visible=true

	logBtn.Visible=false
	metalBtn.Visible=false
	fuelBtn.Visible=false
	healBtn.Visible=false
	ammoBtn.Visible=false
	rifleBtn.Visible=false
	foodBtn.Visible=false

	speedBtn.Visible=false
	rangeBtn.Visible=false

	hideAllAttackExtras()
end

local function showBring()

	playerBtn.Visible=false
	animalBtn.Visible=false
	chestBtn.Visible=false

	logBtn.Visible=true
	metalBtn.Visible=true
	fuelBtn.Visible=true
	healBtn.Visible=true
	ammoBtn.Visible=true
	rifleBtn.Visible=true
	foodBtn.Visible=true

	speedBtn.Visible=false
	rangeBtn.Visible=false

	hideAllAttackExtras()
end

local function showAttack()

	playerBtn.Visible=false
	animalBtn.Visible=false
	chestBtn.Visible=false

	logBtn.Visible=false
	metalBtn.Visible=false
	fuelBtn.Visible=false
	healBtn.Visible=false
	ammoBtn.Visible=false
	rifleBtn.Visible=false
	foodBtn.Visible=false

	speedBtn.Visible=true
	rangeBtn.Visible=true
	lightBtn.Visible=true
	infJumpBtn.Visible=true

	hideAllAttackExtras()
end

homeBtn.MouseButton1Click:Connect(showHome)
bringBtn.MouseButton1Click:Connect(showBring)
attackBtn.MouseButton1Click:Connect(showAttack)

-------------------------------------------------
-- SPEED
-------------------------------------------------

speedBtn.MouseButton1Click:Connect(function()
	-- show speed choices directly under Speed button
	sp1.Visible=true; sp2.Visible=true; sp3.Visible=true; sp4.Visible=true

	-- hide range choices & other popups
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end)

local function setSpeed(mult)
	local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		-- set to exact multiple of originalWalkSpeed
		hum.WalkSpeed = (originalWalkSpeed or 16) * (mult or 1)
	end
	-- hide popup after pick
	sp1.Visible=false; sp2.Visible=false; sp3.Visible=false; sp4.Visible=false
end

sp1.MouseButton1Click:Connect(function() setSpeed(1) end)
sp2.MouseButton1Click:Connect(function() setSpeed(2) end)
sp3.MouseButton1Click:Connect(function() setSpeed(3) end)
sp4.MouseButton1Click:Connect(function() setSpeed(4) end)

-- keep originalWalkSpeed in sync if player's character spawns
local function cacheOriginalWalkSpeed()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum.WalkSpeed then
		originalWalkSpeed = hum.WalkSpeed
	else
		originalWalkSpeed = 16
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	cacheOriginalWalkSpeed()
end)
cacheOriginalWalkSpeed()

-------------------------------------------------
-- RANGE
-------------------------------------------------

rangeBtn.MouseButton1Click:Connect(function()
	-- show range choices directly under Range button
	rg1.Visible=true; rg2.Visible=true; rg3.Visible=true; rg4.Visible=true

	-- hide speed choices
	sp1.Visible=false; sp2.Visible=false; sp3.Visible=false; sp4.Visible=false
end)

rg1.MouseButton1Click:Connect(function()
	applyRangeMult(1)
	-- hide popup
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end)
rg2.MouseButton1Click:Connect(function()
	applyRangeMult(2)
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end)
rg3.MouseButton1Click:Connect(function()
	applyRangeMult(3)
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end)
rg4.MouseButton1Click:Connect(function()
	applyRangeMult(4)
	rg1.Visible=false; rg2.Visible=false; rg3.Visible=false; rg4.Visible=false
end)

-------------------------------------------------
-- LIGHT (new)
-------------------------------------------------

local prevAmbient = Lighting.Ambient
local prevOutdoor = Lighting.OutdoorAmbient
local prevBrightness = Lighting.Brightness

lightBtn.MouseButton1Click:Connect(function()
	lightOn = not lightOn
	lightBtn.Text = "Light "..(lightOn and "ON" or "OFF")

	if lightOn then
		Lighting.Ambient = Color3.fromRGB(220,220,220)
		Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
		Lighting.Brightness = math.max(prevBrightness or 0, 2)
	else
		if prevAmbient then Lighting.Ambient = prevAmbient end
		if prevOutdoor then Lighting.OutdoorAmbient = prevOutdoor end
		if prevBrightness then Lighting.Brightness = prevBrightness end
	end
end)

-------------------------------------------------
-- INFINITE JUMP (new)
-------------------------------------------------

infJumpBtn.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	infJumpBtn.Text = "Inf Jump "..(infJumpEnabled and "ON" or "OFF")
end)

UIS.JumpRequest:Connect(function()
	if infJumpEnabled and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if hum and root then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			-- upward boost to allow stacking; tune this value if needed
			root.Velocity = Vector3.new(root.Velocity.X, 120, root.Velocity.Z)
		end
	end
end)

-------------------------------------------------
-- BUTTON ACTIONS
-------------------------------------------------

playerBtn.MouseButton1Click:Connect(function()
	playerESP=not playerESP
	playerBtn.Text="Player "..(playerESP and "ON" or "OFF")
	updatePlayers()
end)

animalBtn.MouseButton1Click:Connect(function()
	animalESP=not animalESP
	animalBtn.Text="Animal "..(animalESP and "ON" or "OFF")
	updateAnimals()
end)

chestBtn.MouseButton1Click:Connect(function()
	chestESP=not chestESP
	chestBtn.Text="Chest "..(chestESP and "ON" or "OFF")
	updateChests()
end)

logBtn.MouseButton1Click:Connect(bringLogs)
metalBtn.MouseButton1Click:Connect(bringMetal)
fuelBtn.MouseButton1Click:Connect(bringFuel)
healBtn.MouseButton1Click:Connect(bringHeal)
ammoBtn.MouseButton1Click:Connect(bringAmmo)
rifleBtn.MouseButton1Click:Connect(bringWeapons)
foodBtn.MouseButton1Click:Connect(bringFood)

-------------------------------------------------
-- AUTO UPDATE
-------------------------------------------------

task.spawn(function()
	while true do
		task.wait(2)

		if playerESP then updatePlayers() end
		if animalESP then updateAnimals() end
		if chestESP then updateChests() end
	end
end)
