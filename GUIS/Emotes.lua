--[[ 
    Source script taken from: https://github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md

    scriptblox: https://scriptblox.com/script/Universal-Script-7yd7-I-Emote-Script-48024
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

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local request = http_request or (syn and syn.request) or request

local State = {
    currentMode = "emote",
    emotesWalkEnabled = false,
    favoriteEnabled = false,
    hudEditorActive = false,
    speedEmoteEnabled = false,
    isLoading = false,
    favoriteSetVersion = 0,
    favoriteSetBuiltVersion = -1,
    emoteCacheVersion = 0,
    animationCacheVersion = 0,
    isGUICreated = false,
    isMonitoringClicks = false,
    lastRadialActionTime = 0,
    lastWheelVisibleTime = 0,
    lastActionTick = 0,
    totalEmotesLoaded = 0,
    currentPage = 1,
    totalPages = 1,
    itemsPerPage = 8,
    emoteSearchTerm = "",
    animationSearchTerm = "",
    currentEmoteTrack = nil,
    currentCharacter = nil,
    emoteClickConnections = {},
    guiConnections = {},
    currentTimer = nil,
    animationsData = {},
    originalAnimationsData = {},
    filteredAnimations = {},
    favoriteAnimations = {},
    favoriteAnimationsFileName = "FavoriteAnimations.json",
    emotesData = {},
    originalEmotesData = {},
    filteredEmotes = {},
    scannedEmotes = {},
    favoriteEmotes = {},
    favoriteFileName = "FavoriteEmotes.json",
    speedEmoteConfigFile = "SpeedEmoteConfig.json",
    favoriteEmoteSet = {},
    favoriteAnimationSet = {},
    emotePageCache = { version = nil, normal = {}, favorites = {} },
    animationPageCache = { version = nil, normal = {}, favorites = {} },
    defaultButtonImage = "rbxassetid://71408678974152",
    enabledButtonImage = "rbxassetid://106798555684020",
    favoriteIconId = "rbxassetid://97307461910825",
    notFavoriteIconId = "rbxassetid://124025954365505",
    EmoteTheme = nil,
    isApplyingTheme = false
}

local UI = {
    Under = nil, 
    _1left = nil, 
    _9right = nil, 
    _4pages = nil, 
    _3TextLabel = nil, 
    _2Routenumber = nil, 
    Top = nil, 
    EmoteWalkButton = nil,
    Search = nil, 
    Favorite = nil, 
    SpeedEmote = nil, 
    SpeedBox = nil, 
    Changepage = nil,
    Reload = nil,
    Background = nil
}

local HUD = {
    Connections = {},
    Strokes = {},
    Overlay = nil,
    ForceVisibleConn = nil,
    DefaultPositions = {
        Top = UDim2.new(0.127499998, 0, -0.109999999, 0),
        Under = UDim2.new(0.129999995, 0, 1, 0),
        EmoteWalkButton = UDim2.new(0.889999986, 0, -0.107500002, 0),
        Favorite = UDim2.new(0.0189999994, 0, -0.108000003, 0),
        SpeedEmote = UDim2.new(0.888999999, 0, 0, 0),
        SpeedBox = UDim2.new(0.0189999398, 0, -0.000499992399, 0),
        Changepage = UDim2.new(0.019, 0, 1.021, 0),
        Reload = UDim2.new(0.888999999, 0, 1.02100003, 0),
    }
}

local function SafeLoad(url, name)
    local success, content
    for i = 1, 3 do
        success, content = pcall(function() return game:HttpGet(url) end)
        if success and content and content ~= "" then break end
        task.wait(0.5)
    end
    
    if not success or not content or content == "" then
        getgenv().Notify({
            Title = '7yd7 | Error',
            Content = 'Failed to download ' .. (name or "script") .. ' after 3 attempts.',
            Duration = 5
        })
        return function() end
    end

    local func, err = loadstring(content)
    if not func then
        warn("7yd7 | SafeLoad: Failed to parse " .. (name or "script") .. ": " .. tostring(err))
        return function() end
    end

    local ok, res = pcall(func)
    if not ok then
        warn("7yd7 | SafeLoad: Error executing " .. (name or "script") .. ": " .. tostring(res))
        return function() end
    end
    return res
end

SafeLoad("https://raw.githubusercontent.com/7yd7/Menu-7yd7/refs/heads/Script/GUIS/Off-site/Notify.lua", "Notify System")

local function GetAsset(asset)
    if not asset or asset == "" then return "" end
    local assetStr = tostring(asset)
    
    _G.AssetCache = _G.AssetCache or {}
    if _G.AssetCache[assetStr] then return _G.AssetCache[assetStr] end

    if not assetStr:find("://") and tonumber(assetStr) then
        local id = "rbxassetid://" .. assetStr
        _G.AssetCache[assetStr] = id
        return id
    end
    
    if assetStr:find("rbxassetid://") or assetStr:find("rbxasset://") or assetStr:find("rbxthumb://") then
        return assetStr
    end
    
    if assetStr:find("http") then
        local targetUrl = assetStr
        if targetUrl:find("github.com") and targetUrl:find("/blob/") then
            targetUrl = targetUrl:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
        end

        local filename = targetUrl:match("([^/]+)$") or "asset.png"
        filename = filename:match("([^%?]+)") or filename
        if not filename:find("%.") then filename = filename .. ".png" end
        filename = filename:gsub("[%c%s%*%?%\"%<%>%|]", "_")
        
        local path = "7yd7/Assets/" .. filename
        
        if isfile(path) then
            local success, result = pcall(function() return getcustomasset(path) end)
            if success and result then
                _G.AssetCache[assetStr] = result
                return result
            end
        else
            if not isfolder("7yd7/Assets") then 
                pcall(function()
                    if not isfolder("7yd7") then makefolder("7yd7") end
                    makefolder("7yd7/Assets") 
                end)
            end
            
            local success, content = pcall(function() return game:HttpGet(targetUrl) end)
            if success and content and content ~= "" then
                local low = content:sub(1, 100):lower()
                if low:find("<!doctype") or low:find("<html") or low:find("<head") then
                    warn("7yd7 | GetAsset: Downloaded content appears to be HTML. Link might be incorrect: " .. targetUrl)
                    return ""
                end
                
                pcall(function() writefile(path, content) end)
                task.wait(0.2) 
                
                local s, result = pcall(function() return getcustomasset(path) end)
                if s and result then
                    _G.AssetCache[assetStr] = result
                    return result
                end
            end
        end
    end
    
    return assetStr
end

local function NormalizeUrl(url)
    if not url or url == "" then return url end
    local targetUrl = tostring(url)
    if targetUrl:find("github.com") and targetUrl:find("/blob/") then
        targetUrl = targetUrl:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
    end
    return targetUrl
end

local DEFAULT_WHEEL_BG = "rbxasset://textures/ui/Emotes/Large/SegmentedCircle.png"
local wheelImgState = setmetatable({}, { __mode = "k" })
local checkEmotesMenuExists

local function SetWheelImageMode(bgImg, isCustom)
    if not bgImg then return end
    if not wheelImgState[bgImg] then
        wheelImgState[bgImg] = {
            ScaleType = bgImg.ScaleType,
            SliceCenter = bgImg.SliceCenter,
            SliceScale = bgImg.SliceScale
        }
    end

    if isCustom then
        bgImg.ScaleType = Enum.ScaleType.Stretch
        bgImg.SliceCenter = Rect.new(0, 0, 0, 0)
        bgImg.SliceScale = 1
    else
        local st = wheelImgState[bgImg]
        if st then
            bgImg.ScaleType = st.ScaleType
            bgImg.SliceCenter = st.SliceCenter
            bgImg.SliceScale = st.SliceScale
        end
    end
end

local function ParseGifInfo(bytes)
    if not bytes or #bytes < 13 then return nil end
    if bytes:sub(1, 3) ~= "GIF" then return nil end
    local function u16le(pos)
        local b1 = bytes:byte(pos) or 0
        local b2 = bytes:byte(pos + 1) or 0
        return b1 + b2 * 256
    end
    local width = u16le(7)
    local height = u16le(9)
    local packed = bytes:byte(11) or 0
    local gctFlag = bit32.band(packed, 0x80) ~= 0
    local gctSize = bit32.band(packed, 0x07)
    local offset = 13
    if gctFlag then
        offset = offset + (3 * (2 ^ (gctSize + 1)))
    end

    local frames = 0
    local delays = {}
    local pendingDelay = nil

    local function skipSubBlocks(pos)
        while pos <= #bytes do
            local size = bytes:byte(pos) or 0
            pos = pos + 1
            if size == 0 then
                break
            end
            pos = pos + size
        end
        return pos
    end

    while offset <= #bytes do
        local b = bytes:byte(offset)
        if not b then break end
        if b == 0x3B then
            break
        elseif b == 0x21 then
            local label = bytes:byte(offset + 1) or 0
            if label == 0xF9 then
                local delay = u16le(offset + 4)
                pendingDelay = delay
                offset = offset + 8
            else
                offset = skipSubBlocks(offset + 2)
            end
        elseif b == 0x2C then
            frames = frames + 1
            if pendingDelay then
                table.insert(delays, pendingDelay)
                pendingDelay = nil
            end
            local packedImg = bytes:byte(offset + 9) or 0
            local lctFlag = bit32.band(packedImg, 0x80) ~= 0
            local lctSize = bit32.band(packedImg, 0x07)
            offset = offset + 10
            if lctFlag then
                offset = offset + (3 * (2 ^ (lctSize + 1)))
            end
            offset = offset + 1
            offset = skipSubBlocks(offset)
        else
            offset = offset + 1
        end
    end

    local totalDelay = 0
    for _, d in ipairs(delays) do
        totalDelay = totalDelay + d
    end
    local avgDelay = (#delays > 0) and (totalDelay / #delays) or 10

    return {
        width = width,
        height = height,
        frames = frames > 0 and frames or #delays,
        totalDelayCs = totalDelay,
        avgDelayCs = avgDelay
    }
end

local function ParsePngInfo(bytes)
    if not bytes or #bytes < 24 then return nil end
    if bytes:sub(1, 8) ~= "\137PNG\r\n\26\n" then return nil end
    local function u32be(pos)
        local b1 = bytes:byte(pos) or 0
        local b2 = bytes:byte(pos + 1) or 0
        local b3 = bytes:byte(pos + 2) or 0
        local b4 = bytes:byte(pos + 3) or 0
        return ((b1 * 256 + b2) * 256 + b3) * 256 + b4
    end
    local width = u32be(17)
    local height = u32be(21)
    if width <= 0 or height <= 0 then return nil end
    return { width = width, height = height }
end

local function LooksLikeGif(src)
    if not src or src == "" then return false end
    local s = tostring(src):lower()
    return s:find("%.gif") or s:find("format=gif") or s:find("image/gif")
end

local wheelGifConnection = nil
local function StopWheelGifAnimation()
    if wheelGifConnection then
        wheelGifConnection:Disconnect()
        wheelGifConnection = nil
    end
end

local function StartWheelGifAnimation(bgImg, data)
    StopWheelGifAnimation()
    if not bgImg or not data or not data.sprite then return end

    local frames = data.frames or 0
    local frameW = data.frameW or 0
    local frameH = data.frameH or 0
    if frames <= 0 or frameW <= 0 or frameH <= 0 then return end

    local cols = data.cols or 0
    if cols <= 0 then
        cols = math.max(1, math.floor(1024 / frameW))
    end
    local delay = data.delay
    if not delay then
        local delayCs = (data.gifInfo and data.gifInfo.avgDelayCs) or 10
        delay = math.max(0.02, (delayCs / 100))
    end

    bgImg.Image = data.sprite
    bgImg.ImageRectSize = Vector2.new(frameW, frameH)

    local current = 0
    local acc = 0
    wheelGifConnection = RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < delay then return end
        acc = 0
        current = (current + 1) % frames
        local x = (current % cols) * frameW
        local y = math.floor(current / cols) * frameH
        bgImg.ImageRectOffset = Vector2.new(x, y)
    end)
end

local WheelAnimCache = {}

local function MakeWheelAnimKey(gifUrl, sheetUrl)
    return tostring(gifUrl or "") .. "|" .. tostring(sheetUrl or "")
end

local function AreWheelAnimMetaEqual(a, b)
    if a == b then return true end
    if not a or not b then return false end
    return a.Enabled == b.Enabled
        and a.FrameHeight == b.FrameHeight
        and a.FrameWidth == b.FrameWidth
        and a.FPS == b.FPS
        and a.Frames == b.Frames
        and a.Cols == b.Cols
        and a.Rows == b.Rows
        and a.GifUrl == b.GifUrl
        and a.SheetUrl == b.SheetUrl
end

local ConfigPath = "7yd7/EmoteSettings.json"
local Config = {
    NotifyEnabled = true,
    SearchVisible = true,
    FavVisible = true,
    ModeVisible = true,
    FreezeVisible = true,
    SpeedVisible = true,
    NavVisible = true,
    EmoteSpeed = 1,
    EmoteSpeedEnabled = false,
    SelectedTheme = "Default",
    EmotePage = 1,
    AnimationPage = 1,
    HUDPositions = {}
}

local function applySavedPositions() end 
local enterHUDEditor, exitHUDEditor

local function ApplyUIVisibility()
    pcall(function()
        if UI.Search and UI.Top then UI.Top.Visible = Config.SearchVisible end
        if UI.Favorite then UI.Favorite.Visible = Config.FavVisible end
        if UI.Changepage then UI.Changepage.Visible = Config.ModeVisible end
        if UI.EmoteWalkButton then UI.EmoteWalkButton.Visible = Config.FreezeVisible end
        if UI.SpeedEmote then UI.SpeedEmote.Visible = Config.SpeedVisible end
        if UI.SpeedBox then 
            UI.SpeedBox.Visible = (Config.SpeedVisible and State.speedEmoteEnabled) 
        end
        if UI.Under then UI.Under.Visible = Config.NavVisible end
        if UI.Reload then 
            UI.Reload.Visible = (State.currentMode == "animation" and Config.NavVisible) 
        end
    end)
end

local function SaveConfig()
    if not isfolder("7yd7") then makefolder("7yd7") end
    writefile(ConfigPath, HttpService:JSONEncode(Config))
end

local function LoadConfig()
    if isfile(ConfigPath) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigPath)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do Config[k] = v end
        end
    end
end
LoadConfig()

local rawNotify = getgenv().Notify
getgenv().Notify = function(data)
    if Config.NotifyEnabled then
        rawNotify(data)
    end
end

local SettingsLib = SafeLoad("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Settings.lua", "Settings Library")

local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "open/Close"
ToggleContainer.Parent = SettingsLib.UI
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Size = UDim2.fromScale(1, 1)
ToggleContainer.ZIndex = 5000
ToggleContainer.Visible = false
ToggleContainer.Active = false
ToggleContainer.Selectable = false

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleSettings"
ToggleBtn.Parent = ToggleContainer
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BackgroundTransparency = 0.4
ToggleBtn.Position = UDim2.new(0, 10, 1, -52)
ToggleBtn.Size = UDim2.fromOffset(42, 42)
ToggleBtn.Image = "rbxassetid://79568054778195"

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

local function getSettingsMainFrame()
    if SettingsLib and SettingsLib.UI then
        return SettingsLib.UI:FindFirstChild("MainFrame")
    end
    return nil
end

local function applySettingsToggleStyle()
    local main = getSettingsMainFrame()
    if main then
        ToggleBtn.BackgroundColor3 = main.BackgroundColor3
    elseif State.EmoteTheme and State.EmoteTheme.Background then
        ToggleBtn.BackgroundColor3 = State.EmoteTheme.Background
    end
end

local function syncToggleVisibility()
    local main = getSettingsMainFrame()
    if main then
        ToggleContainer.Visible = not main.Visible
    else
        ToggleContainer.Visible = true
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    local main = getSettingsMainFrame()
    if main then
        main.Visible = not main.Visible
        syncToggleVisibility()
    else
        SettingsLib.UI.Enabled = not SettingsLib.UI.Enabled
    end
end)

