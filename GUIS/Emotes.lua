--[[ 
Source script taken from: https://github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md
If you want to set an emote, I recommend using a source script that was taken from for ease of use only.
Also other scripts, there is no difference them. I just created it if you want from the Roblox coregui menu, emote Easily (almost..).
]]

if _G.EmotesGUIRunning then
	getgenv().Notify({
		Title = '7yd7 | Emote',
		Content = '⚠️ It works It actually works',
		Duration = 5
	})
	return
end
_G.EmotesGUIRunning = true
local emotesWalkEnabled = false 

loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Menu-7yd7/refs/heads/Script/GUIS/Off-site/Notify.lua"))()

getgenv().Notify({
	Title = '7yd7 | Emote',
	Content = '⚠️ Script loading',
	Duration = 5
})

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local emotesData = {}
local currentPage = 1
local itemsPerPage = 8
local totalPages = 1
local filteredEmotes = {}
local isLoading = false
local loadingProgress = 0
local totalEmotesLoaded = 0

local Under, UIListLayout, _1left, _9right, _4pages, _3TextLabel, _2Routenumber, Top, EmoteWalkButton, UICorner1, UIListLayout_2, UICorner, Search
local guiElements = {}
local isGUICreated = false

local emotesWalkEnabled = false
local currentEmoteTrack = nil
local defaultButtonImage = "rbxassetid://71408678974152"
local enabledButtonImage = "rbxassetid://106798555684020"

local function getCharacterAndHumanoid()
	local character = player.Character
	if not character then return nil, nil end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return nil, nil end
	
	return character, humanoid
end

local function checkEmotesMenuExists()
	local coreGui = game:GetService("CoreGui")
	local robloxGui = coreGui:FindFirstChild("RobloxGui")
	if not robloxGui then return false end
	
	local emotesMenu = robloxGui:FindFirstChild("EmotesMenu")
	if not emotesMenu then return false end
	
	local children = emotesMenu:FindFirstChild("Children")
	if not children then return false end
	
	local main = children:FindFirstChild("Main")
	if not main then return false end
	
	local emotesWheel = main:FindFirstChild("EmotesWheel")
	if not emotesWheel then return false end
	
	return true, emotesWheel
end

local function getBackgroundOverlay()
	local success, result = pcall(function()
		return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Back.Background.BackgroundCircleOverlay
	end)
	if success then
		return result
	end
	return nil
end

local function updateGUIColors()
	local backgroundOverlay = getBackgroundOverlay()
	if not backgroundOverlay then return end
	
	local bgColor = backgroundOverlay.BackgroundColor3
	local bgTransparency = backgroundOverlay.BackgroundTransparency
	
	if _1left then
		_1left.ImageColor3 = bgColor
		_1left.ImageTransparency = bgTransparency
	end
	
	if _9right then
		_9right.ImageColor3 = bgColor
		_9right.ImageTransparency = bgTransparency
	end
	
	if _4pages then
		_4pages.TextColor3 = bgColor
		_4pages.TextTransparency = bgTransparency
	end
	
	if _3TextLabel then
		_3TextLabel.TextColor3 = bgColor
		_3TextLabel.TextTransparency = bgTransparency
	end
	
	if _2Routenumber then
		_2Routenumber.TextColor3 = bgColor
		_2Routenumber.TextTransparency = bgTransparency
	end
	
	if Top then
		Top.BackgroundColor3 = bgColor
		Top.BackgroundTransparency = bgTransparency
	end
	
	if EmoteWalkButton then
		EmoteWalkButton.BackgroundColor3 = bgColor
		EmoteWalkButton.BackgroundTransparency = bgTransparency
	end
end

