local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SytherUIScreenGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local themes = {
	DarkBrown = {
		Name = "Dark Brown",
		MainFrameBG = Color3.fromRGB(45, 30, 15),
		MainFrameBorder = Color3.fromRGB(80, 55, 25),
		TitleBarBG = Color3.fromRGB(60, 40, 20),
		TitleBarText = Color3.fromRGB(220, 200, 180),
		TabFrameBG = Color3.fromRGB(50, 35, 20),
		ContentFrameBG = Color3.fromRGB(55, 40, 25),
		ButtonBG = Color3.fromRGB(100, 65, 30),
		ButtonText = Color3.fromRGB(255, 255, 255),
		ButtonBorder = Color3.fromRGB(130, 85, 40),
		ButtonBGHover = Color3.fromRGB(120, 80, 40),
		ButtonTextHover = Color3.fromRGB(255, 255, 255),
		ButtonBorderHover = Color3.fromRGB(150, 100, 50),
		ActiveTabBG = Color3.fromRGB(100, 65, 30),
		ActiveTabBorder = Color3.fromRGB(150, 100, 50),
		DefaultTabBG = Color3.fromRGB(70, 45, 25),
		DefaultTabBorder = Color3.fromRGB(100, 65, 30),
		CloseButtonBG = Color3.fromRGB(180, 50, 50),
		CloseButtonText = Color3.fromRGB(255, 255, 255),
		CloseButtonBorder = Color3.fromRGB(220, 70, 70),
		CloseButtonBGHover = Color3.fromRGB(200, 60, 60),
		WatermarkText = Color3.fromRGB(150, 120, 90),
		ScrollBar = Color3.fromRGB(100, 65, 30),
		TextDisabled = Color3.fromRGB(120,120,120),
		TextBoxBG = Color3.fromRGB(35, 25, 10),
		TextBoxText = Color3.fromRGB(230, 210, 190),
		TextBoxBorder = Color3.fromRGB(80, 55, 25),
		TextBoxPlaceholderText = Color3.fromRGB(100, 80, 60),
	},
	LightMode = {
		Name = "Light Mode",
		MainFrameBG = Color3.fromRGB(235, 235, 225),
		MainFrameBorder = Color3.fromRGB(190, 190, 170),
		TitleBarBG = Color3.fromRGB(220, 220, 200),
		TitleBarText = Color3.fromRGB(50, 50, 50),
		TabFrameBG = Color3.fromRGB(210, 210, 190),
		ContentFrameBG = Color3.fromRGB(225, 225, 215),
		ButtonBG = Color3.fromRGB(170, 180, 190),
		ButtonText = Color3.fromRGB(20, 20, 20),
		ButtonBorder = Color3.fromRGB(140, 150, 160),
		ButtonBGHover = Color3.fromRGB(190, 200, 210),
		ButtonTextHover = Color3.fromRGB(10, 10, 10),
		ButtonBorderHover = Color3.fromRGB(160, 170, 180),
		ActiveTabBG = Color3.fromRGB(170, 180, 190),
		ActiveTabBorder = Color3.fromRGB(140, 150, 160),
		DefaultTabBG = Color3.fromRGB(190, 200, 210),
		DefaultTabBorder = Color3.fromRGB(160, 170, 180),
		CloseButtonBG = Color3.fromRGB(220, 80, 80),
		CloseButtonText = Color3.fromRGB(255, 255, 255),
		CloseButtonBorder = Color3.fromRGB(240, 100, 100),
		CloseButtonBGHover = Color3.fromRGB(230, 90, 90),
		WatermarkText = Color3.fromRGB(100, 100, 100),
		ScrollBar = Color3.fromRGB(180, 180, 160),
		TextDisabled = Color3.fromRGB(150,150,150),
		TextBoxBG = Color3.fromRGB(245, 245, 235),
		TextBoxText = Color3.fromRGB(30, 30, 30),
		TextBoxBorder = Color3.fromRGB(190, 190, 170),
		TextBoxPlaceholderText = Color3.fromRGB(150, 150, 130),
	}
}
local currentThemeName = "DarkBrown"