applySettingsToggleStyle()
syncToggleVisibility()

do
    local main = getSettingsMainFrame()
    if main then
        main:GetPropertyChangedSignal("Visible"):Connect(syncToggleVisibility)
    end
end

local GeneralTab = SettingsLib.CreateTab("General", 1)
SettingsLib.AddToggle(GeneralTab, "Show Notifications", "Receive alerts and feedback", Config.NotifyEnabled, function(v)
    Config.NotifyEnabled = v
    SaveConfig()
end)
local ButtonsTab = SettingsLib.CreateTab("Buttons", 2)

SettingsLib.AddToggle(ButtonsTab, "Search Bar", "Show/Hide the search input", Config.SearchVisible, function(v)
    Config.SearchVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

SettingsLib.AddToggle(ButtonsTab, "Favorites Button", "Show/Hide the star button", Config.FavVisible, function(v)
    Config.FavVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

SettingsLib.AddToggle(ButtonsTab, "Mode Switcher", "Show/Hide animation mode button", Config.ModeVisible, function(v)
    Config.ModeVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

SettingsLib.AddToggle(ButtonsTab, "Freeze Button", "Show/Hide emote freeze button", Config.FreezeVisible, function(v)
    Config.FreezeVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

SettingsLib.AddToggle(ButtonsTab, "Speed Button", "Show/Hide the speed controller", Config.SpeedVisible, function(v)
    Config.SpeedVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

SettingsLib.AddToggle(ButtonsTab, "Page Controls", "Show/Hide navigation buttons", Config.NavVisible, function(v)
    Config.NavVisible = v
    ApplyUIVisibility()
    SaveConfig()
end)

local cachedOverlay = nil
local hudEditorItem = SettingsLib.AddItem(GeneralTab, "HUD Editor", "Reposition buttons & UI elements")
local hudEditorBtn = SettingsLib:Create("TextButton", {
    Parent = hudEditorItem,
    BackgroundColor3 = Color3.fromRGB(0, 255, 150),
    Position = UDim2.new(1, -80, 0.5, -12),
    Size = UDim2.new(0, 70, 0, 24),
    Font = Enum.Font.GothamBold,
    Text = "EDIT",
    TextColor3 = Color3.fromRGB(24, 25, 28),
    TextSize = 11
}, { SettingsLib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

hudEditorBtn.MouseButton1Click:Connect(function()
    if enterHUDEditor then enterHUDEditor() end
end)
local function getBackgroundOverlay()
    if cachedOverlay and cachedOverlay.Parent then return cachedOverlay end
    
    local success, result = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Back.Background
                   .BackgroundCircleOverlay
    end)
    if success and result then
        cachedOverlay = result
        return result
    end
    return nil
end

local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function ColorToTable(c) return {math.round(c.R*255), math.round(c.G*255), math.round(c.B*255)} end
local function TableToColor(t)
    if type(t) ~= "table" then
        return Color3.fromRGB(255, 255, 255)
    end
    local r = tonumber(t[1]) or 255
    local g = tonumber(t[2]) or 255
    local b = tonumber(t[3]) or 255
    return Color3.fromRGB(r, g, b)
end

local function GetThemeIconColor(key)
    local theme = State.EmoteTheme
    if theme and theme.IconColors and theme.IconColors[key] then
        return TableToColor(theme.IconColors[key])
    end
    if theme and theme.ImageColor then
        return theme.ImageColor
    end
    return Color3.new(1, 1, 1)
end

local ApplyFavoriteButtonVisual
local function updateGUIColors()
    local backgroundOverlay = getBackgroundOverlay()
    if not backgroundOverlay then
        return
    end

    local theme = State.EmoteTheme
    if not theme then return end
    
    local bgColor = theme.Background
    local accentColor = theme.Accent
    local imgColor = theme.ImageColor
    local bgTransparency = backgroundOverlay.BackgroundTransparency

    local function getIconColor(key)
        if theme.IconColors and theme.IconColors[key] then
            return TableToColor(theme.IconColors[key])
        end
        return imgColor
    end

    if UI._1left then
        UI._1left.ImageColor3 = getIconColor("Left")
        UI._1left.ImageTransparency = bgTransparency
        UI._1left.BackgroundTransparency = 1 
    end

    if UI._9right then
        UI._9right.ImageColor3 = getIconColor("Right")
        UI._9right.ImageTransparency = bgTransparency
        UI._9right.BackgroundTransparency = 1
    end

    if UI._4pages then
        UI._4pages.TextColor3 = bgColor 
        UI._4pages.TextTransparency = bgTransparency
    end

    if UI._3TextLabel then
        UI._3TextLabel.TextColor3 = bgColor
        UI._3TextLabel.TextTransparency = bgTransparency
    end

    if UI._2Routenumber then
        UI._2Routenumber.TextColor3 = bgColor
        UI._2Routenumber.PlaceholderColor3 = bgColor
        UI._2Routenumber.TextTransparency = bgTransparency
    end

    if UI.Top then
        UI.Top.BackgroundColor3 = bgColor
        UI.Top.BackgroundTransparency = bgTransparency
    end

    if UI.EmoteWalkButton then
        UI.EmoteWalkButton.BackgroundColor3 = bgColor
        UI.EmoteWalkButton.BackgroundTransparency = bgTransparency
    end

    if UI.SpeedEmote then
        UI.SpeedEmote.BackgroundColor3 = bgColor
        UI.SpeedEmote.BackgroundTransparency = bgTransparency
    end

     if UI.Changepage then
        UI.Changepage.BackgroundColor3 = bgColor
        UI.Changepage.BackgroundTransparency = bgTransparency
    end

    if UI.SpeedBox then
        UI.SpeedBox.BackgroundColor3 = bgColor
        UI.SpeedBox.BackgroundTransparency = bgTransparency
    end

    if UI.Favorite then
        UI.Favorite.BackgroundColor3 = bgColor
        UI.Favorite.BackgroundTransparency = bgTransparency
    end

    if UI.Reload then
        UI.Reload.BackgroundColor3 = bgColor
        UI.Reload.BackgroundTransparency = bgTransparency
    end
    
    if ApplyFavoriteButtonVisual then
        ApplyFavoriteButtonVisual()
    end
    ApplyUIVisibility()
    applySettingsToggleStyle()
end

ApplyFavoriteButtonVisual = function()
    if not UI.Favorite then return end
    local isOn = State.favoriteEnabled
    local image = isOn and State.favoriteIconId or State.notFavoriteIconId
    if image and image ~= "" then
        UI.Favorite.Image = image
    end
    local colorKey = isOn and "Favorite" or "NotFavorite"
    UI.Favorite.ImageColor3 = GetThemeIconColor(colorKey)
end

-- Optimizing performance: Removed RenderStepped loop
-- game:GetService("RunService").RenderStepped:Connect(function()
--     updateGUIColors()
-- end)

local ThemeTab = SettingsLib.CreateTab("Theme", 3)

local DiscordPromo = SettingsLib.AddItem(ThemeTab, "WANT THEMES?", "Join our Discord for themes!")
DiscordPromo.LayoutOrder = -1

local CopyBtn = SettingsLib:Create("TextButton", {
    Parent = DiscordPromo,
    BackgroundColor3 = Color3.fromRGB(0, 255, 150),
    Position = UDim2.new(1, -95, 0.5, -12),
    Size = UDim2.new(0, 85, 0, 24),
    Font = Enum.Font.GothamBold,
    Text = "COPY LINK",
    TextColor3 = Color3.fromRGB(24, 25, 28),
    TextSize = 11
}, { SettingsLib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

CopyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/kRfzv2kV7X")
    getgenv().Notify({Title = "Discord", Content = "Link copied to clipboard!", Duration = 3})
end)

local ThemeConfigPath = "7yd7/EmoteThemes.json"

local lastSaveTime = 0
local saveDebounce = 1
local pendingSave = false

local function SaveThemesImplementation(themes)
    if not isfolder("7yd7") then makefolder("7yd7") end
    local toSave = { Themes = {}, Order = {}, Selected = currentThemeName }
    
    toSave.Order = themes.Order or {}
    
    for name, data in pairs(themes) do
        if name ~= "Default" and name ~= "Order" and name ~= "Selected" then
            toSave.Themes[name] = data
        end
    end
    writefile(ThemeConfigPath, HttpService:JSONEncode(toSave))
end

local function SaveThemes(themes)
    if pendingSave then 
        pendingSave = "queued"
        return 
    end
    pendingSave = true
    task.delay(0.5, function()
        SaveThemesImplementation(themes)
        local wasQueued = pendingSave == "queued"
        pendingSave = false
        if wasQueued then
            SaveThemes(themes)
        end
    end)
end

local function LoadThemes()
    local defaultTheme = {
        Background = {28, 30, 32},
        Accent = {0, 255, 150},
        ImageColor = {255, 255, 255},
        IconColors = {
            Left = {0, 0, 0},
            Right = {0, 0, 0}
        },
        Icons = {
            Left = "93111945058621",
            Right = "107938916240738",
            Walk = "71408678974152",
            Favorite = "97307461910825",
            NotFavorite = "124025954365505",
            Speed = "116056570415896",
            Page = "13285615740",
            Reload = "127493377027615"
        },
        Wheel = {
            BackgroundImage = "rbxasset://textures/ui/Emotes/Large/SegmentedCircle.png",
            BackgroundImageColor = {255, 255, 255},
            SelectionGradient = "rbxasset://textures/ui/Emotes/Large/SelectedGradient.png",
            SelectionGradientColor = {255, 255, 255},
            SelectionLine = "rbxasset://textures/ui/Emotes/Large/SelectedLine.png",
            SelectionLineColor = {255, 255, 255}
        }
    }
    
    local loaded = { Default = defaultTheme, Order = {"Default"} }
    
    if isfile(ThemeConfigPath) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ThemeConfigPath)) end)
        if success and type(decoded) == "table" then
            local themesTable = decoded.Themes or decoded 
            local orderTable = decoded.Order or {}
            
            for name, data in pairs(themesTable) do
                if not data.Icons then data.Icons = DeepCopy(defaultTheme.Icons) end
                if not data.Wheel then data.Wheel = DeepCopy(defaultTheme.Wheel) end
                loaded[name] = data
                
                if name == "Default" then
                    if not data.IconColors then data.IconColors = {} end
                    data.IconColors.Left = {0, 0, 0}
                    data.IconColors.Right = {0, 0, 0}
                end

                if not decoded.Order and name ~= "Default" then
                    table.insert(loaded.Order, name)
                end
            end
            
            if decoded.Order then
                loaded.Order = {"Default"}
                for _, name in ipairs(decoded.Order) do
                    if name ~= "Default" and loaded[name] then
                        table.insert(loaded.Order, name)
                    end
                end
            end
            
            if decoded.Selected and loaded[decoded.Selected] then
                loaded.Selected = decoded.Selected
            end
            
            return loaded
        end
    end
    return loaded
end

local themes = LoadThemes()
local currentThemeName = Config.SelectedTheme or themes.Selected or "Default"
if not themes[currentThemeName] then currentThemeName = "Default" end

local themeDropdown

local function GetNames()
    local n = {}
    for _, name in ipairs(themes.Order) do
        if themes[name] then table.insert(n, name) end
    end
    for name, _ in pairs(themes) do
        if name ~= "Order" and not table.find(n, name) then
            table.insert(n, name)
        end
    end
    return n
end

local UIElements = {
    Background = {},
    Accent = {},
    ImageColor = {},
    Icons = {},
    Wheel = {}
}

local function ApplyWheelBackgroundImage(bgImg, wheel)
    if not bgImg or not wheel then return end
    local bgSrc = wheel.BackgroundImage or ""
    local isCustomBg = tostring(bgSrc) ~= DEFAULT_WHEEL_BG

    local gifUrl, sheetUrl = nil, nil
    if bgSrc and tostring(bgSrc):find("\n") then
        local lines = {}
        for line in tostring(bgSrc):gmatch("[^\r\n]+") do
            line = line:match("^%s*(.-)%s*$")
            if line ~= "" then table.insert(lines, line) end
        end
        gifUrl = lines[1]
        sheetUrl = lines[2]
    elseif tostring(bgSrc):find("|") then
        local parts = {}
        for part in tostring(bgSrc):gmatch("[^|]+") do
            part = part:match("^%s*(.-)%s*$")
            if part ~= "" then table.insert(parts, part) end
        end
        gifUrl = parts[1]
        sheetUrl = parts[2]
    elseif LooksLikeGif(bgSrc) then
        gifUrl = bgSrc
    end

    local targetUrl = NormalizeUrl(bgSrc)
    if gifUrl then gifUrl = NormalizeUrl(gifUrl) end
    if sheetUrl then sheetUrl = NormalizeUrl(sheetUrl) end

    if gifUrl and sheetUrl and sheetUrl ~= "" then
        local cacheKey = MakeWheelAnimKey(gifUrl, sheetUrl)
        local meta = wheel.Animation
        if meta and meta.GifUrl == gifUrl and meta.SheetUrl == sheetUrl then
            WheelAnimCache[cacheKey] = meta
        else
            meta = WheelAnimCache[cacheKey]
        end

        if meta and meta.Enabled == false then
            local sheetAsset = GetAsset(sheetUrl)
            StopWheelGifAnimation()
            SetWheelImageMode(bgImg, true)
            bgImg.Image = sheetAsset or ""
            bgImg.ImageRectSize = Vector2.new(0, 0)
            bgImg.ImageRectOffset = Vector2.new(0, 0)
            return
        end

        if meta and meta.Enabled == true then
            local sheetAsset = GetAsset(sheetUrl)
            if sheetAsset and sheetAsset ~= "" and (meta.FrameWidth or 0) > 0 and (meta.FrameHeight or 0) > 0 then
                local frames = tonumber(meta.Frames) or 0
                local cols = tonumber(meta.Cols) or 0
                local rows = tonumber(meta.Rows) or 0
                local frameW = tonumber(meta.FrameWidth) or 0
                local frameH = tonumber(meta.FrameHeight) or 0
                local fps = tonumber(meta.FPS) or 10
                local delay = fps > 0 and (1 / fps) or 0.1

                local spriteData = {
                    sprite = sheetAsset,
                    frames = frames,
                    frameW = frameW,
                    frameH = frameH,
                    cols = cols,
                    rows = rows,
                    delay = delay
                }
                SetWheelImageMode(bgImg, true)
                StartWheelGifAnimation(bgImg, spriteData)
                return
            end
        end

        local okGif, gifBytes = pcall(function() return game:HttpGet(gifUrl) end)
        local gifInfo = okGif and gifBytes and ParseGifInfo(gifBytes) or nil

        local okSheet, sheetBytes = pcall(function() return game:HttpGet(sheetUrl) end)
        local sheetInfo = okSheet and sheetBytes and ParsePngInfo(sheetBytes) or nil
        local sheetAsset = GetAsset(sheetUrl)

        if gifInfo and sheetInfo and sheetAsset and sheetAsset ~= "" then
            local frameW = gifInfo.width
            local frameH = gifInfo.height
            local cols = math.max(1, math.floor(sheetInfo.width / frameW))
            local rows = math.max(1, math.floor(sheetInfo.height / frameH))
            local frames = gifInfo.frames or (cols * rows)
            local fps = (gifInfo.avgDelayCs and gifInfo.avgDelayCs > 0) and (100 / gifInfo.avgDelayCs) or 10

            local spriteData = {
                sprite = sheetAsset,
                frames = frames,
                frameW = frameW,
                frameH = frameH,
                cols = cols,
                rows = rows,
                gifInfo = gifInfo
            }
            SetWheelImageMode(bgImg, true)
            StartWheelGifAnimation(bgImg, spriteData)

            local newMeta = {
                Enabled = true,
                FrameWidth = frameW,
                FrameHeight = frameH,
                FPS = math.floor(fps + 0.5),
                Frames = frames,
                Cols = cols,
                Rows = rows,
                GifUrl = gifUrl,
                SheetUrl = sheetUrl
            }
            if not AreWheelAnimMetaEqual(wheel.Animation, newMeta) then
                wheel.Animation = newMeta
                WheelAnimCache[cacheKey] = newMeta
                if currentThemeName and currentThemeName ~= "Default" then
                    SaveThemes(themes)
                end
            end
            return
        else
            StopWheelGifAnimation()
            SetWheelImageMode(bgImg, true)
            bgImg.Image = sheetAsset or ""
            bgImg.ImageRectSize = Vector2.new(0, 0)
            bgImg.ImageRectOffset = Vector2.new(0, 0)

            local newMeta = {
                Enabled = false,
                FrameWidth = 0,
                FrameHeight = 0,
                FPS = 10,
                Frames = 1,
                Cols = 0,
                Rows = 0,
                GifUrl = gifUrl,
                SheetUrl = sheetUrl
            }
            if not AreWheelAnimMetaEqual(wheel.Animation, newMeta) then
                wheel.Animation = newMeta
                WheelAnimCache[cacheKey] = newMeta
                if currentThemeName and currentThemeName ~= "Default" then
                    SaveThemes(themes)
                end
            end
            return
        end
    end

    StopWheelGifAnimation()
    SetWheelImageMode(bgImg, isCustomBg)
    bgImg.Image = GetAsset(targetUrl)
    bgImg.ImageRectSize = Vector2.new(0, 0)
    bgImg.ImageRectOffset = Vector2.new(0, 0)
end

local function ApplyTheme(themeData)
    if State.isApplyingTheme then return end
    State.isApplyingTheme = true
    
    if themeData.Background then
        State.EmoteTheme = {
            Background = TableToColor(themeData.Background),
            Accent = TableToColor(themeData.Accent or {0, 255, 150}),
            ImageColor = TableToColor(themeData.ImageColor or {255, 255, 255}),
            Icons = themeData.Icons or {},
            IconColors = themeData.IconColors or {},
            Wheel = themeData.Wheel or {}
        }
        
        local function getIconColor(key)
            if State.EmoteTheme.IconColors and State.EmoteTheme.IconColors[key] then
                return TableToColor(State.EmoteTheme.IconColors[key])
            end
            return State.EmoteTheme.ImageColor 
        end
        
        State.favoriteIconId = GetAsset(State.EmoteTheme.Icons.Favorite)
        State.notFavoriteIconId = GetAsset(State.EmoteTheme.Icons.NotFavorite)
        
        updateGUIColors()
        
        if UI._1left then UI._1left.Image = GetAsset(State.EmoteTheme.Icons.Left); UI._1left.ImageColor3 = getIconColor("Left") end
        if UI._9right then UI._9right.Image = GetAsset(State.EmoteTheme.Icons.Right); UI._9right.ImageColor3 = getIconColor("Right") end
        if UI.EmoteWalkButton then UI.EmoteWalkButton.Image = GetAsset(State.EmoteTheme.Icons.Walk); UI.EmoteWalkButton.ImageColor3 = getIconColor("Walk") end
        if UI.SpeedEmote then UI.SpeedEmote.Image = GetAsset(State.EmoteTheme.Icons.Speed); UI.SpeedEmote.ImageColor3 = getIconColor("Speed") end
        if UI.Changepage then UI.Changepage.Image = GetAsset(State.EmoteTheme.Icons.Page); UI.Changepage.ImageColor3 = getIconColor("Page") end
        if UI.Reload then UI.Reload.Image = GetAsset(State.EmoteTheme.Icons.Reload); UI.Reload.ImageColor3 = getIconColor("Reload") end
        
        if UI.Favorite then ApplyFavoriteButtonVisual() end 

        
        if UI.Background and UI.Background.Main then UI.Background.Main.SetValue(State.EmoteTheme.Background) end
        
        for key, comp in pairs(UIElements.Icons) do
            local iconVal = State.EmoteTheme.Icons[key] or ""
            local specificColor = State.EmoteTheme.IconColors and State.EmoteTheme.IconColors[key]
            local colorVal
            
            if specificColor then
                colorVal = TableToColor(specificColor)
            else
                colorVal = State.EmoteTheme.ImageColor 
            end
            
            if comp then comp.SetValue(iconVal, colorVal) end
        end

        local function applyWheel()
            pcall(function()
                local root = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
                if not root then return end
                root = root:FindFirstChild("EmotesMenu")
                if not root then return end
                root = root.Children.Main.EmotesWheel.Back.Background
                
                local wheel = State.EmoteTheme.Wheel
                if not wheel then return end

                local function getAsset(id)
                    return GetAsset(id)
                end

                local bgImg = root:FindFirstChild("BackgroundImage")
                if bgImg then
                    ApplyWheelBackgroundImage(bgImg, wheel)
                    bgImg.ImageColor3 = TableToColor(wheel.BackgroundImageColor or {255,255,255})
                end

                local gradContainer = root:FindFirstChild("BackgroundGradient")
                local selectionGrad = gradContainer and gradContainer:FindFirstChild("SelectionGradient")
                local grad = selectionGrad and selectionGrad:FindFirstChild("SelectedGradient")
                if grad then
                    grad.Image = getAsset(wheel.SelectionGradient)
                    grad.ImageColor3 = TableToColor(wheel.SelectionGradientColor or {255,255,255})
                end

                local selection = root:FindFirstChild("Selection")
                local selectionEffect = selection and selection:FindFirstChild("SelectionEffect")
                local line = selectionEffect and selectionEffect:FindFirstChild("SelectedLine")
                if line then
                    line.Image = getAsset(wheel.SelectionLine)
                    line.ImageColor3 = TableToColor(wheel.SelectionLineColor or {255,255,255})
                end
            end)
        end
        applyWheel()

        for key, comp in pairs(UIElements.Wheel) do
            local imgVal = State.EmoteTheme.Wheel[key] or ""
            local colorVal = TableToColor(State.EmoteTheme.Wheel[key.."Color"] or {255, 255, 255})
            if comp then comp.SetValue(imgVal, colorVal) end
        end
    end
    State.isApplyingTheme = false
end

checkEmotesMenuExists = function()
    local coreGui = game:GetService("CoreGui")
    local robloxGui = coreGui:FindFirstChild("RobloxGui")
    if not robloxGui then
        return false
    end

    local emotesMenu = robloxGui:FindFirstChild("EmotesMenu")
    if not emotesMenu then
        return false
    end

    local children = emotesMenu:FindFirstChild("Children")
    if not children then
        return false
    end

    local main = children:FindFirstChild("Main")
    if not main then
        return false
    end

    local emotesWheel = main:FindFirstChild("EmotesWheel")
    if not emotesWheel then
        return false
    end

    return true, emotesWheel
end

task.spawn(function()
    local attempts = 0
    while attempts < 15 do
        local exists = checkEmotesMenuExists()
        if exists then
            ApplyTheme(themes[currentThemeName])
            break
        end
        attempts = attempts + 1
        task.wait(1)
    end
end)

themeDropdown = SettingsLib.AddDropdown(ThemeTab, "Select Theme", GetNames(), currentThemeName, function(v)
    currentThemeName = v
    Config.SelectedTheme = v
    SaveConfig()
    if themes[v] then
        SaveThemes(themes) 
        task.wait(0.1)
        ApplyTheme(themes[v])
    end
end)
if themeDropdown and themeDropdown.Button and themeDropdown.Button.Parent and themeDropdown.Button.Parent.Parent then
   themeDropdown.Button.Parent.Parent.LayoutOrder = 0
end

local BtnItem = SettingsLib.AddItem(ThemeTab, "Theme Management", "Manage your themes")
BtnItem.LayoutOrder = 1 
BtnItem.BackgroundColor3 = Color3.fromRGB(35, 38, 42)
BtnItem.Size = UDim2.new(0.95, 0, 0, 70) 

for _, v in pairs(BtnItem:GetChildren()) do if v.Name == "Title" or v.Name == "Desc" then v:Destroy() end end

local ManagementContainer = Instance.new("Frame")
ManagementContainer.Parent = BtnItem
ManagementContainer.BackgroundTransparency = 1
ManagementContainer.Size = UDim2.new(1, 0, 1, 0)

local Layout = Instance.new("UIListLayout")
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.Padding = UDim.new(0, 15)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Center
Layout.Parent = ManagementContainer

local BtnRow = ManagementContainer 

local function CreatePopup(title, size)
    local panel = Instance.new("Frame")
    panel.Size = size or UDim2.fromOffset(280, 140)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.BackgroundColor3 = Color3.fromHex("18191c")
    panel.ZIndex = 2000
    panel.Parent = SettingsLib.UI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Parent = panel
    stroke.Color = (State.EmoteTheme and State.EmoteTheme.Accent) or Color3.fromRGB(0, 255, 150)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5

    local lbl = Instance.new("TextLabel")
    lbl.Parent = panel
    lbl.Size = UDim2.new(1, 0, 0, 35)
    lbl.BackgroundTransparency = 1
    lbl.Text = title:upper()
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.new(1,1,1)
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = panel
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 35)
    content.Size = UDim2.new(1, 0, 1, -35)
    
    return panel, content
end

local function CreateInput(parent, placeholder, text, isMulti)
    local box = Instance.new("TextBox")
    box.Size = isMulti and UDim2.new(0.9, 0, 0, 100) or UDim2.new(0.9, 0, 0, 35)
    box.Position = UDim2.new(0.05, 0, 0, 5)
    box.BackgroundColor3 = Color3.fromRGB(35, 38, 41)
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderText = placeholder or ""
    box.Text = text or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.MultiLine = isMulti
    box.TextWrapped = isMulti
    box.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = box
    
    return box
end

local function CreateButton(parent, text, color, pos, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0.4, 0, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = (color.R + color.G + color.B < 1.5) and Color3.new(1,1,1) or Color3.new(0,0,0)
    btn.TextSize = 12
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

SettingsLib.AddIconButton(BtnRow, "108445456753346", function()
    local popup, content = CreatePopup("Create Theme")
    local In = CreateInput(content, "Theme Name...")
    
    local Save = CreateButton(content, "SAVE", (State.EmoteTheme and State.EmoteTheme.Accent) or Color3.fromRGB(0, 255, 150), UDim2.new(0.05, 0, 0.6, 0))
    local Cancel = CreateButton(content, "CANCEL", Color3.fromRGB(50, 50, 50), UDim2.new(0.55, 0, 0.6, 0))
    Cancel.TextColor3 = Color3.new(1,1,1)

    Save.MouseButton1Click:Connect(function()
        if In.Text ~= "" and not themes[In.Text] then
            themes[In.Text] = DeepCopy(themes[currentThemeName])
            if not themes[In.Text].IconColors then themes[In.Text].IconColors = {} end
            table.insert(themes.Order, In.Text)
            
            table.sort(themes.Order, function(a, b)
                if a == "Default" then return true end
                if b == "Default" then return false end
                return a:lower() < b:lower()
            end)
            
            SaveThemes(themes)
            currentThemeName = In.Text
            themeDropdown.Refresh(GetNames())
            themeDropdown.Button.Text = currentThemeName .. "  ▼"
            ApplyTheme(themes[currentThemeName])
            popup:Destroy()
        end
    end)
    
    Cancel.MouseButton1Click:Connect(function() popup:Destroy() end)
end)

SettingsLib.AddIconButton(BtnRow, "71829270056766", function()
    if currentThemeName ~= "Default" then
        local idx = table.find(themes.Order, currentThemeName)
        if idx then table.remove(themes.Order, idx) end
        
        themes[currentThemeName] = nil
        SaveThemes(themes)
        currentThemeName = "Default"
        themeDropdown.Refresh(GetNames())
        themeDropdown.Button.Text = "Default  ▼"
        ApplyTheme(themes["Default"])
    end
end)

SettingsLib.AddIconButton(BtnRow, "117761881427472", function()
    if currentThemeName == "Default" then return end
    
    local popup, content = CreatePopup("Rename Theme")
    local In = CreateInput(content, "New Name...", currentThemeName)
    
    local Save = CreateButton(content, "RENAME", (State.EmoteTheme and State.EmoteTheme.Accent) or Color3.fromRGB(0, 255, 150), UDim2.new(0.05, 0, 0.6, 0))
    local Cancel = CreateButton(content, "CANCEL", Color3.fromRGB(50, 50, 50), UDim2.new(0.55, 0, 0.6, 0))
    Cancel.TextColor3 = Color3.new(1,1,1)

    Save.MouseButton1Click:Connect(function()
        if In.Text ~= "" and not themes[In.Text] then
            local idx = table.find(themes.Order, currentThemeName)
            if idx then themes.Order[idx] = In.Text end
            
            themes[In.Text] = themes[currentThemeName]
            themes[currentThemeName] = nil
            currentThemeName = In.Text
            SaveThemes(themes)
            themeDropdown.Refresh(GetNames())
            themeDropdown.Button.Text = currentThemeName .. "  ▼"
            popup:Destroy()
        end
    end)
    
    Cancel.MouseButton1Click:Connect(function() popup:Destroy() end)
end)

SettingsLib.AddIconButton(BtnRow, "78317476576895", function()
    local popup, content = CreatePopup("Import Theme", UDim2.fromOffset(320, 240))
    local box = CreateInput(content, "Paste Theme JSON here...", "", true)
    box.Size = UDim2.new(0.9, 0, 0, 130)
    
    local imp = CreateButton(content, "IMPORT THEME", (State.EmoteTheme and State.EmoteTheme.Accent) or Color3.fromRGB(0, 255, 150), UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.9, 0, 0, 35))

    imp.MouseButton1Click:Connect(function()
        local s, d = pcall(function() return HttpService:JSONDecode(box.Text) end)
        if s and type(d) == "table" and d.name then
            if d.name == "Default" then
                getgenv().Notify({Title = "Error", Content = "Cannot overwrite 'Default' theme.", Duration = 3})
                return
            end
            if not themes[d.name] then
                table.insert(themes.Order, d.name)
            end
            themes[d.name] = d.data
            SaveThemes(themes)
            themeDropdown.Refresh(GetNames())
            popup:Destroy()
        else
            getgenv().Notify({Title = "Error", Content = "Invalid JSON Format!", Duration = 3})
        end
    end)
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(24, 24)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.BackgroundTransparency = 1
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = popup
    close.MouseButton1Click:Connect(function() popup:Destroy() end)
end)

SettingsLib.AddIconButton(BtnRow, "107588515524752", function()
    local exportData = { name = currentThemeName, data = themes[currentThemeName] }
    local json = HttpService:JSONEncode(exportData)
    
    local popup, content = CreatePopup("Export Theme", UDim2.fromOffset(320, 240))
    local box = CreateInput(content, "", json, true)
    box.Size = UDim2.new(0.9, 0, 0, 130)
    box.TextEditable = false
    
    local copy = CreateButton(content, "COPY TO CLIPBOARD", (State.EmoteTheme and State.EmoteTheme.Accent) or Color3.fromRGB(0, 255, 150), UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.9, 0, 0, 35))

    copy.MouseButton1Click:Connect(function()
        setclipboard(json)
        copy.Text = "COPIED!"
        task.delay(1, function() copy.Text = "COPY TO CLIPBOARD" end)
    end)
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(24, 24)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.BackgroundTransparency = 1
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = popup
    close.MouseButton1Click:Connect(function() popup:Destroy() end)
end)


local function SmartUpdate(key, subkey, val)
    if currentThemeName == "Default" then
        getgenv().Notify({Title = "Theme", Content = "Cannot modify Default theme. Create a new one!", Duration = 2})
        return
    end

    if themes[currentThemeName] then
        if not themes[currentThemeName][key] then themes[currentThemeName][key] = {} end
        
        if subkey then
            themes[currentThemeName][key][subkey] = val
        else
            themes[currentThemeName][key] = val
        end
        SaveThemes(themes)
        ApplyTheme(themes[currentThemeName])
    end
end

local WheelFolder = SettingsLib.AddFolder(ThemeTab, "Wheel Settings")
WheelFolder.Parent.LayoutOrder = 1.1

local function AddWheelInput(title, wheelKey)
    local initialData = themes["Default"].Wheel[wheelKey]
    local initialColor = TableToColor(themes["Default"].Wheel[wheelKey.."Color"])
    
    local current = (themes[currentThemeName].Wheel and themes[currentThemeName].Wheel[wheelKey]) or initialData
    local currentColor = TableToColor((themes[currentThemeName].Wheel and themes[currentThemeName].Wheel[wheelKey.."Color"]) or themes["Default"].Wheel[wheelKey.."Color"])
    
    local comp = SettingsLib.AddAssetColor(WheelFolder, title, "Asset ID...", current, currentColor, function(text, color)
        if currentThemeName == "Default" then
            getgenv().Notify({Title = "Theme", Content = "Cannot modify Default theme!", Duration = 2})
            return
        end
        
        if themes[currentThemeName] then
            if not themes[currentThemeName].Wheel then themes[currentThemeName].Wheel = {} end
            themes[currentThemeName].Wheel[wheelKey] = text
            themes[currentThemeName].Wheel[wheelKey.."Color"] = ColorToTable(color)
            
            SaveThemes(themes)
            ApplyTheme(themes[currentThemeName])
        end
    end)
    UIElements.Wheel[wheelKey] = comp

    local resetBtn = SettingsLib:Create("ImageButton", {
        Parent = comp.Item,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0.5, -10),
        Size = UDim2.fromOffset(20, 20),
        Image = "rbxassetid://127493377027615",
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 10
    })
    
    resetBtn.MouseButton1Click:Connect(function()
        if currentThemeName == "Default" then return end
        comp.SetValue(initialData, initialColor)
        if themes[currentThemeName] then
            if not themes[currentThemeName].Wheel then themes[currentThemeName].Wheel = {} end
            themes[currentThemeName].Wheel[wheelKey] = initialData
            themes[currentThemeName].Wheel[wheelKey.."Color"] = ColorToTable(initialColor)
            SaveThemes(themes)
            ApplyTheme(themes[currentThemeName])
        end
    end)
end

AddWheelInput("Wheel Background", "BackgroundImage")
AddWheelInput("Selection Gradient", "SelectionGradient")
AddWheelInput("Selection Line", "SelectionLine")

local BackgroundFolder = SettingsLib.AddFolder(ThemeTab, "Background Settings")
BackgroundFolder.Parent.LayoutOrder = 2
UIElements.Background.Main = SettingsLib.AddColorPicker(BackgroundFolder, "Main Background", TableToColor(themes[currentThemeName].Background), function(c)
    SmartUpdate("Background", nil, ColorToTable(c))
end)

local IconSettingsFolder = SettingsLib.AddFolder(ThemeTab, "Icon Settings")
IconSettingsFolder.Parent.LayoutOrder = 3

local function AddAssetInput(title, iconKey)
    local current = (themes[currentThemeName].Icons and themes[currentThemeName].Icons[iconKey]) or ""
    local defaultText = (themes["Default"].Icons and themes["Default"].Icons[iconKey]) or ""
    
    local currentColor = Color3.new(1,1,1)
    if themes[currentThemeName].IconColors and themes[currentThemeName].IconColors[iconKey] then
        currentColor = TableToColor(themes[currentThemeName].IconColors[iconKey])
    elseif themes[currentThemeName].ImageColor then
        currentColor = TableToColor(themes[currentThemeName].ImageColor)
    end
    
    local defaultColor = Color3.new(1,1,1)
    if themes["Default"].IconColors and themes["Default"].IconColors[iconKey] then
        defaultColor = TableToColor(themes["Default"].IconColors[iconKey])
    elseif themes["Default"].ImageColor then
        defaultColor = TableToColor(themes["Default"].ImageColor)
    end
    
    local comp = SettingsLib.AddInputWithColor(IconSettingsFolder, title, "Asset ID...", defaultText, defaultColor, function(text, color)
        local s, err = pcall(function()
            if currentThemeName == "Default" then
                getgenv().Notify({Title = "Theme", Content = "Cannot modify Default theme!", Duration = 2})
                return
            end
            
            if themes[currentThemeName] then
                if not themes[currentThemeName].Icons then themes[currentThemeName].Icons = {} end
                if not themes[currentThemeName].IconColors then themes[currentThemeName].IconColors = {} end
                
                local cTable = ColorToTable(color)
                themes[currentThemeName].Icons[iconKey] = text
                themes[currentThemeName].IconColors[iconKey] = cTable
                
                SaveThemes(themes)
                ApplyTheme(themes[currentThemeName])
            end
        end)
        if not s then
            warn("Theme Save Error: " .. tostring(err))
            getgenv().Notify({Title = "Error", Content = "Failed to save color!", Duration = 3})
        end
    end)
    comp.SetValue(current, currentColor)
    UIElements.Icons[iconKey] = comp
end

AddAssetInput("Left Arrow", "Left")
AddAssetInput("Right Arrow", "Right")
AddAssetInput("Walk Icon", "Walk")
AddAssetInput("Speed Icon", "Speed")
AddAssetInput("Page Icon", "Page")
AddAssetInput("Reload Icon", "Reload")
AddAssetInput("Favorite (Star)", "Favorite")
AddAssetInput("Not Favorite", "NotFavorite")


pcall(function()
    SafeLoad("https://raw.githubusercontent.com/7yd7/Hub/Branch/GUIS/count-emote", "Count Emote")
end)

getgenv().Notify({
    Title = '7yd7 | Emote',
    Content = '⚠️ Script loading...',
    Duration = 5
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

RunService.Heartbeat:Connect(function()
    local success, menu = pcall(function() return CoreGui.RobloxGui.EmotesMenu.Children end)
    if not (success and menu) then return end
    
    pcall(function()
        local wheelVisible = menu.Main.EmotesWheel.Visible
        if wheelVisible then
            State.lastWheelVisibleTime = tick()
        end
        ToggleContainer.Visible = wheelVisible
    end)

    local errorMsg = menu:FindFirstChild("ErrorMessage")

    if errorMsg and errorMsg.Visible then
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            errorMsg.ErrorText.Text = "Only r15 does not work r6"
        elseif tick() - State.lastRadialActionTime < 2 then
            errorMsg.Visible = false
        end
    end
end)


function ErrorMessage(text, duration)

    if State.currentTimer then
        task.cancel(State.currentTimer)
        State.currentTimer = nil
    end
    
    local errorMessage = CoreGui.RobloxGui.EmotesMenu.Children.ErrorMessage
    local errorText = errorMessage.ErrorText
    
    errorText.Text = text
    
    errorMessage.Visible = true
    
    State.currentTimer = task.delay(duration, function()
        errorMessage.Visible = false
        State.currentTimer = nil
    end)
end

local function stopEmotes()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local function getCharacterAndHumanoid()
    local character = player.Character
    if not character then
        return nil, nil
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return nil, nil
    end
    return character, humanoid
end

local function urlToId(animationId)
    animationId = string.gsub(animationId, "http://www%.roblox%.com/asset/%?id=", "")
    animationId = string.gsub(animationId, "rbxassetid://", "")
    return animationId
end

local function saveFavorites()
    if writefile then
        local jsonData = HttpService:JSONEncode(State.favoriteEmotes)
        writefile(State.favoriteFileName, jsonData)
    end
end

local function saveFavoritesAnimations()
    if writefile then
        local jsonData = HttpService:JSONEncode(State.favoriteAnimations)
        writefile(State.favoriteAnimationsFileName, jsonData)
    end
end

local function loadFavorites()
    if readfile and isfile and isfile(State.favoriteFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(State.favoriteFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            State.favoriteEmotes = result
            State.favoriteSetVersion = State.favoriteSetVersion + 1
        end
    end
end

local function loadFavoritesAnimations()
    if readfile and isfile and isfile(State.favoriteAnimationsFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(State.favoriteAnimationsFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            State.favoriteAnimations = result
            State.favoriteSetVersion = State.favoriteSetVersion + 1
        end
    end
end

local function disconnectAllConnections()
    for _, connection in pairs(State.guiConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.guiConnections = {}
end

local function loadSpeedEmoteConfig()
    State.speedEmoteEnabled = Config.EmoteSpeedEnabled
    if UI.SpeedBox then
        UI.SpeedBox.Text = tostring(Config.EmoteSpeed)
        UI.SpeedBox.Visible = (State.speedEmoteEnabled and Config.SpeedVisible)
    end
end

local function extractAssetId(imageUrl)
    local assetId = string.match(imageUrl, "Asset&id=(%d+)")
    return assetId
end

local function getEmoteName(assetId)
    local success, productInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(tonumber(assetId))
    end)
    
    if success and productInfo then
        return productInfo.Name
    else
        return "Emote_" .. tostring(assetId)
    end
end

local function isInFavorites(assetId)
    if State.favoriteSetBuiltVersion ~= State.favoriteSetVersion then
        State.favoriteEmoteSet = {}
        for _, favorite in pairs(State.favoriteEmotes) do
            State.favoriteEmoteSet[tostring(favorite.id)] = true
        end
        State.favoriteAnimationSet = {}
        for _, favorite in pairs(State.favoriteAnimations) do
            State.favoriteAnimationSet[tostring(favorite.id)] = true
        end
        State.favoriteSetBuiltVersion = State.favoriteSetVersion
    end
    if State.currentMode == "animation" then
        return State.favoriteAnimationSet[tostring(assetId)] == true
    end
    return State.favoriteEmoteSet[tostring(assetId)] == true
end

local function rebuildEmoteNormalCache()
    if State.emotePageCache.version == State.emoteCacheVersion and State.emotePageCache.favVersion == State.favoriteSetVersion then
        return
    end
    if State.favoriteSetBuiltVersion ~= State.favoriteSetVersion then
        State.favoriteEmoteSet = {}
        for _, favorite in pairs(State.favoriteEmotes) do
            State.favoriteEmoteSet[tostring(favorite.id)] = true
        end
        State.favoriteAnimationSet = {}
        for _, favorite in pairs(State.favoriteAnimations) do
            State.favoriteAnimationSet[tostring(favorite.id)] = true
        end
        State.favoriteSetBuiltVersion = State.favoriteSetVersion
    end
    local normal = {}
    for _, emote in ipairs(State.filteredEmotes) do
        if not State.favoriteEmoteSet[tostring(emote.id)] then
            table.insert(normal, emote)
        end
    end
    State.emotePageCache.normal = normal
    State.emotePageCache.version = State.emoteCacheVersion
    State.emotePageCache.favVersion = State.favoriteSetVersion
end

local function rebuildAnimationNormalCache()
    if State.animationPageCache.version == State.animationCacheVersion and State.animationPageCache.favVersion == State.favoriteSetVersion then
        return
    end
    if State.favoriteSetBuiltVersion ~= State.favoriteSetVersion then
        State.favoriteEmoteSet = {}
        for _, favorite in pairs(State.favoriteEmotes) do
            State.favoriteEmoteSet[tostring(favorite.id)] = true
        end
        State.favoriteAnimationSet = {}
        for _, favorite in pairs(State.favoriteAnimations) do
            State.favoriteAnimationSet[tostring(favorite.id)] = true
        end
        State.favoriteSetBuiltVersion = State.favoriteSetVersion
    end
    local normal = {}
    for _, animation in ipairs(State.filteredAnimations) do
        if not State.favoriteAnimationSet[tostring(animation.id)] then
            table.insert(normal, animation)
        end
    end
    State.animationPageCache.normal = normal
    State.animationPageCache.version = State.animationCacheVersion
    State.animationPageCache.favVersion = State.favoriteSetVersion
end

local function updateAnimationImages(currentPageAnimations)
    local success, frontFrame = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
    end)
    
    if not success or not frontFrame then
        return
    end
    
    local buttonIndex = 1
    for _, child in pairs(frontFrame:GetChildren()) do
        if child:IsA("ImageLabel") then
            if buttonIndex <= #currentPageAnimations then
                local animationData = currentPageAnimations[buttonIndex]
                child.Image = "rbxthumb://type=BundleThumbnail&id=" .. animationData.id .. "&w=420&h=420"
                
                local idValue = child:FindFirstChild("AnimationID") or Instance.new("IntValue")
                idValue.Name = "AnimationID"
                idValue.Value = animationData.id
                idValue.Parent = child

                child.Active = not State.favoriteEnabled

                buttonIndex = buttonIndex + 1
            else
                child.Image = ""
                local idValue = child:FindFirstChild("AnimationID")
                if idValue then 
                    idValue:Destroy() 
                end
                child.Active = true
            end
        end
    end
    
    frontFrame.Active = not State.favoriteEnabled
end


local function updateFavoriteIcon(imageLabel, assetId, isFavorite)
    local favoriteIcon = imageLabel:FindFirstChild("FavoriteIcon")
    
    if not favoriteIcon then
        favoriteIcon = Instance.new("ImageLabel")
        favoriteIcon.Name = "FavoriteIcon"
        favoriteIcon.Size = UDim2.new(0.3, 0, 0.3, 0) 
        favoriteIcon.Position = UDim2.new(0.7, 0, 0, 0)
        favoriteIcon.AnchorPoint = Vector2.new(0, 0)
        favoriteIcon.BackgroundTransparency = 1
        favoriteIcon.ZIndex = imageLabel.ZIndex + 5
        favoriteIcon.ScaleType = Enum.ScaleType.Fit
        favoriteIcon.Parent = imageLabel
    end
    
    if isFavorite then
        favoriteIcon.Image = State.favoriteIconId
    else
        favoriteIcon.Image = State.notFavoriteIconId 
    end
end

local function updateAllFavoriteIcons()
    local success, frontFrame = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
    end)
    
    if success and frontFrame then
        for _, child in pairs(frontFrame:GetChildren()) do
            if child:IsA("ImageLabel") and child.Image ~= "" then
                local assetId
                if State.currentMode == "animation" then
                    local idValue = child:FindFirstChild("AnimationID")
                    if idValue then
                        assetId = idValue.Value
                    end
                else
                    assetId = extractAssetId(child.Image)
                end
                
                if assetId then
                    local isFavorite = isInFavorites(assetId)
                    updateFavoriteIcon(child, assetId, isFavorite)
                end
                child.Active = not State.favoriteEnabled
            end
        end
        frontFrame.Active = not State.favoriteEnabled
    end
end

local function updateAnimations()
    local character, humanoid = getCharacterAndHumanoid()
    if not character or not humanoid then
        return
    end

    local humanoidDescription = humanoid.HumanoidDescription
    if not humanoidDescription then
        return
    end

    local currentPageAnimations = {}
    local animationTable = {}
    local equippedAnimations = {}

    rebuildAnimationNormalCache()
    local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or State.favoriteAnimations
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / State.itemsPerPage) or 0
    local isInFavoritesPages = State.currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (State.currentPage - 1) * State.itemsPerPage + 1
        local endIndex = math.min(startIndex + State.itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageAnimations, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalAnimations = State.animationPageCache.normal or {}
        local adjustedPage = State.currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * State.itemsPerPage + 1
        local endIndex = math.min(startIndex + State.itemsPerPage - 1, #normalAnimations)

        for i = startIndex, endIndex do
            if normalAnimations[i] then
                table.insert(currentPageAnimations, normalAnimations[i])
            end
        end
    end

    for _, animation in pairs(currentPageAnimations) do
        local animationName = animation.name
        local animationId = animation.id
        animationTable[animationName] = {animationId}
        table.insert(equippedAnimations, animationName)
    end

    humanoidDescription:SetEmotes(animationTable)
    humanoidDescription:SetEquippedEmotes(equippedAnimations)
    
    task.wait(0.1)
    updateAnimationImages(currentPageAnimations)

    task.delay(0.2, function()
        if State.favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function updateEmotes()
    local character, humanoid = getCharacterAndHumanoid()
    if not character or not humanoid then
        return
    end

    if State.currentMode == "animation" then
        updateAnimations()
        return
    end

    local humanoidDescription = humanoid.HumanoidDescription
    if not humanoidDescription then
        return
    end

    local currentPageEmotes = {}
    local emoteTable = {}
    local equippedEmotes = {}

    rebuildEmoteNormalCache()
    local favoritesToUse = _G.filteredFavoritesForDisplay or State.favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / State.itemsPerPage) or 0
    local isInFavoritesPages = State.currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (State.currentPage - 1) * State.itemsPerPage + 1
        local endIndex = math.min(startIndex + State.itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageEmotes, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalEmotes = State.emotePageCache.normal or {}
        local adjustedPage = State.currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * State.itemsPerPage + 1
        local endIndex = math.min(startIndex + State.itemsPerPage - 1, #normalEmotes)

        for i = startIndex, endIndex do
            if normalEmotes[i] then
                table.insert(currentPageEmotes, normalEmotes[i])
            end
        end
    end

    for _, emote in pairs(currentPageEmotes) do
        local emoteName = emote.name
        local emoteId = emote.id
        emoteTable[emoteName] = {emoteId}
        table.insert(equippedEmotes, emoteName)
    end

    humanoidDescription:SetEmotes(emoteTable)
    humanoidDescription:SetEquippedEmotes(equippedEmotes)
    
    task.delay(0.2, function()
        if State.favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function calculateTotalPages()
      if State.currentMode == "animation" then
        local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or State.favoriteAnimations
        local hasFavorites = #favoritesToUse > 0
        rebuildAnimationNormalCache()
        local normalAnimationsCount = #(State.animationPageCache.normal or {})

        local pages = 0
        if hasFavorites then
            pages = pages + math.ceil(#favoritesToUse / State.itemsPerPage)
        end
        if normalAnimationsCount > 0 then
            pages = pages + math.ceil(normalAnimationsCount / State.itemsPerPage)
        end
        return math.max(pages, 1)
    end
    
    local favoritesToUse = _G.filteredFavoritesForDisplay or State.favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    rebuildEmoteNormalCache()
    local normalEmotesCount = #(State.emotePageCache.normal or {})

    local pages = 0

    if hasFavorites then
        pages = pages + math.ceil(#favoritesToUse / State.itemsPerPage)
    end

    if normalEmotesCount > 0 then
        pages = pages + math.ceil(normalEmotesCount / State.itemsPerPage)
    end

    return math.max(pages, 1)
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
    if emotesWheel:FindFirstChild("Favorite") then
        emotesWheel.Favorite:Destroy()
    end
    if emotesWheel:FindFirstChild("SpeedEmote") then
        emotesWheel.SpeedEmote:Destroy()
    end
    if emotesWheel:FindFirstChild("Changepage") then
        emotesWheel.Changepage:Destroy()
    end
    if emotesWheel:FindFirstChild("SpeedBox") then
        emotesWheel.SpeedBox:Destroy()
    end
    if emotesWheel:FindFirstChild("Reload") then
        emotesWheel.Reload:Destroy()
    end

    UI.Under = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    UI._1left = Instance.new("ImageButton")
    UI._9right = Instance.new("ImageButton")
    UI._4pages = Instance.new("TextLabel")
    UI._3TextLabel = Instance.new("TextLabel")
    UI._2Routenumber = Instance.new("TextBox")
    UI.EmoteWalkButton = Instance.new("ImageButton")
    local UICorner_Left = Instance.new("UICorner")
    UICorner_Left.CornerRadius = UDim.new(0, 10)
    UICorner_Left.Parent = UI._1left
    
    local UICorner_Right = Instance.new("UICorner")
    UICorner_Right.CornerRadius = UDim.new(0, 10)
    UICorner_Right.Parent = UI._9right

    local UICorner1 = Instance.new("UICorner")
    UI.Top = Instance.new("Frame")
    local UIListLayout_2 = Instance.new("UIListLayout")
    local UICorner = Instance.new("UICorner")
    UI.Search = Instance.new("TextBox")
    UI.Favorite = Instance.new("ImageButton")
    local UICorner2 = Instance.new("UICorner")
    UI.SpeedBox = Instance.new("TextBox")
    local UICorner_4 = Instance.new("UICorner")
    UI.SpeedEmote = Instance.new("ImageButton")
    local UICorner_2 = Instance.new("UICorner")
    UI.Changepage = Instance.new("ImageButton")
    local UICorner_5 = Instance.new("UICorner")
    UI.Reload = Instance.new("ImageButton")
    local UICorner_6 = Instance.new("UICorner")

    UI.Under.Name = "Under"
    UI.Under.Parent = emotesWheel
    UI.Under.BackgroundTransparency = 1.000
    UI.Under.BorderSizePixel = 0
    UI.Under.Position = UDim2.new(0.129999995, 0, 1, 0)
    UI.Under.Size = UDim2.new(0.737500012, 0, 0.132499993, 0)

    UIListLayout.Parent = UI.Under
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    UI._1left.Name = "1left"
    UI._1left.Parent = UI.Under
    UI._1left.BackgroundTransparency = 1.000
    UI._1left.BorderSizePixel = 0
    UI._1left.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
    UI._1left.Image = "rbxassetid://93111945058621"
    UI._1left.ImageColor3 = Color3.fromRGB(0, 0, 0)
    UI._1left.ImageTransparency = 0.400

    UI._9right.Name = "9right"
    UI._9right.Parent = UI.Under
    UI._9right.BackgroundTransparency = 1.000
    UI._9right.BorderSizePixel = 0
    UI._9right.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
    UI._9right.Image = "rbxassetid://107938916240738"
    UI._9right.ImageColor3 = Color3.fromRGB(0, 0, 0)
    UI._9right.ImageTransparency = 0.400

    UI._4pages.Name = "4pages"
    UI._4pages.Parent = UI.Under
    UI._4pages.BackgroundTransparency = 1.000
    UI._4pages.BorderSizePixel = 0
    UI._4pages.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
    UI._4pages.Font = Enum.Font.SourceSansBold
    UI._4pages.Text = "1"
    UI._4pages.TextColor3 = Color3.fromRGB(0, 0, 0)
    UI._4pages.TextScaled = true
    UI._4pages.TextSize = 14.000
    UI._4pages.TextTransparency = 0.400
    UI._4pages.TextWrapped = true

    UI._3TextLabel.Name = "3TextLabel"
    UI._3TextLabel.Parent = UI.Under
    UI._3TextLabel.BackgroundTransparency = 1.000
    UI._3TextLabel.BorderSizePixel = 0
    UI._3TextLabel.Size = UDim2.new(0.338983059, 0, 0.94339627, 0)
    UI._3TextLabel.Font = Enum.Font.SourceSansBold
    UI._3TextLabel.Text = " ------ "
    UI._3TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    UI._3TextLabel.TextScaled = true
    UI._3TextLabel.TextSize = 14.000
    UI._3TextLabel.TextTransparency = 0.400
    UI._3TextLabel.TextWrapped = true

    UI._2Routenumber.Name = "2Route-number"
    UI._2Routenumber.Parent = UI.Under
    UI._2Routenumber.Active = true
    UI._2Routenumber.BackgroundTransparency = 1.000
    UI._2Routenumber.BorderSizePixel = 0
    UI._2Routenumber.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
    UI._2Routenumber.Font = Enum.Font.SourceSansBold
    UI._2Routenumber.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    UI._2Routenumber.Text = "1"
    UI._2Routenumber.TextColor3 = Color3.fromRGB(0, 0, 0)
    UI._2Routenumber.TextScaled = true
    UI._2Routenumber.TextSize = 14.000
    UI._2Routenumber.TextTransparency = 0.400
    UI._2Routenumber.TextWrapped = true

    UI.Top.Name = "Top"
    UI.Top.Parent = emotesWheel
    UI.Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.Top.BackgroundTransparency = 0.400
    UI.Top.BorderSizePixel = 0
    UI.Top.Position = UDim2.new(0.127499998, 0, -0.109999999, 0)
    UI.Top.Size = UDim2.new(0.737500012, 0, 0.0949999914, 0)

    UIListLayout_2.Parent = UI.Top
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = UI.Top

    UI.Search.Name = "Search"
    UI.Search.Parent = UI.Top
    UI.Search.BackgroundTransparency = 1.000
    UI.Search.Size = UDim2.new(0.864406765, 0, 0.81578958, 0)
    UI.Search.Font = Enum.Font.SourceSansBold
    UI.Search.PlaceholderText = "Search/ID"
    UI.Search.Text = ""
    UI.Search.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.Search.TextScaled = true
    UI.Search.TextSize = 14.000
    UI.Search.TextWrapped = true

    UI.EmoteWalkButton.Name = "EmoteWalkButton"
    UI.EmoteWalkButton.Parent = emotesWheel
    UI.EmoteWalkButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.EmoteWalkButton.BackgroundTransparency = 0.400
    UI.EmoteWalkButton.BorderSizePixel = 0
    UI.EmoteWalkButton.Position = UDim2.new(0.889999986, 0, -0.107500002, 0)
    UI.EmoteWalkButton.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    UI.EmoteWalkButton.Image = State.defaultButtonImage

    UICorner1.CornerRadius = UDim.new(0, 10)
    UICorner1.Parent = UI.EmoteWalkButton

    UI.Favorite.Name = "Favorite"
    UI.Favorite.Parent = emotesWheel
    UI.Favorite.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.Favorite.BackgroundTransparency = 0.400
    UI.Favorite.BorderSizePixel = 0
    UI.Favorite.Position = UDim2.new(0.0189999994, 0, -0.108000003, 0)
    UI.Favorite.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    UI.Favorite.Image = "rbxassetid://124025954365505"

    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = UI.Favorite

    UI.SpeedBox.Name = "SpeedBox"
    UI.SpeedBox.Parent = emotesWheel
    UI.SpeedBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.SpeedBox.BackgroundTransparency = 0.400
    UI.SpeedBox.BorderSizePixel = 0
    UI.SpeedBox.Position = UDim2.new(0.0189999398, 0, -0.000499992399, 0)
    UI.SpeedBox.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    UI.SpeedBox.Visible = false
    UI.SpeedBox.Font = Enum.Font.SourceSansBold
    UI.SpeedBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    UI.SpeedBox.Text = "1"
    UI.SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    UI.SpeedBox.TextScaled = true
    UI.SpeedBox.TextWrapped = true
    UI.SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
       UI.SpeedBox.Text = UI.SpeedBox.Text:gsub("[^%d.]", "")
    end)
    UI.SpeedBox.ZIndex = 2

    UICorner_4.CornerRadius = UDim.new(0, 10)
    UICorner_4.Parent = UI.SpeedBox

    UI.SpeedEmote.Name = "SpeedEmote"
    UI.SpeedEmote.Parent = emotesWheel
    UI.SpeedEmote.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.SpeedEmote.BackgroundTransparency = 0.400
    UI.SpeedEmote.BorderSizePixel = 0
    UI.SpeedEmote.Position = UDim2.new(0.888999999, 0, -0, 0)
    UI.SpeedEmote.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    UI.SpeedEmote.Image = "rbxassetid://116056570415896"
    UI.SpeedEmote.ZIndex = 2

    UICorner_2.CornerRadius = UDim.new(0, 10)
    UICorner_2.Parent = UI.SpeedEmote

UI.Changepage.Name = "Changepage"
UI.Changepage.Parent = emotesWheel
UI.Changepage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
UI.Changepage.BackgroundTransparency = 0.400
UI.Changepage.BorderColor3 = Color3.fromRGB(0, 0, 0)
UI.Changepage.BorderSizePixel = 0
UI.Changepage.Position = UDim2.new(0.019, 0,1.021, 0)
UI.Changepage.Size = UDim2.new(0.087, 0,0.087, 0)
UI.Changepage.ZIndex = 3
UI.Changepage.Image = "rbxassetid://13285615740"

UICorner_5.CornerRadius = UDim.new(0, 10)
UICorner_5.Parent = UI.Changepage

    UI.Reload.Name = "Reload"
    UI.Reload.Parent = emotesWheel
    UI.Reload.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    UI.Reload.BackgroundTransparency = 0.400
    UI.Reload.BorderSizePixel = 0
    UI.Reload.Position = UDim2.new(0.888999999, 0, 1.02100003, 0)
    UI.Reload.Size = UDim2.new(0.0869999975, 0, 0.0869999975, 0)
    UI.Reload.ZIndex = 3
    UI.Reload.Image = "rbxassetid://127493377027615"

    UICorner_6.CornerRadius = UDim.new(0, 10)
    UICorner_6.Parent = UI.Reload

    loadSpeedEmoteConfig()

    connectEvents()
    State.isGUICreated = true
    
    ApplyTheme(themes[currentThemeName] or themes.Default)
    
    updateGUIColors()
    
    ApplyUIVisibility()
    
    if applySavedPositions then applySavedPositions() end
    
    return true
end

local function updatePageDisplay()
    if UI._4pages and UI._2Routenumber then
        UI._4pages.Text = tostring(State.totalPages)
        UI._2Routenumber.Text = tostring(State.currentPage)
    end
    if State.currentMode == "animation" then
        Config.AnimationPage = State.currentPage
    else
        Config.EmotePage = State.currentPage
    end
    SaveConfig()
end


local function toggleFavorite(emoteId, emoteName)
    local found = false

    local index = 0

    for i, fav in pairs(State.favoriteEmotes) do
        if fav.id == emoteId then
            found = true
            index = i
            break
        end
    end

    if found then
        table.remove(State.favoriteEmotes, index)
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '🗑️ Removed "' .. emoteName .. '" from favorites',
            Duration = 3
        })
    else
        table.insert(State.favoriteEmotes, {
            id = emoteId,
            name = emoteName .. " - ⭐"
        })
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '✅ Added "' .. emoteName .. '" to favorites',
            Duration = 3
        })
    end

    State.favoriteSetVersion = State.favoriteSetVersion + 1
    saveFavorites()
    State.totalPages = calculateTotalPages()
    updatePageDisplay()
    updateEmotes()
    updateAllFavoriteIcons()
end


local function toggleFavoriteAnimation(animationData)
    local found = false


    local index = 0

    for i, fav in pairs(State.favoriteAnimations) do
        if fav.id == animationData.id then
            found = true
            index = i
            break
        end
    end

    if found then
        table.remove(State.favoriteAnimations, index)
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '🗑️ Removed "' .. animationData.name .. '" from favorites',
            Duration = 3
        })
    else
        table.insert(State.favoriteAnimations, {
            id = animationData.id,
            name = animationData.name .. " - ⭐",
            bundledItems = animationData.bundledItems
        })
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '✅ Added "' .. animationData.name .. '" to favorites',
            Duration = 3
        })
    end

    State.favoriteSetVersion = State.favoriteSetVersion + 1
    saveFavoritesAnimations()
    State.totalPages = calculateTotalPages()
    updatePageDisplay()
    updateAnimations()
    updateAllFavoriteIcons()
end


local function setupEmoteClickDetection()
    if State.isMonitoringClicks then
        return
    end
end
   
local function setupEmoteClickDetection()
    if State.isMonitoringClicks then
        return
    end
   
    local function monitorEmotes()
        while State.favoriteEnabled do
            local success, frontFrame = pcall(function()
                return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
            end)
           
            if success and frontFrame then
                for _, connection in pairs(State.emoteClickConnections) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                State.emoteClickConnections = {}
               
                for _, child in pairs(frontFrame:GetChildren()) do
                    if child:IsA("ImageLabel") and child.Image ~= "" then
                        local imageUrl = child.Image
                        local assetId = extractAssetId(imageUrl)
                        if assetId then
                            local isFavorite = isInFavorites(assetId)
                            updateFavoriteIcon(child, assetId, isFavorite)
                        end
                        child.Active = not State.favoriteEnabled
                    end
                end
                frontFrame.Active = not State.favoriteEnabled
            end
            
            task.wait(0.1)
        end
    end
   
    if State.favoriteEnabled then
        State.isMonitoringClicks = true
        task.spawn(monitorEmotes)
    end
end

local function applyAnimation(animationData)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local animate = character:FindFirstChild("Animate")
    
    if not animate or not humanoid then
        getgenv().Notify({
            Title = '7yd7 | Animation Error',
            Content = '❌ Animate or Humanoid not found',
            Duration = 3
        })
        return
    end
    
    local bundleId = animationData.id
    local bundledItems = animationData.bundledItems

    getgenv().lastPlayedAnimation = animationData
    
    if not bundledItems then
        getgenv().Notify({
            Title = '7yd7 | Animation Error', 
            Content = '❌ No bundled items found',
            Duration = 3
        })
        return
    end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    for key, assetIds in pairs(bundledItems) do
        for _, assetId in pairs(assetIds) do
            spawn(function()
                local success, objects = pcall(function()
                    return game:GetObjects("rbxassetid://" .. assetId)
                end)
                
                if success and objects then
                    local function searchForAnimations(parent, parentPath)
                        for _, child in pairs(parent:GetChildren()) do
                            if child:IsA("Animation") then
                                local animationPath = parentPath .. "." .. child.Name
                                local pathParts = animationPath:split(".")
                                
                                if #pathParts >= 2 then
                                    local animateCategory = pathParts[#pathParts - 1]
                                    local animationName = pathParts[#pathParts]
                                    
                                    if animate:FindFirstChild(animateCategory) then
                                        local categoryFolder = animate[animateCategory]
                                        if categoryFolder:FindFirstChild(animationName) then
                                            categoryFolder[animationName].AnimationId = child.AnimationId
                                            
                                            task.wait(0.1)
                                            local animation = Instance.new("Animation")
                                            animation.AnimationId = child.AnimationId
                                            
                                            local animTrack = humanoid.Animator:LoadAnimation(animation)
                                            animTrack.Priority = Enum.AnimationPriority.Action
                                            animTrack:Play()
                                            
                                            task.wait(0.1)
                                            animTrack:Stop()
                                        end
                                    end
                                end
                            elseif #child:GetChildren() > 0 then
                                searchForAnimations(child, parentPath .. "." .. child.Name)
                            end
                        end
                    end
                    
                    for _, obj in pairs(objects) do
                        searchForAnimations(obj, obj.Name)
                        obj.Parent = workspace
                        task.delay(1, function()
                            if obj then obj:Destroy() end
                        end)
                    end
                end
            end)
        end
    end
end

local function handleSectorAction(index)
    if tick() - State.lastActionTick < 0.25 then return end
    State.lastActionTick = tick()
    
    task.wait(0.05)

    local favoritesToUse = (State.currentMode == "animation") and (_G.filteredFavoritesAnimationsForDisplay or State.favoriteAnimations) or (_G.filteredFavoritesForDisplay or State.favoriteEmotes)
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / State.itemsPerPage) or 0
    local isInFavoritesPages = State.currentPage <= favoritePagesCount

    local function getEmoteAtIndex(idx)
        if isInFavoritesPages and hasFavorites then
            local startIndex = (State.currentPage - 1) * State.itemsPerPage + 1
            return favoritesToUse[startIndex + idx - 1]
        else
            local filteredList = (State.currentMode == "animation") and State.filteredAnimations or State.filteredEmotes
            local normalList = {}
            for _, item in pairs(filteredList) do
                if not isInFavorites(item.id) then
                    table.insert(normalList, item)
                end
            end
            local adjustedPage = State.currentPage - favoritePagesCount
            local startIndex = (adjustedPage - 1) * State.itemsPerPage + 1
            return normalList[startIndex + idx - 1]
        end
    end

    local itemData = getEmoteAtIndex(index)
    if not itemData then return end

    State.lastRadialActionTime = tick()


    if State.favoriteEnabled then
        if State.currentMode == "animation" then
            toggleFavoriteAnimation(itemData)
        else
            toggleFavorite(itemData.id, itemData.name)
        end
    else
        if State.currentMode == "animation" then
            applyAnimation(itemData)
        else
            local _, hum = getCharacterAndHumanoid()
            if hum then
                playEmote(hum, itemData.id)
            end
        end
    end

end


local function monitorAnimations()
    while State.currentMode == "animation" do
        local success, frontFrame = pcall(function()
            return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
        end)
        
        if success and frontFrame then
            for _, connection in pairs(State.emoteClickConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            State.emoteClickConnections = {}
            
            local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or State.favoriteAnimations
            local hasFavorites = #favoritesToUse > 0
            local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / State.itemsPerPage) or 0
            local isInFavoritesPages = State.currentPage <= favoritePagesCount
            
            local currentPageAnimations = {}
            
            if isInFavoritesPages and hasFavorites then
                local startIndex = (State.currentPage - 1) * State.itemsPerPage + 1
                local endIndex = math.min(startIndex + State.itemsPerPage - 1, #favoritesToUse)
                
                for i = startIndex, endIndex do
                    if favoritesToUse[i] then
                        table.insert(currentPageAnimations, favoritesToUse[i])
                    end
                end
            else
                local normalAnimations = {}
                for _, animation in pairs(State.filteredAnimations) do
                    if not isInFavorites(animation.id) then
                        table.insert(normalAnimations, animation)
                    end
                end
                
                local adjustedPage = State.currentPage - favoritePagesCount
                local startIndex = (adjustedPage - 1) * State.itemsPerPage + 1
                local endIndex = math.min(startIndex + State.itemsPerPage - 1, #normalAnimations)
                
                for i = startIndex, endIndex do
                    if normalAnimations[i] then
                        table.insert(currentPageAnimations, normalAnimations[i])
                    end
                end
            end
            
            local buttonIndex = 1
            for _, child in pairs(frontFrame:GetChildren()) do
                if child:IsA("ImageLabel") then
                    if buttonIndex <= #currentPageAnimations then
                        local animationData = currentPageAnimations[buttonIndex]
                        
                        if State.favoriteEnabled then
                            local isFavorite = isInFavorites(animationData.id)
                            updateFavoriteIcon(child, animationData.id, isFavorite)
                        else
                            local favoriteIcon = child:FindFirstChild("FavoriteIcon")
                            if favoriteIcon then
                                favoriteIcon:Destroy()
                            end
                        end
                        buttonIndex = buttonIndex + 1
                    else
                        local favoriteIcon = child:FindFirstChild("FavoriteIcon")
                        if favoriteIcon then
                            favoriteIcon:Destroy()
                        end
                    end
                end
            end

        end
        
        task.wait(0.1)
    end
end

local function stopEmoteClickDetection()
    State.isMonitoringClicks = false
    
    for _, connection in pairs(State.emoteClickConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.emoteClickConnections = {}
    
    local success, frontFrame = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
    end)
    
    if success and frontFrame then
        for _, child in pairs(frontFrame:GetChildren()) do
            if child:IsA("ImageLabel") then
                local clickDetector = child:FindFirstChild("ClickDetector")
                if clickDetector then
                    clickDetector:Destroy()
                end
                
                local favoriteIcon = child:FindFirstChild("FavoriteIcon")
                if favoriteIcon then
                    favoriteIcon:Destroy()
                end
            end
        end
    end
end


local function fetchAllEmotes()
    if State.isLoading then
        return
    end
    State.isLoading = true
    State.emotesData = {}
    State.totalEmotesLoaded = 0

    local success, result = pcall(function()
        local jsonContent = game:HttpGet("https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/EmoteSniper.json")
        
        if jsonContent and jsonContent ~= "" then
            local data = HttpService:JSONDecode(jsonContent)
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
                table.insert(State.emotesData, emoteData)
                State.totalEmotesLoaded = State.totalEmotesLoaded + 1
            end
        end
    else
        State.emotesData = {
            {id = 3360686498, name = "Stadium"},
            {id = 3360692915, name = "Tilt"},
            {id = 3576968026, name = "Shrug"},
            {id = 3360689775, name = "Salute"}
        }
        State.totalEmotesLoaded = #State.emotesData
    end

    State.originalEmotesData = State.emotesData
    State.filteredEmotes = State.emotesData
    State.emoteCacheVersion = State.emoteCacheVersion + 1

    State.totalPages = calculateTotalPages()
    State.currentPage = 1
    updatePageDisplay()
    updateEmotes()
    
    getgenv().Notify({
        Title = '7yd7 | Emote',
        Content = "🎉 Loaded Successfully! Total Emotes: " .. State.totalEmotesLoaded,
        Duration = 5
    })
    
    State.isLoading = false
end

local function fetchAllAnimations()
    if State.isLoading then
        return
    end
    State.isLoading = true
    State.animationsData = {}
    
    local success, result = pcall(function()
        local jsonContent = game:HttpGet("https://raw.githubusercontent.com/7yd7/sniper-Emote/refs/heads/test/AnimationSniper.json")
        
        if jsonContent and jsonContent ~= "" then
            local data = HttpService:JSONDecode(jsonContent)
            return data.data or {}
        else
            return nil
        end
    end)

    if success and result then
        for _, item in pairs(result) do
            local animationData = {
                id = tonumber(item.id),
                name = item.name or ("Animation_" .. (item.id or "Unknown")),
                bundledItems = item.bundledItems
            }
            if animationData.id and animationData.id > 0 then
                table.insert(State.animationsData, animationData)
            end
        end
    end

    State.originalAnimationsData = State.animationsData
    State.filteredAnimations = State.animationsData
    State.animationCacheVersion = State.animationCacheVersion + 1
    State.isLoading = false
end

local function searchEmotes(searchTerm)
    if State.isLoading then
        getgenv().Notify({
            Title = '7yd7 | Emote',
            Content = '⚠️ Loading please wait...',
            Duration = 5
        })
        return
    end

    searchTerm = searchTerm:lower()

    if searchTerm == "" then
        State.filteredEmotes = State.originalEmotesData
        State.emoteCacheVersion = State.emoteCacheVersion + 1
        if _G.originalFavoritesBackup then
            _G.originalFavoritesBackup = nil
        end
        _G.filteredFavoritesForDisplay = nil
    else
        local isIdSearch = searchTerm:match("^%d%d%d%d%d+$")
        
        local newFilteredList = {}
        
        if isIdSearch then
            for _, emote in pairs(State.originalEmotesData) do
                if tostring(emote.id) == searchTerm then
                    table.insert(newFilteredList, emote)
                end
            end
            
            if #newFilteredList == 0 then
                local emoteId = tonumber(searchTerm)
                if emoteId then
                    local emoteName = getEmoteName(emoteId)
                    local newEmote = {
                        id = emoteId,
                        name = emoteName
                    }
                    
                    table.insert(State.originalEmotesData, newEmote)
                    table.insert(newFilteredList, newEmote)
                end
            end
        else
            for _, emote in pairs(State.originalEmotesData) do
                if emote.name:lower():find(searchTerm) then
                    table.insert(newFilteredList, emote)
                end
            end
        end
        
        State.filteredEmotes = newFilteredList
        State.emoteCacheVersion = State.emoteCacheVersion + 1

        if not isIdSearch then
            if not _G.originalFavoritesBackup then
                _G.originalFavoritesBackup = {}
                for i, favorite in pairs(State.favoriteEmotes) do
                    _G.originalFavoritesBackup[i] = {
                        id = favorite.id,
                        name = favorite.name
                    }
                end
            end

            _G.filteredFavoritesForDisplay = {}
            for _, favorite in pairs(State.favoriteEmotes) do
                if favorite.name:lower():find(searchTerm) then
                    table.insert(_G.filteredFavoritesForDisplay, favorite)
                end
            end
        end
    end

    State.totalPages = calculateTotalPages()
    State.currentPage = 1
    updatePageDisplay()
    updateEmotes()
end

local function searchAnimations(searchTerm)
    if State.isLoading then
        getgenv().Notify({
            Title = '7yd7 | Animation',
            Content = '⚠️ Loading please wait...',
            Duration = 5
        })
        return
    end

    searchTerm = searchTerm:lower()

    if searchTerm == "" then
        State.filteredAnimations = State.originalAnimationsData
        State.animationCacheVersion = State.animationCacheVersion + 1
        if _G.originalAnimationFavoritesBackup then
            _G.originalAnimationFavoritesBackup = nil
        end
        _G.filteredFavoritesAnimationsForDisplay = nil
    else
        local isIdSearch = searchTerm:match("^%d+$")
        
        local newFilteredList = {}
        
        if isIdSearch then
            for _, animation in pairs(State.originalAnimationsData) do
                if tostring(animation.id) == searchTerm then
                    table.insert(newFilteredList, animation)
                end
            end
        else
            for _, animation in pairs(State.originalAnimationsData) do
                if animation.name:lower():find(searchTerm) then
                    table.insert(newFilteredList, animation)
                end
            end
        end
        
        State.filteredAnimations = newFilteredList
        State.animationCacheVersion = State.animationCacheVersion + 1

        if not isIdSearch then
            if not _G.originalAnimationFavoritesBackup then
                _G.originalAnimationFavoritesBackup = {}
                for i, favorite in pairs(State.favoriteAnimations) do
                    _G.originalAnimationFavoritesBackup[i] = {
                        id = favorite.id,
                        name = favorite.name,
                        bundledItems = favorite.bundledItems
                    }
                end
            end

            _G.filteredFavoritesAnimationsForDisplay = {}
            for _, favorite in pairs(State.favoriteAnimations) do
                if favorite.name:lower():find(searchTerm) then
                    table.insert(_G.filteredFavoritesAnimationsForDisplay, favorite)
                end
            end
        end
    end

    State.totalPages = calculateTotalPages()
    State.currentPage = 1
    updatePageDisplay()
    updateAnimations()
end

local function goToPage(pageNumber)
    if pageNumber < 1 then
        State.currentPage = 1
    elseif pageNumber > State.totalPages then
        State.currentPage = State.totalPages
    else
        State.currentPage = pageNumber
    end
    updatePageDisplay()
    updateEmotes()
end

local function previousPage()
    if State.currentPage <= 1 then
        State.currentPage = State.totalPages
    else
        State.currentPage = State.currentPage - 1
    end
    updatePageDisplay()
    updateEmotes()
end

local function nextPage()
    if State.currentPage >= State.totalPages then
        State.currentPage = 1
    else
        State.currentPage = State.currentPage + 1
    end
    updatePageDisplay()
    updateEmotes()
end

local function stopCurrentEmote()
    if State.currentEmoteTrack then
        State.currentEmoteTrack:Stop()
        State.currentEmoteTrack = nil
    end
end

local function playEmote(humanoid, emoteId)
    stopCurrentEmote()
    stopEmotes()

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. emoteId

    local success, animTrack = pcall(function()
        return humanoid.Animator:LoadAnimation(animation)
    end)

    if success and animTrack then
        State.currentEmoteTrack = animTrack
        State.currentEmoteTrack.Priority = Enum.AnimationPriority.Action
        State.currentEmoteTrack.Looped = true
        task.wait(0.1)
        if State.speedEmoteEnabled or State.emotesWalkEnabled then
            State.currentEmoteTrack:Play()

            if State.speedEmoteEnabled then
                local speedValue = tonumber(UI.SpeedBox.Text) or 1
                State.currentEmoteTrack:AdjustSpeed(speedValue)
            end
        end
    end
end

local function onCharacterAdded(character)
    State.currentCharacter = character
    stopCurrentEmote()

    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")

 if getgenv().autoReloadEnabled and getgenv().lastPlayedAnimation then
    task.wait(.3)
    applyAnimation(getgenv().lastPlayedAnimation)
    getgenv().Notify({
        Title = '7yd7 | Auto Reload Animation',
        Content = '🔄 The last animation was automatically \n reapplied',
        Duration = 3
    })
end

    animator.AnimationPlayed:Connect(function(animationTrack)
        if isDancing(character, animationTrack) then
            local playedEmoteId = urlToId(animationTrack.Animation.AnimationId)

            if State.emotesWalkEnabled then
                if State.currentEmoteTrack then
                    local currentEmoteId = urlToId(State.currentEmoteTrack.Animation.AnimationId)
                    if currentEmoteId == playedEmoteId then
                        return
                    else
                        stopCurrentEmote()
                    end
                end

                playEmote(humanoid, playedEmoteId)

                if currentEmoteTrack then
                    currentEmoteTrack.Ended:Connect(function()
                        if currentEmoteTrack == animationTrack then
                            currentEmoteTrack = nil
                        end
                    end)
                end
            end

            if State.speedEmoteEnabled and not State.emotesWalkEnabled then
                if State.currentEmoteTrack then
                    local currentEmoteId = urlToId(State.currentEmoteTrack.Animation.AnimationId)
                    if currentEmoteId == playedEmoteId then
                        return
                    else
                        stopCurrentEmote()
                    end
                end

                playEmote(humanoid, playedEmoteId)

                if currentEmoteTrack then
                    currentEmoteTrack.Ended:Connect(function()
                        if currentEmoteTrack == animationTrack then
                            currentEmoteTrack = nil
                        end
                    end)
                end
            end
        end
    end)

    humanoid.Died:Connect(function()
    if State.hudEditorActive and exitHUDEditor then exitHUDEditor() end
    State.emotesWalkEnabled = false
    State.speedEmoteEnabled = false
    State.favoriteEnabled = false
    State.currentEmoteTrack = nil

    stopEmotes()
        stopCurrentEmote()
    end)
end

local function toggleEmoteWalk()
    State.emotesWalkEnabled = not State.emotesWalkEnabled

    if State.emotesWalkEnabled then
        getgenv().Notify({
            Title = '7yd7 | Emote Freeze',
            Content = "🔒 Emote freeze ON",
            Duration = 5
        })

        UI.EmoteWalkButton.Image = State.enabledButtonImage
        task.wait(0.1)
        stopCurrentEmote()
        if State.currentEmoteTrack and State.currentEmoteTrack.IsPlaying then
            State.currentEmoteTrack:AdjustSpeed(1)
        end
    else
        getgenv().Notify({
            Title = '7yd7 | Emote Freeze',
            Content = '🔓 Emote freeze OFF',
            Duration = 5
        })
        UI.EmoteWalkButton.Image = State.defaultButtonImage
        task.wait(0.1)
        stopCurrentEmote()

        if State.currentEmoteTrack and State.currentEmoteTrack.IsPlaying and State.speedEmoteEnabled then
            local speedValue = tonumber(UI.SpeedBox.Text) or 1
            State.currentEmoteTrack:AdjustSpeed(speedValue)
        elseif State.currentEmoteTrack and State.currentEmoteTrack.IsPlaying then
            State.currentEmoteTrack:AdjustSpeed(1)
        end
    end
end
print(Players.LocalPlayer.Name)
local function toggleSpeedEmote()
    State.speedEmoteEnabled = not State.speedEmoteEnabled

    UI.SpeedBox.Visible = State.speedEmoteEnabled

    if State.speedEmoteEnabled then
        getgenv().Notify({
            Title = '7yd7 | Speed Emote',
            Content = "⚡ Speed Emote ON",
            Duration = 5
        })
        task.wait(0.1)
        stopCurrentEmote()
    else
        getgenv().Notify({
            Title = '7yd7 | Speed Emote',
            Content = '⚡ Speed Emote OFF',
            Duration = 5
        })
        task.wait(0.1)
        stopCurrentEmote()
    end

    Config.EmoteSpeedEnabled = State.speedEmoteEnabled
    Config.EmoteSpeed = tonumber(UI.SpeedBox.Text) or 1
    SaveConfig()
end

local function toggleFavoriteMode()
    State.favoriteEnabled = not State.favoriteEnabled

    if State.favoriteEnabled then
        ApplyFavoriteButtonVisual()
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = "🔒 Favorite ON",
            Duration = 5
        })

        if State.currentMode == "emote" then
            setupEmoteClickDetection()
        else 
            updateAllFavoriteIcons()
        end
    else
        ApplyFavoriteButtonVisual()
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '🔓 Favorite OFF',
            Duration = 3
        })
        
        if State.currentMode == "emote" then
            stopEmoteClickDetection()
        else
            updateAllFavoriteIcons()
        end
    end

    pcall(function()
        local frontFrame = CoreGui.RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
        frontFrame.Active = not State.favoriteEnabled
        for _, child in pairs(frontFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Active = not State.favoriteEnabled
            end
        end
    end)
end

local clickCooldown = {}
local CLICK_COOLDOWN_TIME = 0.1

local function safeButtonClick(buttonName, callback)
    if State.hudEditorActive then return end
    local currentTime = tick()
    if not clickCooldown[buttonName] or (currentTime - clickCooldown[buttonName]) > CLICK_COOLDOWN_TIME then
        clickCooldown[buttonName] = currentTime
        callback()
    end
end

local function setupAnimationClickDetection()
    if State.isMonitoringClicks then
        return
    end
    
    if State.currentMode == "animation" then
        State.isMonitoringClicks = true
        task.spawn(monitorAnimations)
    end
end

local function toggleAutoReload()
    getgenv().autoReloadEnabled = not getgenv().autoReloadEnabled
    
    if getgenv().autoReloadEnabled then
        getgenv().Notify({
            Title = '7yd7 | Auto Reload Animation',
            Content = "🔄 Auto Reload ON",
            Duration = 5
        })
    else
        getgenv().Notify({
            Title = '7yd7 | Auto Reload Animation',
            Content = '🔄 Auto Reload OFF',
            Duration = 3
        })
    end
end

function connectEvents()
    disconnectAllConnections()

    if UI._1left then
        table.insert(State.guiConnections, UI._1left.MouseButton1Click:Connect(function()
            safeButtonClick("PrevPage", previousPage)
        end))
    end

    if UI._9right then
        table.insert(State.guiConnections, UI._9right.MouseButton1Click:Connect(function()
            safeButtonClick("NextPage", nextPage)
        end))
    end

    if UI._2Routenumber then
        table.insert(State.guiConnections, UI._2Routenumber.FocusLost:Connect(function(enterPressed)
            if State.hudEditorActive then return end
            local pageNum = tonumber(UI._2Routenumber.Text)
            if pageNum then
                goToPage(pageNum)
            else
                UI._2Routenumber.Text = tostring(State.currentPage)
            end
        end))
    end

    if UI.Search then
        table.insert(State.guiConnections, UI.Search.Changed:Connect(function(property)
            if State.hudEditorActive then return end
            if property == "Text" then
                if State.currentMode == "emote" then
                    State.emoteSearchTerm = UI.Search.Text
                    searchEmotes(State.emoteSearchTerm)
                else
                    State.animationSearchTerm = UI.Search.Text
                    searchAnimations(State.animationSearchTerm)
                end
            end
        end))
    end

    local SECTOR_COUNT = 8
    local SECTOR_ANGLE = 360 / SECTOR_COUNT

    table.insert(State.guiConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if State.hudEditorActive then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        if not (State.favoriteEnabled or State.currentMode == "animation") then return end

        local exists, emotesWheel = checkEmotesMenuExists()
        local isRecentlyVisible = (tick() - State.lastWheelVisibleTime < 0.15)
        if not (exists and (emotesWheel.Visible or isRecentlyVisible)) then return end

        
        local actualPos = Vector2.new(input.Position.X, input.Position.Y)

        local absPos = emotesWheel.AbsolutePosition
        local absSize = emotesWheel.AbsoluteSize

        local inXBounds = (actualPos.X >= absPos.X) and (actualPos.X <= absPos.X + absSize.X)
        local inYBounds = (actualPos.Y >= absPos.Y) and (actualPos.Y <= absPos.Y + absSize.Y)
        if not (inXBounds and inYBounds) then return end

        local center = absPos + (absSize / 2)
        local dx = actualPos.X - center.X
        local dy = actualPos.Y - center.Y

        local distance = math.sqrt(dx*dx + dy*dy)
        local dynamicDeadzone = absSize.X * 0.1 
        if distance < dynamicDeadzone then return end

        local angle = math.deg(math.atan2(dy, dx))
        local correctedAngle = (angle + 90 + (SECTOR_ANGLE / 2)) % 360
        local index = math.floor(correctedAngle / SECTOR_ANGLE) + 1
        
        handleSectorAction(index)
    end))

    if UI.EmoteWalkButton then
        table.insert(State.guiConnections, UI.EmoteWalkButton.MouseButton1Click:Connect(function()
            safeButtonClick("EmoteWalk", toggleEmoteWalk)
        end))
    end

    if UI.Favorite then
        table.insert(State.guiConnections, UI.Favorite.MouseButton1Click:Connect(function()
            safeButtonClick("Favorite", toggleFavoriteMode)
        end))
    end

    if UI.SpeedEmote then
        table.insert(State.guiConnections, UI.SpeedEmote.MouseButton1Click:Connect(function()
            safeButtonClick("SpeedEmote", toggleSpeedEmote)
        end))
    end

    if UI.Reload then
        table.insert(State.guiConnections, UI.Reload.MouseButton1Click:Connect(function()
            safeButtonClick("AutoReload", toggleAutoReload)
        end))
    end

    if UI.Changepage then
        table.insert(State.guiConnections, UI.Changepage.MouseButton1Click:Connect(function()
            safeButtonClick("ChangePage", function()
                stopEmoteClickDetection()
                
                if State.currentMode == "emote" then
                    State.currentMode = "animation"
                    
                    spawn(function()
                        fetchAllAnimations()
                        UI.Search.Text = State.animationSearchTerm
                        State.currentPage = Config.AnimationPage or 1
                        State.totalPages = calculateTotalPages()
                        updatePageDisplay()
                        updateEmotes()
                        State.isMonitoringClicks = true
                        task.spawn(monitorAnimations)
                    end)
                    
                    getgenv().Notify({
                        Title = '7yd7 | Animation',
                        Content = '📄 Changed to Emote > Animation Mode',
                        Duration = 3
                    })

                else
                    State.currentMode = "emote"
                    UI.Search.Text = State.emoteSearchTerm
                    State.currentPage = Config.EmotePage or 1
                    State.totalPages = calculateTotalPages()
                    updatePageDisplay() 
                    updateEmotes()
                    
                    if State.favoriteEnabled then
                        setupEmoteClickDetection()
                    end
                    
                    getgenv().Notify({
                        Title = '7yd7 | Emote', 
                        Content = '📄 Changed to Animation > Emote Mode',
                        Duration = 3
                    })
                end
            end)
        end))
    end

    if UI.SpeedBox then
        table.insert(State.guiConnections, UI.SpeedBox.FocusLost:Connect(function()
            if State.hudEditorActive then return end
            Config.EmoteSpeed = tonumber(UI.SpeedBox.Text) or 1
            SaveConfig()
        end))
    end
end




local function getMovableElements()
    local elems = {}
    if UI.Top then elems["Top"] = UI.Top end
    if UI.Under then elems["Under"] = UI.Under end
    if UI.EmoteWalkButton then elems["EmoteWalkButton"] = UI.EmoteWalkButton end
    if UI.Favorite then elems["Favorite"] = UI.Favorite end
    if UI.SpeedEmote then elems["SpeedEmote"] = UI.SpeedEmote end
    if UI.SpeedBox then elems["SpeedBox"] = UI.SpeedBox end
    if UI.Changepage then elems["Changepage"] = UI.Changepage end
    if UI.Reload then elems["Reload"] = UI.Reload end
    return elems
end

applySavedPositions = function()
    if not Config.HUDPositions then return end
    local elems = getMovableElements()
    for name, pos in pairs(Config.HUDPositions) do
        local el = elems[name]
        if el and type(pos) == "table" and #pos == 4 then
            el.Position = UDim2.new(pos[1], pos[2], pos[3], pos[4])
        end
    end
end

exitHUDEditor = function()
    if not State.hudEditorActive then return end
    State.hudEditorActive = false
    for _, conn in pairs(HUD.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    HUD.Connections = {}
    for _, stroke in pairs(HUD.Strokes) do
        pcall(function() if stroke and stroke.Parent then stroke:Destroy() end end)
    end
    HUD.Strokes = {}
    for _, el in pairs(getMovableElements()) do
        local h = el:FindFirstChild("HUDDragHandle")
        if h then h:Destroy() end
        if el:FindFirstChildOfClass("UIListLayout") then
            for _, child in pairs(el:GetChildren()) do
                if child:IsA("GuiButton") or child:IsA("TextBox") then
                    child.Active = true
                end
            end
        end
    end
    if HUD.Overlay then
        for _, g in pairs(HUD.Overlay:GetChildren()) do
            if g.Name == "SnapGuide" then g:Destroy() end
        end
    end
    if HUD.Overlay and HUD.Overlay.Parent then HUD.Overlay:Destroy() end
    HUD.Overlay = nil
    if HUD.ForceVisibleConn then HUD.ForceVisibleConn:Disconnect(); HUD.ForceVisibleConn = nil end
    if UI.Search then UI.Search.TextEditable = true; UI.Search.Active = true end
    if UI.SpeedBox then UI.SpeedBox.TextEditable = true; UI.SpeedBox.Active = true end
    if UI._2Routenumber then UI._2Routenumber.TextEditable = true; UI._2Routenumber.Active = true end
    pcall(function() game:GetService("GuiService"):SetEmotesMenuOpen(false) end)
    pcall(function() game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Visible = false end)
end

enterHUDEditor = function()
    if State.hudEditorActive then return end
    State.hudEditorActive = true

    game:GetService("GuiService"):SetEmotesMenuOpen(false)
    task.wait(0.15)

    local exists, emotesWheel = checkEmotesMenuExists()
    if not exists then State.hudEditorActive = false; return end
    emotesWheel.Visible = true

    HUD.ForceVisibleConn = RunService.Heartbeat:Connect(function()
        if not State.hudEditorActive then return end
        pcall(function()
            local _, ew = checkEmotesMenuExists()
            if ew then ew.Visible = true end
        end)
    end)

    local main = getSettingsMainFrame()
    if main then main.Visible = false end
    syncToggleVisibility()

    local overlay = Instance.new("Frame")
    overlay.Name = "HUDEditorOverlay"
    overlay.Parent = SettingsLib.UI
    overlay.BackgroundTransparency = 1
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.ZIndex = 6000
    overlay.Active = false
    HUD.Overlay = overlay

    local bc = Instance.new("Frame")
    bc.Parent = overlay
    bc.BackgroundTransparency = 1
    bc.AnchorPoint = Vector2.new(1, 0)
    bc.Position = UDim2.new(1, -10, 0, 10)
    bc.Size = UDim2.fromOffset(100, 42)
    bc.ZIndex = 6000

    local bl = Instance.new("UIListLayout")
    bl.FillDirection = Enum.FillDirection.Horizontal
    bl.Padding = UDim.new(0, 8)
    bl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    bl.VerticalAlignment = Enum.VerticalAlignment.Center
    bl.Parent = bc

    local resetBtn = Instance.new("ImageButton")
    resetBtn.Parent = bc
    resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    resetBtn.BackgroundTransparency = 0.4
    resetBtn.Size = UDim2.fromOffset(42, 42)
    resetBtn.Image = "rbxassetid://123088523596870"
    resetBtn.ZIndex = 6001
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 10)

    local backBtn = Instance.new("ImageButton")
    backBtn.Parent = bc
    backBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backBtn.BackgroundTransparency = 0.4
    backBtn.Size = UDim2.fromOffset(42, 42)
    backBtn.Image = "rbxassetid://79024388644722"
    backBtn.ZIndex = 6001
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 10)

    table.insert(HUD.Connections, backBtn.MouseButton1Click:Connect(function()
        exitHUDEditor()
    end))

    table.insert(HUD.Connections, resetBtn.MouseButton1Click:Connect(function()
        Config.HUDPositions = {}
        SaveConfig()
        for name, el in pairs(getMovableElements()) do
            if HUD.DefaultPositions[name] then el.Position = HUD.DefaultPositions[name] end
        end
        getgenv().Notify({ Title = "7yd7 | HUD Editor", Content = "🔄 Positions reset to default", Duration = 3 })
    end))

    if UI.Search then UI.Search.TextEditable = false; UI.Search.Active = false; pcall(function() UI.Search:ReleaseFocus() end) end
    if UI.SpeedBox then UI.SpeedBox.TextEditable = false; UI.SpeedBox.Active = false; pcall(function() UI.SpeedBox:ReleaseFocus() end) end
    if UI._2Routenumber then UI._2Routenumber.TextEditable = false; UI._2Routenumber.Active = false; pcall(function() UI._2Routenumber:ReleaseFocus() end) end

    local SNAP_THRESHOLD = 8
    local allMovable = getMovableElements()
    local snapGuideH, snapGuideV

    local function createSnapGuides()
        if not HUD.Overlay then return end
        snapGuideH = Instance.new("Frame")
        snapGuideH.Name = "SnapGuide"
        snapGuideH.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        snapGuideH.BorderSizePixel = 0
        snapGuideH.Size = UDim2.new(1, 0, 0, 1)
        snapGuideH.ZIndex = 6002
        snapGuideH.Visible = false
        snapGuideH.Parent = HUD.Overlay
        snapGuideV = Instance.new("Frame")
        snapGuideV.Name = "SnapGuide"
        snapGuideV.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        snapGuideV.BorderSizePixel = 0
        snapGuideV.Size = UDim2.new(0, 1, 1, 0)
        snapGuideV.ZIndex = 6002
        snapGuideV.Visible = false
        snapGuideV.Parent = HUD.Overlay
    end
    createSnapGuides()

    local function snapCalc(element, newPos, currentName)
        local parent = element.Parent
        if not parent then return newPos, nil, nil end
        local ps = parent.AbsoluteSize
        local pp = parent.AbsolutePosition
        local absX = pp.X + newPos.X.Scale * ps.X + newPos.X.Offset
        local absY = pp.Y + newPos.Y.Scale * ps.Y + newPos.Y.Offset
        local absW = element.AbsoluteSize.X
        local absH = element.AbsoluteSize.Y
        local sX, sY = absX, absY
        local didX, didY = false, false
        local guideX, guideY
        for oName, oEl in pairs(allMovable) do
            if oName ~= currentName then
                local oX = oEl.AbsolutePosition.X
                local oY = oEl.AbsolutePosition.Y
                local oW = oEl.AbsoluteSize.X
                local oH = oEl.AbsoluteSize.Y
                if not didX then
                    if math.abs(absX - oX) < SNAP_THRESHOLD then sX = oX; didX = true; guideX = oX end
                    if math.abs(absX - (oX + oW)) < SNAP_THRESHOLD then sX = oX + oW; didX = true; guideX = oX + oW end
                    if math.abs((absX + absW) - oX) < SNAP_THRESHOLD then sX = oX - absW; didX = true; guideX = oX end
                    if math.abs((absX + absW) - (oX + oW)) < SNAP_THRESHOLD then sX = oX + oW - absW; didX = true; guideX = oX + oW end
                    if math.abs((absX + absW/2) - (oX + oW/2)) < SNAP_THRESHOLD then sX = oX + oW/2 - absW/2; didX = true; guideX = oX + oW/2 end
                end
                if not didY then
                    if math.abs(absY - oY) < SNAP_THRESHOLD then sY = oY; didY = true; guideY = oY end
                    if math.abs(absY - (oY + oH)) < SNAP_THRESHOLD then sY = oY + oH; didY = true; guideY = oY + oH end
                    if math.abs((absY + absH) - oY) < SNAP_THRESHOLD then sY = oY - absH; didY = true; guideY = oY end
                    if math.abs((absY + absH) - (oY + oH)) < SNAP_THRESHOLD then sY = oY + oH - absH; didY = true; guideY = oY + oH end
                    if math.abs((absY + absH/2) - (oY + oH/2)) < SNAP_THRESHOLD then sY = oY + oH/2 - absH/2; didY = true; guideY = oY + oH/2 end
                end
            end
        end
        local fsx = (sX - pp.X) / ps.X
        local fsy = (sY - pp.Y) / ps.Y
        return UDim2.new(fsx, newPos.X.Offset, fsy, newPos.Y.Offset), guideX, guideY
    end

    for name, element in pairs(allMovable) do
        element.Visible = true

        local stroke = Instance.new("UIStroke")
        stroke.Name = "HUDEditorStroke"
        stroke.Color = Color3.fromRGB(0, 255, 100)
        stroke.Thickness = 2
        stroke.Parent = element
        table.insert(HUD.Strokes, stroke)

        local hasLayout = element:FindFirstChildOfClass("UIListLayout")
        local inputTarget

        if hasLayout then
            for _, child in pairs(element:GetChildren()) do
                if child:IsA("GuiButton") or child:IsA("TextBox") then
                    child.Active = false
                end
            end
            element.Active = true
            inputTarget = element
        else
            local dh = Instance.new("TextButton")
            dh.Name = "HUDDragHandle"
            dh.Parent = element
            dh.BackgroundTransparency = 1
            dh.Text = ""
            dh.Size = UDim2.fromScale(1, 1)
            dh.ZIndex = 9999
            dh.Active = true
            inputTarget = dh
        end

        local dragging = false
        local dragStart, startPos

        table.insert(HUD.Connections, inputTarget.InputBegan:Connect(function(input)
            if not State.hudEditorActive then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = element.Position
                stroke.Color = Color3.fromRGB(255, 255, 255)
            end
        end))

        table.insert(HUD.Connections, UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                local ps = element.Parent and element.Parent.AbsoluteSize or Vector2.new(1, 1)
                local rawPos = UDim2.new(
                    startPos.X.Scale + delta.X / ps.X, startPos.X.Offset,
                    startPos.Y.Scale + delta.Y / ps.Y, startPos.Y.Offset
                )
                local snapped, gx, gy = snapCalc(element, rawPos, name)
                element.Position = snapped
                local ovP = HUD.Overlay and HUD.Overlay.AbsolutePosition or Vector2.new(0, 0)
                if snapGuideV then snapGuideV.Visible = (gx ~= nil); if gx then snapGuideV.Position = UDim2.fromOffset(gx - ovP.X, 0) end end
                if snapGuideH then snapGuideH.Visible = (gy ~= nil); if gy then snapGuideH.Position = UDim2.fromOffset(0, gy - ovP.Y) end end
            end
        end))

        table.insert(HUD.Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    stroke.Color = Color3.fromRGB(0, 255, 100)
                    if snapGuideV then snapGuideV.Visible = false end
                    if snapGuideH then snapGuideH.Visible = false end
                    Config.HUDPositions[name] = {
                        element.Position.X.Scale, element.Position.X.Offset,
                        element.Position.Y.Scale, element.Position.Y.Offset
                    }
                    SaveConfig()
                end
            end
        end))
    end

    getgenv().Notify({ Title = "7yd7 | HUD Editor", Content = "✏️ Drag elements to reposition", Duration = 5 })
