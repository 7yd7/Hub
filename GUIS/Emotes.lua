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

local Under, UIListLayout, _1left, _9right, _4pages, _3TextLabel, _2Routenumber, Top, UIListLayout_2, UICorner, Search
local guiElements = {}
local isGUICreated = false

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
    
    Under = Instance.new("Frame")
    UIListLayout = Instance.new("UIListLayout")
    _1left = Instance.new("ImageButton")
    _9right = Instance.new("ImageButton")
    _4pages = Instance.new("TextLabel")
    _3TextLabel = Instance.new("TextLabel")
    _2Routenumber = Instance.new("TextBox")
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
    Search.Position = UDim2.new(0.0677966103, 0, 0, 0)
    Search.Size = UDim2.new(0.864406765, 0, 0.81578958, 0)
    Search.Font = Enum.Font.SourceSansBold
    Search.PlaceholderText = "Search"
    Search.Text = ""
    Search.TextColor3 = Color3.fromRGB(255, 255, 255)
    Search.TextScaled = true
    Search.TextSize = 14.000
    Search.TextWrapped = true
    
    connectEvents()
    isGUICreated = true
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

local function fetchSinglePage(cursor)
    local alternativeUrls = {"https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/EmoteSniper.json"}
    for i, url in ipairs(alternativeUrls) do
        local success, result = pcall(function()
            local response = syn and syn.request or request
            local requestData = {
                Url = url,
                Method = "GET",
                Headers = {
                    ["content-type"] = "application/json",
                    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                }
            }
            local apiResponse = response(requestData)
            if apiResponse.StatusCode == 200 then
                local data = HttpService:JSONDecode(apiResponse.Body)
                return {
                    data = data.data or {},
                    nextPageCursor = nil
                }
            else
                getgenv().Notify({
                    Title = '7yd7 | Emote',
                    Content = '⚠️ URL ' .. i .. ' to fail: ' .. apiResponse.StatusCode,
                    Duration = 5
                })
                return nil
            end
        end)
        if success and result then
            return result
        else
            getgenv().Notify({
                Title = '7yd7 | Emote',
                Content = "❌ URL error " .. i .. ": " .. tostring(result),
                Duration = 5
            })
        end
    end
    return nil
end

local function fetchAllEmotes()
    if isLoading then
        return
    end
    isLoading = true
    emotesData = {}
    totalEmotesLoaded = 0
    local cursor = nil
    local pageCount = 0
    local maxPages = 1 
    
    repeat
        pageCount = pageCount + 1
        local response = fetchSinglePage(cursor)
        if response and response.data then
            for _, item in pairs(response.data) do
                local emoteData = {
                    id = tonumber(item.id),
                    name = item.name or ("Emote_" .. (item.id or "Unknown"))
                }
                if emoteData.id and emoteData.id > 0 then
                    table.insert(emotesData, emoteData)
                    totalEmotesLoaded = totalEmotesLoaded + 1
                    if totalEmotesLoaded % 10 == 0 then
                        wait(0.1)
                    end
                end
            end
            cursor = response.nextPageCursor
        else
            cursor = nil
        end
        wait(0.1)
    until not cursor or pageCount >= maxPages
    
    if #emotesData == 0 then
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
    if isLoading then
        return
    end

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
    if isLoading then
        return
    end

    if currentPage <= 1 then
        currentPage = totalPages
    else
        currentPage = currentPage - 1
    end
    updatePageDisplay()
    updateEmotes()
end

local function nextPage()
    if isLoading then
        return
    end

    if currentPage >= totalPages then
        currentPage = 1
    else
        currentPage = currentPage + 1
    end
    updatePageDisplay()
    updateEmotes()
end

function connectEvents()
    if _1left then
        _1left.MouseButton1Click:Connect(previousPage)
    end
    
    if _9right then
        _9right.MouseButton1Click:Connect(nextPage)
    end
    
    if _2Routenumber then
        _2Routenumber.FocusLost:Connect(function(enterPressed)
            if isLoading then
                return
            end

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
end

local function checkAndRecreateGUI()
    local exists, emotesWheel = checkEmotesMenuExists()
    if not exists then
        isGUICreated = false
        return
    end
    
    if not emotesWheel:FindFirstChild("Under") or not emotesWheel:FindFirstChild("Top") then
        isGUICreated = false
        if createGUIElements() then
            updatePageDisplay()
            updateEmotes()
        end
    end
end

player.CharacterAdded:Connect(function(character)
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
