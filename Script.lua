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
-- GRAPHICS SAVE
-------------------------------------------------

local originalLighting = {
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient
}


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
-- ATTACK BUTTONS (FINAL CLEAN SYSTEM)
-------------------------------------------------

-- MAIN BUTTONS
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0,200,0,35)
speedBtn.Position = UDim2.new(0,0,0,0)
speedBtn.Text = "Speed"
speedBtn.Visible = false
speedBtn.Parent = scroll

local lightBtn = Instance.new("TextButton")
lightBtn.Size = UDim2.new(0,200,0,35)
lightBtn.Position = UDim2.new(0,0,0,40)
lightBtn.Text = "Light OFF"
lightBtn.Visible = false
lightBtn.Parent = scroll

local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(0,200,0,35)
infJumpBtn.Position = UDim2.new(0,0,0,80)
infJumpBtn.Text = "Inf Jump OFF"
infJumpBtn.Visible = false
infJumpBtn.Parent = scroll

local graphicsBtn = Instance.new("TextButton")
graphicsBtn.Size = UDim2.new(0,200,0,35)
graphicsBtn.Position = UDim2.new(0,0,0,120)
graphicsBtn.Text = "Graphics"
graphicsBtn.Visible = false
graphicsBtn.Parent = scroll

local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0,200,0,35)
restoreBtn.Position = UDim2.new(0,0,0,160)
restoreBtn.Text = "Restore Graphics"
restoreBtn.Visible = false
restoreBtn.Parent = scroll

-------------------------------------------------
-- SPEED POPUP
-------------------------------------------------

local sp1 = Instance.new("TextButton")
sp1.Size = UDim2.new(0,200,0,30)
sp1.Text = "1x Speed"
sp1.Visible = false
sp1.Parent = scroll

local sp2 = Instance.new("TextButton")
sp2.Size = UDim2.new(0,200,0,30)
sp2.Text = "2x Speed"
sp2.Visible = false
sp2.Parent = scroll

local sp3 = Instance.new("TextButton")
sp3.Size = UDim2.new(0,200,0,30)
sp3.Text = "3x Speed"
sp3.Visible = false
sp3.Parent = scroll

local sp4 = Instance.new("TextButton")
sp4.Size = UDim2.new(0,200,0,30)
sp4.Text = "4x Speed"
sp4.Visible = false
sp4.Parent = scroll

local function closeSpeed()
	sp1.Visible = false
	sp2.Visible = false
	sp3.Visible = false
	sp4.Visible = false

	lightBtn.Position = UDim2.new(0,0,0,40)
	infJumpBtn.Position = UDim2.new(0,0,0,80)
	graphicsBtn.Position = UDim2.new(0,0,0,120)
	restoreBtn.Position = UDim2.new(0,0,0,160)
end

local function setSpeed(mult)
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16 * mult
		end
	end
end

speedBtn.MouseButton1Click:Connect(function()

	local open = not sp1.Visible

	sp1.Visible = open
	sp2.Visible = open
	sp3.Visible = open
	sp4.Visible = open

	if open then
		sp1.Position = UDim2.new(0,0,0,40)
		sp2.Position = UDim2.new(0,0,0,70)
		sp3.Position = UDim2.new(0,0,0,100)
		sp4.Position = UDim2.new(0,0,0,130)

		lightBtn.Position = UDim2.new(0,0,0,170)
		infJumpBtn.Position = UDim2.new(0,0,0,210)
		graphicsBtn.Position = UDim2.new(0,0,0,250)
		restoreBtn.Position = UDim2.new(0,0,0,290)
	else
		closeSpeed()
	end

end)

sp1.MouseButton1Click:Connect(function() setSpeed(1) closeSpeed() end)
sp2.MouseButton1Click:Connect(function() setSpeed(2) closeSpeed() end)
sp3.MouseButton1Click:Connect(function() setSpeed(3) closeSpeed() end)
sp4.MouseButton1Click:Connect(function() setSpeed(4) closeSpeed() end)

-------------------------------------------------
-- GRAPHICS SYSTEM
-------------------------------------------------