end

local function checkAndRecreateGUI()
    local exists, emotesWheel = checkEmotesMenuExists()
    if not exists then
        isGUICreated = false
        return
    end

    if not emotesWheel:FindFirstChild("Under") or not emotesWheel:FindFirstChild("Top") or
        not emotesWheel:FindFirstChild("EmoteWalkButton") or not emotesWheel:FindFirstChild("Favorite") or
        not emotesWheel:FindFirstChild("SpeedEmote") or not emotesWheel:FindFirstChild("SpeedBox") or
        not emotesWheel:FindFirstChild("Changepage") or not emotesWheel:FindFirstChild("Reload") then
        isGUICreated = false
        if createGUIElements() then
            updatePageDisplay()
            updateEmotes()
            loadSpeedEmoteConfig()
        end
    end
end

if player.Character then
    onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    onCharacterAdded(char)
    
    task.spawn(function()
        local attempts = 0
        while attempts < 20 do
            if checkEmotesMenuExists() then
                task.wait(0.2)
                stopEmotes()
                if createGUIElements() then
                    updatePageDisplay()
                    updateEmotes()
                    updateGUIColors()
                    loadSpeedEmoteConfig()
                end
                break
            end
            attempts = attempts + 1
            task.wait(0.1)
        end
    end)
end)