local MainFrame, TitleBarFrame, TitleLabel, TabFrame, ContentFrame, CloseButton
local TabButtons = {}
local Tabs = {"Universal", "Emotes", "Game Specific", "Local Executor", "Settings"} 
local CurrentTab = Tabs[1]

local noclipActive = false
local noclipConnection = nil

local LoadUniversalScripts, LoadEmotes, LoadGameSpecific, LoadLocalExecutor, LoadSettings

local function ClearContentFramePreservingLayout(frame)
	local childrenToKeep = {}
	for _, child in frame:GetChildren() do
		if child:IsA("UIListLayout") or child:IsA("UIPadding") then

		else
			child:Destroy()
		end
	end
end

local function ApplyTheme(themeNameKey)
	local theme = themes[themeNameKey]
	if not theme then return end
	currentThemeName = themeNameKey

	if MainFrame then
		MainFrame.BackgroundColor3 = theme.MainFrameBG
		MainFrame:FindFirstChildOfClass("UIStroke").Color = theme.MainFrameBorder
	end
	if TitleBarFrame then
		TitleBarFrame.BackgroundColor3 = theme.TitleBarBG
		if TitleLabel then TitleLabel.TextColor3 = theme.TitleBarText end
		local titleBottomBlock = TitleBarFrame:FindFirstChild("TitleBottomBlock")
		if titleBottomBlock then titleBottomBlock.BackgroundColor3 = theme.TitleBarBG end
	end
	if TabFrame then
		TabFrame.BackgroundColor3 = theme.TabFrameBG
	end
	if ContentFrame then
		ContentFrame.BackgroundColor3 = theme.ContentFrameBG
		ContentFrame.ScrollBarImageColor3 = theme.ScrollBar
		local contentTopBlock = ContentFrame:FindFirstChild("ContentTopBlock")
		if contentTopBlock then contentTopBlock.BackgroundColor3 = theme.ContentFrameBG end
	end
	if CloseButton then
		CloseButton.BackgroundColor3 = theme.CloseButtonBG
		CloseButton.TextColor3 = theme.CloseButtonText
		CloseButton:FindFirstChildOfClass("UIStroke").Color = theme.CloseButtonBorder
	end

	for name, btn in TabButtons do
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if name == CurrentTab then
			btn.BackgroundColor3 = theme.ActiveTabBG
			if stroke then stroke.Color = theme.ActiveTabBorder end
		else
			btn.BackgroundColor3 = theme.DefaultTabBG
			if stroke then stroke.Color = theme.DefaultTabBorder end
		end
		btn.TextColor3 = theme.ButtonText
	end

	if CurrentTab and ContentFrame then
		ClearContentFramePreservingLayout(ContentFrame)
		if not ContentFrame:FindFirstChildOfClass("UIListLayout") then
			local listLayout = Instance.new("UIListLayout")
			listLayout.Padding = UDim.new(0, 8)
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			listLayout.Parent = ContentFrame
		end
		if not ContentFrame:FindFirstChildOfClass("UIPadding") then
			local padding = Instance.new("UIPadding")
			padding.PaddingTop = UDim.new(0, 10)
			padding.PaddingBottom = UDim.new(0, 10)
			padding.Parent = ContentFrame
		end

		if CurrentTab == Tabs[1] and LoadUniversalScripts then LoadUniversalScripts()
		elseif CurrentTab == Tabs[2] and LoadEmotes then LoadEmotes()
		elseif CurrentTab == Tabs[3] and LoadGameSpecific then LoadGameSpecific()
		elseif CurrentTab == Tabs[4] and LoadLocalExecutor then LoadLocalExecutor() 
		elseif CurrentTab == Tabs[5] and LoadSettings then LoadSettings()
		end
	end
end