local function graphicsNormal()
	local w = workspace
	local l = Lighting
	local t = w.Terrain

	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

	pcall(function() sethiddenproperty(l,"Technology",2) end)
	pcall(function() sethiddenproperty(t,"Decoration",false) end)

	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0

	l.GlobalShadows = false
	l.FogEnd = 9e9
	l.Brightness = 0.05
	l.Ambient = Color3.fromRGB(10,10,10)
	l.OutdoorAmbient = Color3.fromRGB(10,10,10)

	for _,v in pairs(w:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
		elseif v:IsA("Decal") then
			v.Transparency = 1
		end
	end
end

local function graphicsExtreme()
	graphicsNormal()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
			v.Enabled = false
		end
	end
end

local function graphicsRestore()
	local l = Lighting
	local t = workspace.Terrain

	l.Brightness = originalLighting.Brightness
	l.GlobalShadows = originalLighting.GlobalShadows
	l.FogEnd = originalLighting.FogEnd
	l.Ambient = originalLighting.Ambient
	l.OutdoorAmbient = originalLighting.OutdoorAmbient
	settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

	pcall(function() sethiddenproperty(t,"Decoration",true) end)

	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.SmoothPlastic
			v.Reflectance = 0.1
		elseif v:IsA("Decal") then
			v.Transparency = 0
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
			v.Enabled = true
		end
	end
end

-------------------------------------------------
-- GRAPHICS POPUP
-------------------------------------------------

local graphicsPopup1 = Instance.new("TextButton")
graphicsPopup1.Size = UDim2.new(0,200,0,30)
graphicsPopup1.Text = "Low Graphics"
graphicsPopup1.Visible = false
graphicsPopup1.Parent = scroll

local graphicsPopup2 = Instance.new("TextButton")
graphicsPopup2.Size = UDim2.new(0,200,0,30)
graphicsPopup2.Text = "Extreme Graphics"
graphicsPopup2.Visible = false
graphicsPopup2.Parent = scroll

local function closeGraphics()
	graphicsPopup1.Visible = false
	graphicsPopup2.Visible = false
	restoreBtn.Position = UDim2.new(0,0,0,160)
end

graphicsBtn.MouseButton1Click:Connect(function()

	local open = not graphicsPopup1.Visible
	local baseY = graphicsBtn.Position.Y.Offset

	graphicsPopup1.Visible = open
	graphicsPopup2.Visible = open

	if open then
		graphicsPopup1.Position = UDim2.new(0,0,0,baseY+40)
		graphicsPopup2.Position = UDim2.new(0,0,0,baseY+70)
		restoreBtn.Position = UDim2.new(0,0,0,baseY+110)
	else
		closeGraphics()
	end

end)

graphicsPopup1.MouseButton1Click:Connect(function()
	graphicsNormal()
	closeGraphics()
end)

graphicsPopup2.MouseButton1Click:Connect(function()
	graphicsExtreme()
	closeGraphics()
end)

restoreBtn.MouseButton1Click:Connect(function()
	graphicsRestore()
	closeGraphics()
end)

------------------------------------------------
-- LIGHT
-------------------------------------------------

local prevAmbient, prevOutdoor, prevBrightness, prevFogEnd

lightBtn.MouseButton1Click:Connect(function()

	lightOn = not lightOn
	lightBtn.Text = "Light "..(lightOn and "ON" or "OFF")

	if lightOn then
		prevAmbient = Lighting.Ambient
		prevOutdoor = Lighting.OutdoorAmbient
		prevBrightness = Lighting.Brightness
		prevFogEnd = Lighting.FogEnd

		Lighting.Ambient = Color3.fromRGB(180,180,180)
		Lighting.OutdoorAmbient = Color3.fromRGB(170,170,170)
		Lighting.Brightness = (prevBrightness or 1) * 2
		Lighting.FogEnd = 100000
	else
		if prevAmbient then Lighting.Ambient = prevAmbient end
		if prevOutdoor then Lighting.OutdoorAmbient = prevOutdoor end
		if prevBrightness then Lighting.Brightness = prevBrightness end
		if prevFogEnd then Lighting.FogEnd = prevFogEnd end
	end

end)
-------------------------------------------------
-- INFINITE JUMP
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
			root.Velocity = Vector3.new(root.Velocity.X, 120, root.Velocity.Z)
		end
	end
end)
    
-------------------------------------------------
-- PAGE SWITCH
-------------------------------------------------
local function hideAllAttackExtras()
	-- HIDE POPUPS
	sp1.Visible=false
	sp2.Visible=false
	sp3.Visible=false
	sp4.Visible=false
	graphicsPopup1.Visible=false
	graphicsPopup2.Visible=false

	-- RESET BUTTON POSITIONS (THIS WAS MISSING)
	speedBtn.Position = UDim2.new(0,0,0,0)
	lightBtn.Position = UDim2.new(0,0,0,40)
	infJumpBtn.Position = UDim2.new(0,0,0,80)
	graphicsBtn.Position = UDim2.new(0,0,0,120)
	restoreBtn.Position = UDim2.new(0,0,0,160)
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

	hideAllAttackExtras()
end

local function showAttack()

	hideAllAttackExtras()

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

	-- SHOW BUTTONS
	speedBtn.Visible=true
	lightBtn.Visible=true
	infJumpBtn.Visible=true
	graphicsBtn.Visible=true
	restoreBtn.Visible=true

	-- FIX POSITIONS (NO GAP)
	speedBtn.Position = UDim2.new(0,0,0,0)
	lightBtn.Position = UDim2.new(0,0,0,40)
	infJumpBtn.Position = UDim2.new(0,0,0,80)
	graphicsBtn.Position = UDim2.new(0,0,0,120)
	restoreBtn.Position = UDim2.new(0,0,0,160)

end
    
homeBtn.MouseButton1Click:Connect(showHome)
bringBtn.MouseButton1Click:Connect(showBring)
attackBtn.MouseButton1Click:Connect(showAttack)

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