local function createGUIElements()
	local exists, emotesWheel = checkEmotesMenuExists()
	if not exists then
		return false
	end
	
	if emotesWheel:FindFirstChild("Under") then
		emotesWheel.Under:Destroy()
	end
	if emotesWheel:FindFirstChild("Top") then
		emotesWheel.Top:Destroy()
	end
	
	if emotesWheel:FindFirstChild("EmoteWalkButton") then
		emotesWheel.EmoteWalkButton:Destroy()
	end
	
	Under = Instance.new("Frame")
	UIListLayout = Instance.new("UIListLayout")
	_1left = Instance.new("ImageButton")
	_9right = Instance.new("ImageButton")
	_4pages = Instance.new("TextLabel")
	_3TextLabel = Instance.new("TextLabel")
	_2Routenumber = Instance.new("TextBox")
	EmoteWalkButton = Instance.new("ImageButton")
	UICorner1 = Instance.new("UICorner")
	Top = Instance.new("Frame")
	UIListLayout_2 = Instance.new("UIListLayout")
	UICorner = Instance.new("UICorner")
	Search = Instance.new("TextBox")


	Under.Name = "Under"
	Under.Parent = emotesWheel
	Under.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Under.BackgroundTransparency = 1.000
	Under.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Under.BorderSizePixel = 0
	Under.Position = UDim2.new(0.129999995, 0, 1, 0)
	Under.Size = UDim2.new(0.737500012, 0, 0.132499993, 0)

	UIListLayout.Parent = Under
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	_1left.Name = "1left"
	_1left.Parent = Under
	_1left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_1left.BackgroundTransparency = 1.000
	_1left.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_1left.BorderSizePixel = 0
	_1left.Position = UDim2.new(0.0289389063, 0, -0.0849056691, 0)
	_1left.Rotation = 7456.000
	_1left.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
	_1left.Image = "rbxassetid://93111945058621"
	_1left.ImageColor3 = Color3.fromRGB(0, 0, 0)
	_1left.ImageTransparency = 0.400

	_9right.Name = "9right"
	_9right.Parent = Under
	_9right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_9right.BackgroundTransparency = 1.000
	_9right.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_9right.BorderSizePixel = 0
	_9right.Position = UDim2.new(0.0289389063, 0, -0.0849056691, 0)
	_9right.Rotation = 7456.000
	_9right.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
	_9right.Image = "rbxassetid://107938916240738"
	_9right.ImageColor3 = Color3.fromRGB(0, 0, 0)
	_9right.ImageTransparency = 0.400

	_4pages.Name = "4pages"
	_4pages.Parent = Under
	_4pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_4pages.BackgroundTransparency = 1.000
	_4pages.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_4pages.BorderSizePixel = 0
	_4pages.Position = UDim2.new(0.630225062, 0, 0.188679263, 0)
	_4pages.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
	_4pages.Font = Enum.Font.SourceSansBold
	_4pages.Text = "1"
	_4pages.TextColor3 = Color3.fromRGB(0, 0, 0)
	_4pages.TextScaled = true
	_4pages.TextSize = 14.000
	_4pages.TextTransparency = 0.400
	_4pages.TextWrapped = true

	_3TextLabel.Name = "3TextLabel"
	_3TextLabel.Parent = Under
	_3TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_3TextLabel.BackgroundTransparency = 1.000
	_3TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_3TextLabel.BorderSizePixel = 0
	_3TextLabel.Position = UDim2.new(0.363344043, 0, 0.0283018891, 0)
	_3TextLabel.Size = UDim2.new(0.338983059, 0, 0.94339627, 0)
	_3TextLabel.Font = Enum.Font.SourceSansBold
	_3TextLabel.Text = " ------ "
	_3TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	_3TextLabel.TextScaled = true
	_3TextLabel.TextSize = 14.000
	_3TextLabel.TextTransparency = 0.400
	_3TextLabel.TextWrapped = true

	_2Routenumber.Name = "2Route-number"
	_2Routenumber.Parent = Under
	_2Routenumber.Active = true
	_2Routenumber.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_2Routenumber.BackgroundTransparency = 1.000
	_2Routenumber.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_2Routenumber.BorderSizePixel = 0
	_2Routenumber.Position = UDim2.new(0.138263673, 0, 0.0283018891, 0)
	_2Routenumber.Selectable = true
	_2Routenumber.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
	_2Routenumber.Font = Enum.Font.SourceSansBold
	_2Routenumber.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
	_2Routenumber.Text = "1"
	_2Routenumber.TextColor3 = Color3.fromRGB(0, 0, 0)
	_2Routenumber.TextScaled = true
	_2Routenumber.TextSize = 14.000
	_2Routenumber.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	_2Routenumber.TextTransparency = 0.400
	_2Routenumber.TextWrapped = true

	Top.Name = "Top"
	Top.Parent = emotesWheel
	Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Top.BackgroundTransparency = 0.400
	Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Top.BorderSizePixel = 0
	Top.Position = UDim2.new(0.127499998, 0, -0.109999999, 0)
	Top.Size = UDim2.new(0.737500012, 0, 0.0949999914, 0)

	UIListLayout_2.Parent = Top
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	UICorner.CornerRadius = UDim.new(0, 20)
	UICorner.Parent = Top

	Search.Name = "Search"
	Search.Parent = Top
	Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Search.BackgroundTransparency = 1.000
	Search.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Search.Position = UDim2.new(0.0677966103, 0, 0)
	Search.Size = UDim2.new(0.864406765, 0, 0.81578958, 0)
	Search.Font = Enum.Font.SourceSansBold
	Search.PlaceholderText = "Search"
	Search.Text = ""
	Search.TextColor3 = Color3.fromRGB(255, 255, 255)
	Search.TextScaled = true
	Search.TextSize = 14.000
	Search.TextWrapped = true

	EmoteWalkButton.Name = "EmoteWalkButton"
	EmoteWalkButton.Parent = emotesWheel
	EmoteWalkButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	EmoteWalkButton.BackgroundTransparency = 0.400
	EmoteWalkButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	EmoteWalkButton.BorderSizePixel = 0
	EmoteWalkButton.Position = UDim2.new(0.889999986, 0, -0.107500002, 0)
	EmoteWalkButton.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
	EmoteWalkButton.Image = defaultButtonImage

	UICorner1.CornerRadius = UDim.new(0, 10)
	UICorner1.Parent = EmoteWalkButton
	
	connectEvents()
	isGUICreated = true
	updateGUIColors()
	return true