local function CreateButton(parent, text, callback, isEnabled)
	isEnabled = isEnabled == nil and true or isEnabled
	local theme = themes[currentThemeName]
	local Button = Instance.new("TextButton")
	Button.Name = text .. "Button"
	Button.Size = UDim2.new(0.9, 0, 0, 35)
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 15
	Button.Text = text
	Button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = Button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = Button

	if isEnabled then
		Button.BackgroundColor3 = theme.ButtonBG
		Button.TextColor3 = theme.ButtonText
		stroke.Color = theme.ButtonBorder
		Button.AutoButtonColor = false

		if callback then
			Button.MouseButton1Click:Connect(function() callback(Button) end) 
		end

		Button.MouseEnter:Connect(function()
			Button.BackgroundColor3 = theme.ButtonBGHover
			Button.TextColor3 = theme.ButtonTextHover
			stroke.Color = theme.ButtonBorderHover
		end)
		Button.MouseLeave:Connect(function()
			Button.BackgroundColor3 = theme.ButtonBG
			Button.TextColor3 = theme.ButtonText
			stroke.Color = theme.ButtonBorder
		end)
	else
		Button.BackgroundColor3 = theme.ContentFrameBG
		Button.TextColor3 = theme.TextDisabled
		stroke.Color = theme.ButtonBorder
		Button.Selectable = false
		Button.AutoButtonColor = false
	end

	return Button
end

local function ExecuteScriptFromURL(url, button)
	local originalText = string.match(button.Name, "^(.+)Button$") or "Button"
	if button then button.Text = "Loading..." end
	print("SytherHub: Attempting to load script from URL:", url)

	local success, content = pcall(function() return HttpService:GetAsync(url) end)
	if not success then
		print("SytherHub Error: Failed to fetch script from URL:", url, "-", content)
		if button then button.Text = "Fetch Failed" end
		task.wait(2)
		if button then button.Text = originalText end
		return
	end

	local scriptFunction, compileError = loadstring(content)
	if not scriptFunction then
		print("SytherHub Error: Failed to compile script from URL:", url, "-", compileError)
		if button then button.Text = "Compile Failed" end
		task.wait(2)
		if button then button.Text = originalText end
		return
	end

	local executionSuccess, executionError = pcall(scriptFunction)
	if not executionSuccess then
		print("SytherHub Error: Failed to execute script from URL:", url, "-", executionError)
		if button then button.Text = "Execute Failed" end
	else
		print("SytherHub: Successfully executed script from", url)
		if button then button.Text = "Executed!" end
	end
	task.wait(2)
	if button then button.Text = originalText end
end

local function ExecuteLocalCode(codeString, statusLabel)
	if not codeString or string.gsub(codeString, "%s", "") == "" then
		print("SytherHub: No code to execute.")
		if statusLabel then statusLabel.Text = "No code entered." end
		task.wait(2)
		if statusLabel then statusLabel.Text = "" end
		return
	end

	print("SytherHub: Attempting to execute local code.")
	if statusLabel then statusLabel.Text = "Executing..." end

	local scriptFunction, compileError = loadstring(codeString)
	if not scriptFunction then
		print("SytherHub Error: Failed to compile local code -", compileError)
		if statusLabel then statusLabel.Text = "Compile Failed!" end
		task.wait(2)
		if statusLabel then statusLabel.Text = "" end
		return
	end

	local executionSuccess, executionError = pcall(scriptFunction)
	if not executionSuccess then
		print("SytherHub Error: Failed to execute local code -", executionError)
		if statusLabel then statusLabel.Text = "Execute Failed!" end
	else
		print("SytherHub: Successfully executed local code.")
		if statusLabel then statusLabel.Text = "Executed Successfully!" end
	end
	task.wait(3)
	if statusLabel then statusLabel.Text = "" end
end

MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = MainFrame

TitleBarFrame = Instance.new("Frame")
TitleBarFrame.Name = "TitleBarFrame"
TitleBarFrame.Size = UDim2.new(1, 0, 0, 35)
TitleBarFrame.BackgroundTransparency = 0
TitleBarFrame.Parent = MainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0,8)
titleCorner.Parent = TitleBarFrame
local titleBottomBlock = Instance.new("Frame")
titleBottomBlock.Name = "TitleBottomBlock"
titleBottomBlock.Size = UDim2.new(1,0,0.5,0)
titleBottomBlock.Position = UDim2.new(0,0,0.5,0)
titleBottomBlock.BorderSizePixel = 0
titleBottomBlock.Parent = TitleBarFrame
TitleBarFrame.ClipsDescendants = true

TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0,0,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.TextSize = 16
TitleLabel.Text = "Syther Script Hub"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = TitleBarFrame

CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -33, 0.5, -15)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = TitleBarFrame.ZIndex + 1
CloseButton.Parent = TitleBarFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton
local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 1.5
closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
closeStroke.Parent = CloseButton
CloseButton.AutoButtonColor = false
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui.Enabled = false
	print("UI hidden via close button")
end)
CloseButton.MouseEnter:Connect(function()
	local theme = themes[currentThemeName]
	CloseButton.BackgroundColor3 = theme.CloseButtonBGHover
end)
CloseButton.MouseLeave:Connect(function()
	local theme = themes[currentThemeName]
	CloseButton.BackgroundColor3 = theme.CloseButtonBG
end)

TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, 0, 0, 40)
TabFrame.Position = UDim2.new(0, 0, 0, 35)
TabFrame.BackgroundTransparency = 0
TabFrame.Parent = MainFrame
local tabFrameListLayout = Instance.new("UIListLayout")
tabFrameListLayout.FillDirection = Enum.FillDirection.Horizontal
tabFrameListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabFrameListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabFrameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabFrameListLayout.Padding = UDim.new(0, 5)
tabFrameListLayout.Parent = TabFrame
local tabFramePadding = Instance.new("UIPadding")
tabFramePadding.PaddingLeft = UDim.new(0,5)
tabFramePadding.PaddingRight = UDim.new(0,5)
tabFramePadding.Parent = TabFrame

ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -75)
ContentFrame.Position = UDim2.new(0, 0, 0, 75)
ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
ContentFrame.ScrollBarThickness = 10
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.BackgroundTransparency = 0
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0,8)
contentCorner.Parent = ContentFrame
local contentTopBlock = Instance.new("Frame")
contentTopBlock.Name = "ContentTopBlock"
contentTopBlock.Size = UDim2.new(1,0,0,8)
contentTopBlock.Position = UDim2.new(0,0,0,-8)
contentTopBlock.BorderSizePixel = 0
contentTopBlock.ZIndex = ContentFrame.ZIndex -1
contentTopBlock.Parent = ContentFrame
ContentFrame.ClipsDescendants = true

local contentListLayout = Instance.new("UIListLayout")
contentListLayout.Padding = UDim.new(0, 8)
contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentListLayout.Parent = ContentFrame
local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.Parent = ContentFrame

