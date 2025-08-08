--[[ 
Source script taken from: https://github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md
If you want to set an emote, I recommend using a source script that was taken from for ease of use only.
Also, UGC emote does not work. It uses an API (apparently old) with this script.
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
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidDescription = humanoid.HumanoidDescription

local emotesData = {}
local currentPage = 1
local itemsPerPage = 8
local totalPages = 1
local filteredEmotes = {}
local isLoading = false
local loadingProgress = 0
local totalEmotesLoaded = 0

local Under = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local _1left = Instance.new("ImageButton")
local _9right = Instance.new("ImageButton")
local _4pages = Instance.new("TextLabel")
local _3TextLabel = Instance.new("TextLabel")
local _2Routenumber = Instance.new("TextBox")
local Top = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")
local Search = Instance.new("TextBox")

Under.Name = "Under"
Under.Parent = game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel
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
Top.Parent = game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel
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

local function updatePageDisplay()
    _4pages.Text = tostring(totalPages)
    _2Routenumber.Text = tostring(currentPage)
end

local function updateEmotes()
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
    local alternativeUrls = {"https://catalog.roblox.com/v1/search/items?category=12&subcategory=39&limit=30" ..
        (cursor and ("&cursor=" .. cursor) or "")}

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
                    data = data.data or data.Results or {},
                    nextPageCursor = data.nextPageCursor or data.NextPageCursor
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
    local maxPages = 100

    repeat
        pageCount = pageCount + 1

        local response = fetchSinglePage(cursor)

        if response and response.data then
            for _, item in pairs(response.data) do
                local emoteData = {
                    id = tonumber(item.id) or tonumber(item.assetId) or tonumber(item.AssetId),
                    name = item.name or item.Name or item.displayName or item.DisplayName or
                        ("Emote_" .. (item.id or item.assetId or "Unknown"))
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

_1left.MouseButton1Click:Connect(previousPage)

_9right.MouseButton1Click:Connect(nextPage)

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

Search.Changed:Connect(function(property)
    if property == "Text" then
        searchEmotes(Search.Text)
    end
end)

spawn(function()
    fetchAllEmotes()
end)