end

local function updatePageDisplay()
	if _4pages and _2Routenumber then
		_4pages.Text = tostring(totalPages)
		_2Routenumber.Text = tostring(currentPage)
	end
end

local function updateEmotes()
	local character, humanoid = getCharacterAndHumanoid()
	if not character or not humanoid then return end
	
	local humanoidDescription = humanoid.HumanoidDescription
	if not humanoidDescription then return end
	
	local emoteTable = {}
	local equippedEmotes = {}

	local startIndex = (currentPage - 1) * itemsPerPage + 1
	local endIndex = math.min(startIndex + itemsPerPage - 1, #filteredEmotes)

	for i = startIndex, endIndex do
		if filteredEmotes[i] then
			local emoteName = filteredEmotes[i].name
			local emoteId = filteredEmotes[i].id
			emoteTable[emoteName] = {emoteId}
			table.insert(equippedEmotes, emoteName)
		end
	end

	humanoidDescription:SetEmotes(emoteTable)
	humanoidDescription:SetEquippedEmotes(equippedEmotes)
end

local function updatePagesWhileLoading()
	if #emotesData > 0 then
		filteredEmotes = emotesData
		totalPages = math.ceil(#filteredEmotes / itemsPerPage)
		if totalPages == 0 then
			totalPages = 1
		end
		updatePageDisplay()
		updateEmotes()
	end
end

local function fetchAllEmotes()
	if isLoading then
		return
	end
	isLoading = true
	emotesData = {}
	totalEmotesLoaded = 0
	
	local success, result = pcall(function()
		local response = syn and syn.request or request
		local requestData = {
			Url = "https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/EmoteSniper.json",
			Method = "GET",
			Headers = {
				["content-type"] = "application/json",
				["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
			}
		}
		local apiResponse = response(requestData)
		if apiResponse.StatusCode == 200 then
			local data = HttpService:JSONDecode(apiResponse.Body)
			return data.data or {}
		else
			return nil
		end
	end)
	
	if success and result then
		for _, item in pairs(result) do
			local emoteData = {
				id = tonumber(item.id),
				name = item.name or ("Emote_" .. (item.id or "Unknown"))
			}
			if emoteData.id and emoteData.id > 0 then
				table.insert(emotesData, emoteData)
				totalEmotesLoaded = totalEmotesLoaded + 1
			end
		end
	else
		emotesData = {{
			id = 3360686498,
			name = "Stadium"
		}, {
			id = 3360692915,
			name = "Tilt"
		}, {
			id = 3576968026,
			name = "Shrug"
		}, {
			id = 3360689775,
			name = "Salute"
		}}
		totalEmotesLoaded = #emotesData
	end
	
	filteredEmotes = emotesData
	totalPages = math.ceil(#filteredEmotes / itemsPerPage)
	currentPage = 1
	updatePageDisplay()
	updateEmotes()
	getgenv().Notify({
		Title = '7yd7 | Emote',
		Content = "🎉 Loaded Successfully! Total Emotes: " .. totalEmotesLoaded,
		Duration = 5
	})
	isLoading = false
end

local function searchEmotes(searchTerm)
	if isLoading then
		getgenv().Notify({
			Title = '7yd7 | Emote',
			Content = '⚠️ Loading please wait',
			Duration = 5
		})
		return
	end

	if searchTerm == "" then
		filteredEmotes = emotesData
	else
		filteredEmotes = {}
		searchTerm = searchTerm:lower()
		for _, emote in pairs(emotesData) do
			if emote.name:lower():find(searchTerm) then
				table.insert(filteredEmotes, emote)
			end
		end
	end

	totalPages = math.ceil(#filteredEmotes / itemsPerPage)
	if totalPages == 0 then
		totalPages = 1
	end
	currentPage = 1
	updatePageDisplay()
	updateEmotes()
end

local function goToPage(pageNumber)
	if pageNumber < 1 then
		currentPage = 1
	elseif pageNumber > totalPages then
		currentPage = totalPages
	else
		currentPage = pageNumber
	end
	updatePageDisplay()
	updateEmotes()
end

local function previousPage()
	if currentPage <= 1 then
		currentPage = totalPages
	else
		currentPage = currentPage - 1
	end
	updatePageDisplay()
	updateEmotes()
end

local function nextPage()
	if currentPage >= totalPages then
		currentPage = 1
	else
		currentPage = currentPage + 1
	end
	updatePageDisplay()
	updateEmotes()
end


local currentCharacter = nil

local function urlToId(animationId)
	animationId = string.gsub(animationId, "http://www%.roblox%.com/asset/%?id=", "")
	animationId = string.gsub(animationId, "rbxassetid://", "")
	return animationId
end

local function isGivenAnimation(animationHolder, animationId)
	for _, animation in animationHolder:GetChildren() do
		if animation:IsA("Animation") and urlToId(animation.AnimationId) == animationId then
			return true
		end
	end
	return false
end

local function isDancing(character, animationTrack)
	local animationId = urlToId(animationTrack.Animation.AnimationId)
	for _, animationHolder in character.Animate:GetChildren() do
		if animationHolder:IsA("StringValue") then
			local sharesAnimationId = isGivenAnimation(animationHolder, animationId)
			if sharesAnimationId then
				return false
			end
		end
	end
	return true
end

local function stopCurrentEmote()
	if currentEmoteTrack then
		currentEmoteTrack:Stop()
		currentEmoteTrack:Destroy()
		currentEmoteTrack = nil
	end
end

local function onCharacterAdded(character)
	currentCharacter = character
	
	stopCurrentEmote()
	
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	animator.AnimationPlayed:Connect(function(animationTrack)
		if isDancing(character, animationTrack) and emotesWalkEnabled then
			local emoteId = urlToId(animationTrack.Animation.AnimationId)
			
			if currentEmoteTrack then
				local currentEmoteId = urlToId(currentEmoteTrack.Animation.AnimationId)
				if currentEmoteId == emoteId then
					return
				else
					stopCurrentEmote()
				end
			end
			
			
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://" .. emoteId
			
			currentEmoteTrack = humanoid:LoadAnimation(animation)
			currentEmoteTrack.Priority = Enum.AnimationPriority.Action
			currentEmoteTrack.Looped = true
			currentEmoteTrack:Play()
			currentEmoteTrack:AdjustSpeed(1)
			
			currentEmoteTrack.Ended:Connect(function()
				if currentEmoteTrack == animationTrack then
					currentEmoteTrack = nil

				end
			end)
		else
			if not emotesWalkEnabled then
			end
		end
	end)
	
	humanoid.Died:Connect(function()
		stopCurrentEmote()
	end)
end

local function toggleEmoteWalk()
	emotesWalkEnabled = not emotesWalkEnabled
	
	if emotesWalkEnabled then
         getgenv().Notify({
                Title = '7yd7 | Emote',
                Content = '🔒 Emote freeze ON',
                Duration = 3
            })
        EmoteWalkButton.Image = enabledButtonImage
	else
		  getgenv().Notify({
                Title = '7yd7 | Emote',
                Content = '🔓 Emote freeze OFF',
                Duration = 3
            })
        EmoteWalkButton.Image = defaultButtonImage
		stopCurrentEmote()
	end
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)


function connectEvents()
	if _1left then
		_1left.MouseButton1Click:Connect(previousPage)
	end
	
	if _9right then
		_9right.MouseButton1Click:Connect(nextPage)
	end
	
	if _2Routenumber then
		_2Routenumber.FocusLost:Connect(function(enterPressed)
			local pageNum = tonumber(_2Routenumber.Text)
			if pageNum then
				goToPage(pageNum)
			else
				_2Routenumber.Text = tostring(currentPage)
			end
		end)
	end
	
	if Search then
		Search.Changed:Connect(function(property)
			if property == "Text" then
				searchEmotes(Search.Text)
			end
		end)
	end
	
	if EmoteWalkButton then
		EmoteWalkButton.MouseButton1Click:Connect(toggleEmoteWalk)
	end
end

local function checkAndRecreateGUI()
	local exists, emotesWheel = checkEmotesMenuExists()
	if not exists then
		isGUICreated = false
		return
	end
	
	if not emotesWheel:FindFirstChild("Under") or not emotesWheel:FindFirstChild("Top") or not emotesWheel:FindFirstChild("EmoteWalkButton") then
		isGUICreated = false
		if createGUIElements() then
			updatePageDisplay()
			updateEmotes()
		end
	end
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(function(character)
	onCharacterAdded(character)
	wait(0.3)
	spawn(function()
		while not checkEmotesMenuExists() do
			wait(0.1)
		end
		wait(0.3)
		if createGUIElements() then
			if #emotesData > 0 then
				updatePageDisplay()
				updateEmotes()
			end
		end
	end)
end)

local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
	if not isGUICreated then
		checkAndRecreateGUI()
	else
		updateGUIColors()
	end
end)

spawn(function()
	while not checkEmotesMenuExists() do
		wait(0.1)
	end
	if createGUIElements() then
		fetchAllEmotes()
	end
end)