for i, tabName in Tabs do
	local TabButton = Instance.new("TextButton")
	TabButton.Name = tabName .. "TabButton"

	local availableWidth = MainFrame.AbsoluteSize.X - (tabFramePadding.PaddingLeft.Offset + tabFramePadding.PaddingRight.Offset) - ((#Tabs -1) * tabFrameListLayout.Padding.Offset)
	TabButton.Size = UDim2.new(0, availableWidth / #Tabs , 0, 30)
	TabButton.Font = Enum.Font.GothamSemibold
	TabButton.TextSize = 14
	TabButton.Text = tabName
	TabButton.Parent = TabFrame
	TabButton.AutoButtonColor = false

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = TabButton
	local tabStroke = Instance.new("UIStroke")
	tabStroke.Thickness = 1.5
	tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tabStroke.Parent = TabButton

	TabButton.MouseButton1Click:Connect(function()
		if CurrentTab == tabName then return end
		CurrentTab = tabName
		ApplyTheme(currentThemeName)
	end)
	TabButtons[tabName] = TabButton
end

LoadUniversalScripts = function()
	CreateButton(ContentFrame, "Infinite Yield", function(btn) ExecuteLocalCode("loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()", btn) end)
	CreateButton(ContentFrame, "Fly Script (FE)", function(btn) ExecuteLocalCode("loadstring(game:HttpGet('https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt'))()", btn) end)
	CreateButton(ContentFrame, "Speed Script", function()
		local player = LocalPlayer
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = humanoid.WalkSpeed == 50 and 16 or 50
			print("Speed set to " .. humanoid.WalkSpeed)
		else print("No character or humanoid found") end
	end)

	local noclipButton = CreateButton(ContentFrame, "Noclip (OFF)", function(button)
		noclipActive = not noclipActive
		button.Text = "Noclip (" .. (noclipActive and "ON" or "OFF") .. ")"
		print("Noclip " .. (noclipActive and "enabled" or "disabled"))

		local function SetCharacterCollision(collidable)
			if LocalPlayer.Character then
				for _, part in LocalPlayer.Character:GetDescendants() do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.CanCollide = collidable
					end
				end
			end
		end

		if noclipActive then
			if noclipConnection then noclipConnection:Disconnect() end
			SetCharacterCollision(false)
			noclipConnection = RunService.Stepped:Connect(function() SetCharacterCollision(false) end)
		else
			if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil; end
			SetCharacterCollision(true)
		end
	end)
	noclipButton.Text = "Noclip (" .. (noclipActive and "ON" or "OFF") .. ")"

	CreateButton(ContentFrame, "ESP", function(btn) ExecuteLocalCode("loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()", btn) end)
	CreateButton(ContentFrame, "Aimbot", function(btn) ExecuteLocalCode("loadstring(game:HttpGet('https://pastebin.com/raw/k5nfErmK'))()", btn) end)
end

LoadEmotes = function()
	local emotes = {
		{"Dance", "rbxassetid://3189773368"}, {"Floss", "rbxassetid://5917459365"},
		{"Laugh", "rbxassetid://5915705587"}, {"Wave", "rbxassetid://507770453"},
		{"Cheer", "rbxassetid://507770818"}, {"Point", "rbxassetid://507766995"},
		{"Shrug", "rbxassetid://709099039"}, {"Tilt", "rbxassetid://709100671"},
		{"Stadium", "rbxassetid://709099601"}, {"Salute", "rbxassetid://507769763"},
		{"Strong", "rbxassetid://709100075"}, {"Sleepy", "rbxassetid://709101062"}
	}
	for _, emoteData in emotes do
		CreateButton(ContentFrame, emoteData[1], function()
			local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local currentAnims = humanoid:GetPlayingAnimationTracks()
				for _, track in currentAnims do
					if track.Animation.AnimationId == emoteData[2] then track:Stop() end
				end
				local anim = Instance.new("Animation")
				anim.AnimationId = emoteData[2]
				local track = humanoid:LoadAnimation(anim)
				track:Play()
				anim:Destroy()
				print("Playing " .. emoteData[1])
			else print("No character or humanoid found") end
		end)
	end
end

LoadGameSpecific = function()
	local supportedGames = {
		["Da Hood"] = { PlaceId = 2788229376, Scripts = {
			{Name = "Aimlock", URL = "loadstring(game:HttpGet('https://raw.githubusercontent.com/ImagineProUser/vortexdahood/main/vortex', true))()"},
			{Name = "ESP", URL = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()"},
		}},
		["Arsenal"] = { PlaceId = 286090429, Scripts = { {Name = "Arsenal Aimbot", URL = "loadstring(game:HttpGet('https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt'))()"} } },
		["Blade Ball"] = { PlaceId = 13772394625, Scripts = { {Name = "Auto Parry (Example)", URL = "loadstring(game:HttpGet('https://raw.githubusercontent.com/Akash1al/Blade-Ball-Updated-Script/refs/heads/main/Blade-Ball-Script'))()"} } },
	}
	local detectedGame = nil
	for gameName, gameData in supportedGames do
		if game.PlaceId == gameData.PlaceId then
			detectedGame = gameName
			CreateButton(ContentFrame, "Detected: " .. gameName, nil, false)
			for _, scriptInfo in gameData.Scripts do
				CreateButton(ContentFrame, scriptInfo.Name, function(btn) ExecuteLocalCode(scriptInfo.URL, btn) end)
			end
			break
		end
	end
	if not detectedGame then
		CreateButton(ContentFrame, "Game not specifically supported.", nil, false)
		CreateButton(ContentFrame, "PlaceId: " .. tostring(game.PlaceId), nil, false)
	end
end

LoadLocalExecutor = function()
	local theme = themes[currentThemeName]

	local CodeInputBox = Instance.new("TextBox")
	CodeInputBox.Name = "CodeInputBox"
	CodeInputBox.Size = UDim2.new(0.9, 0, 0.7, -45) 
	CodeInputBox.Font = Enum.Font.Code
	CodeInputBox.TextSize = 14
	CodeInputBox.MultiLine = true
	CodeInputBox.TextWrapped = true
	CodeInputBox.ClearTextOnFocus = false
	CodeInputBox.TextXAlignment = Enum.TextXAlignment.Left
	CodeInputBox.TextYAlignment = Enum.TextYAlignment.Top
	CodeInputBox.PlaceholderText = "Enter your Lua code here..."
	CodeInputBox.BackgroundColor3 = theme.TextBoxBG
	CodeInputBox.TextColor3 = theme.TextBoxText
	CodeInputBox.PlaceholderColor3 = theme.TextBoxPlaceholderText
	CodeInputBox.Parent = ContentFrame

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = CodeInputBox
	local inputStroke = Instance.new("UIStroke")
	inputStroke.Thickness = 1.5
	inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	inputStroke.Color = theme.TextBoxBorder
	inputStroke.Parent = CodeInputBox

	CodeInputBox:GetPropertyChangedSignal("Parent"):Connect(function()
		if CodeInputBox.Parent == nil then return end 
		task.defer(function() 
			local currentThemeData = themes[currentThemeName]
			CodeInputBox.BackgroundColor3 = currentThemeData.TextBoxBG
			CodeInputBox.TextColor3 = currentThemeData.TextBoxText
			CodeInputBox.PlaceholderColor3 = currentThemeData.TextBoxPlaceholderText
			inputStroke.Color = currentThemeData.TextBoxBorder
		end)
	end)

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.TextSize = 13
	StatusLabel.TextColor3 = theme.ButtonText 
	StatusLabel.Text = ""
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
	StatusLabel.Parent = ContentFrame

	StatusLabel:GetPropertyChangedSignal("Parent"):Connect(function()
		if StatusLabel.Parent == nil then return end
		task.defer(function()
			local currentThemeData = themes[currentThemeName]
			StatusLabel.TextColor3 = currentThemeData.ButtonText
		end)
	end)

	CreateButton(ContentFrame, "Execute Code", function()
		ExecuteLocalCode(CodeInputBox.Text, StatusLabel)
	end)

	local listLayout = ContentFrame:FindFirstChildOfClass("UIListLayout")
	if listLayout then

	end
end

LoadSettings = function()
	CreateButton(ContentFrame, "Toggle Theme: " .. themes[currentThemeName == "DarkBrown" and "LightMode" or "DarkBrown"].Name, function(button)
		if currentThemeName == "DarkBrown" then ApplyTheme("LightMode")
		else ApplyTheme("DarkBrown") end
	end)

	CreateButton(ContentFrame, "Unload Syther Hub", function()
		if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil; end
		ScreenGui:Destroy()
		print("Syther Script Hub unloaded!")
	end)
	CreateButton(ContentFrame, "Menu bind: End", nil, false)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.End then
		ScreenGui.Enabled = not ScreenGui.Enabled
		print("UI " .. (ScreenGui.Enabled and "shown" or "hidden"))
		if ScreenGui.Enabled and CurrentTab and ContentFrame then
			local listLayout = ContentFrame:FindFirstChildOfClass("UIListLayout")
			local padding = ContentFrame:FindFirstChildOfClass("UIPadding")
			local childCount = 0
			for _, child in ContentFrame:GetChildren() do
				if child ~= listLayout and child ~= padding then
					childCount = childCount + 1
				end
			end
			if childCount == 0 then
				ApplyTheme(currentThemeName)
			end
		end
	end
end)

task.wait() 
ApplyTheme(currentThemeName)

print("SytherUI Loaded. Press End to toggle.")