local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not State.isGUICreated then
        checkAndRecreateGUI()
    else
        updateGUIColors()
    end
end)


local function safeFind(path, name)
    if not path then return nil end
    local ok, result = pcall(function()
        return path:FindFirstChild(name)
    end)
    if ok then
        return result
    end
    return nil
end

RunService.Stepped:Connect(function()
    if humanoid and State.currentEmoteTrack and State.currentEmoteTrack.IsPlaying then
        if humanoid.MoveDirection.Magnitude > 0 then
            if State.speedEmoteEnabled and not State.emotesWalkEnabled then
                State.currentEmoteTrack:Stop()
                State.currentEmoteTrack = nil
            end
        end
    end
end)

spawn(function()
    while not checkEmotesMenuExists() do
        wait(0.1)
    end
    if createGUIElements() then
        loadFavorites()
        loadFavoritesAnimations()
        fetchAllEmotes()
        loadSpeedEmoteConfig()
    end
end)
 local StarterGui = game:GetService("StarterGui")

 StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
task.spawn(function()
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")

    while true do
        local robloxGui = CoreGui:FindFirstChild("RobloxGui")
        local emotesMenu = robloxGui and robloxGui:FindFirstChild("EmotesMenu")

        if not emotesMenu then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)

        else
            local exists = emotesMenu:FindFirstChild("Children") and emotesMenu.Children:FindFirstChild("Main") and
                               emotesMenu.Children.Main:FindFirstChild("EmotesWheel")

            if exists then
                local emotesWheel = emotesMenu.Children.Main.EmotesWheel
                if not emotesWheel:FindFirstChild("Under") or not emotesWheel:FindFirstChild("Top") then
                    if createGUIElements then
                        createGUIElements()
                        loadSpeedEmoteConfig()
                    end

                    if updateGUIColors then
                        updateGUIColors()
                        updatePageDisplay()
                        loadFavorites()
                    end
                end
            end
        end

        task.wait(.3)
    end
end)

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    SafeLoad("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/OpenEmote.lua", "Open Emote")
    getgenv().Notify({
        Title = '7yd7 | Emote Mobile',
        Content = '📱 Added emote open button for ease of use',
        Duration = 10
    })
end

if UserInputService.KeyboardEnabled then
    getgenv().Notify({
        Title = '7yd7 | Emote PC',
        Content = '💻 Open menu press button "."',
        Duration = 10
    })
end
