
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Menu-7yd7/refs/heads/Script/GUIS/Off-site/Notify.lua"))()

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local request = http_request or (syn and syn.request) or request

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
    AnimationPage = 1
}

local Under, UIListLayout, _1left, _9right, _4pages, _3TextLabel, _2Routenumber, Top, EmoteWalkButton, UICorner1,
    UIListLayout_2, UICorner, Search, Favorite, UICorner2, UICorner_2, SpeedEmote, UICorner_4, SpeedBox, UICorner_5, Changepage,
    Reload, UICorner_6
local speedEmoteEnabled = false
local currentMode = "emote"
local emotesWalkEnabled = false
local favoriteEnabled = false

local function ApplyUIVisibility()
    pcall(function()
        if Search and Top then Top.Visible = Config.SearchVisible end
        if Favorite then Favorite.Visible = Config.FavVisible end
        if Changepage then Changepage.Visible = Config.ModeVisible end
        if EmoteWalkButton then EmoteWalkButton.Visible = Config.FreezeVisible end
        if SpeedEmote then SpeedEmote.Visible = Config.SpeedVisible end
        if SpeedBox then 
            SpeedBox.Visible = (Config.SpeedVisible and speedEmoteEnabled) 
        end
        if Under then Under.Visible = Config.NavVisible end
        if Reload then 
            Reload.Visible = (currentMode == "animation" and Config.NavVisible) 
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

local SettingsLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Settings.lua"))()

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
ToggleBtn.Position = UDim2.new(0.005, 0, 0.939, 0)
ToggleBtn.Size = UDim2.new(0.027, 0, 0.049, 0)
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
    elseif _G.EmoteTheme and _G.EmoteTheme.Background then
        ToggleBtn.BackgroundColor3 = _G.EmoteTheme.Background
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
    local theme = _G.EmoteTheme
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

    local theme = _G.EmoteTheme
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

    if _1left then
        _1left.ImageColor3 = getIconColor("Left")
        _1left.ImageTransparency = bgTransparency
    end

    if _9right then
        _9right.ImageColor3 = getIconColor("Right")
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

    if SpeedEmote then
        SpeedEmote.BackgroundColor3 = bgColor
        SpeedEmote.BackgroundTransparency = bgTransparency
    end

     if Changepage then
        Changepage.BackgroundColor3 = bgColor
        Changepage.BackgroundTransparency = bgTransparency
    end

    if SpeedBox then
        SpeedBox.BackgroundColor3 = bgColor
        SpeedBox.BackgroundTransparency = bgTransparency
    end

    if Favorite then
        Favorite.BackgroundColor3 = bgColor
        Favorite.BackgroundTransparency = bgTransparency
    end

    if Reload then
        Reload.BackgroundColor3 = bgColor
        Reload.BackgroundTransparency = bgTransparency
    end
    
    if ApplyFavoriteButtonVisual then
        ApplyFavoriteButtonVisual()
    end
    ApplyUIVisibility()
    applySettingsToggleStyle()
end

ApplyFavoriteButtonVisual = function()
    if not Favorite then return end
    local isOn = favoriteEnabled
    local image = isOn and favoriteIconId or notFavoriteIconId
    if image and image ~= "" then
        Favorite.Image = image
    end
    local colorKey = isOn and "Favorite" or "NotFavorite"
    Favorite.ImageColor3 = GetThemeIconColor(colorKey)
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
    if themeData.Background then
        _G.EmoteTheme = {
            Background = TableToColor(themeData.Background),
            Accent = TableToColor(themeData.Accent or {0, 255, 150}),
            ImageColor = TableToColor(themeData.ImageColor or {255, 255, 255}),
            Icons = themeData.Icons or {},
            IconColors = themeData.IconColors or {},
            Wheel = themeData.Wheel or {}
        }
        
        local function getIconColor(key)
            if _G.EmoteTheme.IconColors and _G.EmoteTheme.IconColors[key] then
                return TableToColor(_G.EmoteTheme.IconColors[key])
            end
            return _G.EmoteTheme.ImageColor 
        end
        
        favoriteIconId = GetAsset(_G.EmoteTheme.Icons.Favorite)
        notFavoriteIconId = GetAsset(_G.EmoteTheme.Icons.NotFavorite)
        
        updateGUIColors()
        
        if _1left then _1left.Image = GetAsset(_G.EmoteTheme.Icons.Left); _1left.ImageColor3 = getIconColor("Left") end
        if _9right then _9right.Image = GetAsset(_G.EmoteTheme.Icons.Right); _9right.ImageColor3 = getIconColor("Right") end
        if EmoteWalkButton then EmoteWalkButton.Image = GetAsset(_G.EmoteTheme.Icons.Walk); EmoteWalkButton.ImageColor3 = getIconColor("Walk") end
        if SpeedEmote then SpeedEmote.Image = GetAsset(_G.EmoteTheme.Icons.Speed); SpeedEmote.ImageColor3 = getIconColor("Speed") end
        if Changepage then Changepage.Image = GetAsset(_G.EmoteTheme.Icons.Page); Changepage.ImageColor3 = getIconColor("Page") end
        if Reload then Reload.Image = GetAsset(_G.EmoteTheme.Icons.Reload); Reload.ImageColor3 = getIconColor("Reload") end
        
        if Favorite then ApplyFavoriteButtonVisual() end 

        
        if UIElements.Background.Main then UIElements.Background.Main.SetValue(_G.EmoteTheme.Background) end
        
        for key, comp in pairs(UIElements.Icons) do
            local iconVal = _G.EmoteTheme.Icons[key] or ""
            local specificColor = _G.EmoteTheme.IconColors and _G.EmoteTheme.IconColors[key]
            local colorVal
            
            if specificColor then
                colorVal = TableToColor(specificColor)
            else
                colorVal = _G.EmoteTheme.ImageColor 
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
                
                local wheel = _G.EmoteTheme.Wheel
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
            local imgVal = _G.EmoteTheme.Wheel[key] or ""
            local colorVal = TableToColor(_G.EmoteTheme.Wheel[key.."Color"] or {255, 255, 255})
            if comp then comp.SetValue(imgVal, colorVal) end
        end
    end
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
    stroke.Color = _G.EmoteTheme.Accent
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
    
    local Save = CreateButton(content, "SAVE", _G.EmoteTheme.Accent, UDim2.new(0.05, 0, 0.6, 0))
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
    
    local Save = CreateButton(content, "RENAME", _G.EmoteTheme.Accent, UDim2.new(0.05, 0, 0.6, 0))
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
    
    local imp = CreateButton(content, "IMPORT THEME", _G.EmoteTheme.Accent, UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.9, 0, 0, 35))

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
    close.Position = UDim2.new(1, -30, 0, -30)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.BackgroundTransparency = 1
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = content
    close.MouseButton1Click:Connect(function() popup:Destroy() end)
end)

SettingsLib.AddIconButton(BtnRow, "107588515524752", function()
    local exportData = { name = currentThemeName, data = themes[currentThemeName] }
    local json = HttpService:JSONEncode(exportData)
    
    local popup, content = CreatePopup("Export Theme", UDim2.fromOffset(320, 240))
    local box = CreateInput(content, "", json, true)
    box.Size = UDim2.new(0.9, 0, 0, 130)
    box.TextEditable = false
    
    local copy = CreateButton(content, "COPY TO CLIPBOARD", _G.EmoteTheme.Accent, UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.9, 0, 0, 35))

    copy.MouseButton1Click:Connect(function()
        setclipboard(json)
        copy.Text = "COPIED!"
        task.delay(1, function() copy.Text = "COPY TO CLIPBOARD" end)
    end)
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(24, 24)
    close.Position = UDim2.new(1, -30, 0, -30)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.BackgroundTransparency = 1
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = content
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
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/Branch/GUIS/count-emote"))()
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

_G.EmoteTheme = _G.EmoteTheme or {
    Background = Color3.fromRGB(28, 30, 32),
    Accent = Color3.fromRGB(0, 255, 150),
    ImageColor = Color3.fromRGB(255, 255, 255)
}

local emoteClickConnections = {}
local guiConnections = {}
local isMonitoringClicks = false
local currentTimer = nil

local animationsData = {}
local originalAnimationsData = {}
local filteredAnimations = {}
local favoriteAnimations = {}
local favoriteAnimationsFileName = "FavoriteAnimations.json"
local emoteSearchTerm = ""
local animationSearchTerm = ""

getgenv().lastPlayedAnimation = getgenv().lastPlayedAnimation or nil
getgenv().autoReloadEnabled = getgenv().autoReloadEnabled or false

local lastRadialActionTime = 0
local lastWheelVisibleTime = 0


RunService.Heartbeat:Connect(function()
    local success, menu = pcall(function() return CoreGui.RobloxGui.EmotesMenu.Children end)
    if not (success and menu) then return end
    
    pcall(function()
        local wheelVisible = menu.Main.EmotesWheel.Visible
        if wheelVisible then
            lastWheelVisibleTime = tick()
        end
        ToggleContainer.Visible = wheelVisible
    end)

    local errorMsg = menu:FindFirstChild("ErrorMessage")

    if errorMsg and errorMsg.Visible then
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            errorMsg.ErrorText.Text = "Only r15 does not work r6"
        elseif tick() - lastRadialActionTime < 2 then
            errorMsg.Visible = false
        end
    end
end)


function ErrorMessage(text, duration)

    if currentTimer then
        task.cancel(currentTimer)
        currentTimer = nil
    end
    
    local errorMessage = CoreGui.RobloxGui.EmotesMenu.Children.ErrorMessage
    local errorText = errorMessage.ErrorText
    
    errorText.Text = text
    
    errorMessage.Visible = true
    
    currentTimer = task.delay(duration, function()
        errorMessage.Visible = false
        currentTimer = nil
    end)
end

local function stopEmotes()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local emotesData = {}
local currentPage = 1
local itemsPerPage = 8
local totalPages = 1
local filteredEmotes = {}
local isLoading = false
local originalEmotesData = {}
local totalEmotesLoaded = 0
local scannedEmotes = {}
local favoriteEmotes = {}
local favoriteFileName = "FavoriteEmotes.json"
local currentEmoteTrack = nil
local currentCharacter = nil
local isGUICreated = false
local speedEmoteConfigFile = "SpeedEmoteConfig.json"

local favoriteSetVersion = 0
local favoriteSetBuiltVersion = -1
local favoriteEmoteSet = {}
local favoriteAnimationSet = {}
local emoteCacheVersion = 0
local animationCacheVersion = 0
local emotePageCache = { version = nil, normal = {}, favorites = {} }
local animationPageCache = { version = nil, normal = {}, favorites = {} }

local defaultButtonImage = "rbxassetid://71408678974152"
local enabledButtonImage = "rbxassetid://106798555684020"

local favoriteIconId = "rbxassetid://97307461910825" 
local notFavoriteIconId = "rbxassetid://124025954365505"

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
        local jsonData = HttpService:JSONEncode(favoriteEmotes)
        writefile(favoriteFileName, jsonData)
    end
end

local function saveFavoritesAnimations()
    if writefile then
        local jsonData = HttpService:JSONEncode(favoriteAnimations)
        writefile(favoriteAnimationsFileName, jsonData)
    end
end

local function loadFavorites()
    if readfile and isfile and isfile(favoriteFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(favoriteFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            favoriteEmotes = result
            favoriteSetVersion = favoriteSetVersion + 1
        end
    end
end

local function loadFavoritesAnimations()
    if readfile and isfile and isfile(favoriteAnimationsFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(favoriteAnimationsFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            favoriteAnimations = result
            favoriteSetVersion = favoriteSetVersion + 1
        end
    end
end

local function disconnectAllConnections()
    for _, connection in pairs(guiConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    guiConnections = {}
end

local function loadSpeedEmoteConfig()
    speedEmoteEnabled = Config.EmoteSpeedEnabled
    if SpeedBox then
        SpeedBox.Text = tostring(Config.EmoteSpeed)
        SpeedBox.Visible = (speedEmoteEnabled and Config.SpeedVisible)
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
    if favoriteSetBuiltVersion ~= favoriteSetVersion then
        favoriteEmoteSet = {}
        for _, favorite in pairs(favoriteEmotes) do
            favoriteEmoteSet[tostring(favorite.id)] = true
        end
        favoriteAnimationSet = {}
        for _, favorite in pairs(favoriteAnimations) do
            favoriteAnimationSet[tostring(favorite.id)] = true
        end
        favoriteSetBuiltVersion = favoriteSetVersion
    end
    if currentMode == "animation" then
        return favoriteAnimationSet[tostring(assetId)] == true
    end
    return favoriteEmoteSet[tostring(assetId)] == true
end

local function rebuildEmoteNormalCache()
    if emotePageCache.version == emoteCacheVersion and emotePageCache.favVersion == favoriteSetVersion then
        return
    end
    if favoriteSetBuiltVersion ~= favoriteSetVersion then
        favoriteEmoteSet = {}
        for _, favorite in pairs(favoriteEmotes) do
            favoriteEmoteSet[tostring(favorite.id)] = true
        end
        favoriteAnimationSet = {}
        for _, favorite in pairs(favoriteAnimations) do
            favoriteAnimationSet[tostring(favorite.id)] = true
        end
        favoriteSetBuiltVersion = favoriteSetVersion
    end
    local normal = {}
    for _, emote in ipairs(filteredEmotes) do
        if not favoriteEmoteSet[tostring(emote.id)] then
            table.insert(normal, emote)
        end
    end
    emotePageCache.normal = normal
    emotePageCache.version = emoteCacheVersion
    emotePageCache.favVersion = favoriteSetVersion
end

local function rebuildAnimationNormalCache()
    if animationPageCache.version == animationCacheVersion and animationPageCache.favVersion == favoriteSetVersion then
        return
    end
    if favoriteSetBuiltVersion ~= favoriteSetVersion then
        favoriteEmoteSet = {}
        for _, favorite in pairs(favoriteEmotes) do
            favoriteEmoteSet[tostring(favorite.id)] = true
        end
        favoriteAnimationSet = {}
        for _, favorite in pairs(favoriteAnimations) do
            favoriteAnimationSet[tostring(favorite.id)] = true
        end
        favoriteSetBuiltVersion = favoriteSetVersion
    end
    local normal = {}
    for _, animation in ipairs(filteredAnimations) do
        if not favoriteAnimationSet[tostring(animation.id)] then
            table.insert(normal, animation)
        end
    end
    animationPageCache.normal = normal
    animationPageCache.version = animationCacheVersion
    animationPageCache.favVersion = favoriteSetVersion
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

                child.Active = not favoriteEnabled

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
    
    frontFrame.Active = not favoriteEnabled
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
        favoriteIcon.Image = favoriteIconId
    else
        favoriteIcon.Image = notFavoriteIconId 
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
                if currentMode == "animation" then
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
                child.Active = not favoriteEnabled
            end
        end
        frontFrame.Active = not favoriteEnabled
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
    local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or favoriteAnimations
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
    local isInFavoritesPages = currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageAnimations, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalAnimations = animationPageCache.normal or {}
        local adjustedPage = currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #normalAnimations)

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
        if favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function updateEmotes()
    local character, humanoid = getCharacterAndHumanoid()
    if not character or not humanoid then
        return
    end

    if currentMode == "animation" then
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
    local favoritesToUse = _G.filteredFavoritesForDisplay or favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
    local isInFavoritesPages = currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageEmotes, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalEmotes = emotePageCache.normal or {}
        local adjustedPage = currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #normalEmotes)

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
        if favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function calculateTotalPages()
      if currentMode == "animation" then
        local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or favoriteAnimations
        local hasFavorites = #favoritesToUse > 0
        rebuildAnimationNormalCache()
        local normalAnimationsCount = #animationPageCache.normal

        local pages = 0
        if hasFavorites then
            pages = pages + math.ceil(#favoritesToUse / itemsPerPage)
        end
        if normalAnimationsCount > 0 then
            pages = pages + math.ceil(normalAnimationsCount / itemsPerPage)
        end
        return math.max(pages, 1)
    end
    
    local favoritesToUse = _G.filteredFavoritesForDisplay or favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    rebuildEmoteNormalCache()
    local normalEmotesCount = #emotePageCache.normal

    local pages = 0

    if hasFavorites then
        pages = pages + math.ceil(#favoritesToUse / itemsPerPage)
    end

    if normalEmotesCount > 0 then
        pages = pages + math.ceil(normalEmotesCount / itemsPerPage)
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
    Favorite = Instance.new("ImageButton")
    UICorner2 = Instance.new("UICorner")
    SpeedBox = Instance.new("TextBox")
    UICorner_4 = Instance.new("UICorner")
    SpeedEmote = Instance.new("ImageButton")
    UICorner_2 = Instance.new("UICorner")
    Changepage = Instance.new("ImageButton")
     UICorner_5 = Instance.new("UICorner")
     Reload = Instance.new("ImageButton")
     UICorner_6 = Instance.new("UICorner")

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
    Search.PlaceholderText = "Search/ID"
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

    Favorite.Name = "Favorite"
    Favorite.Parent = emotesWheel
    Favorite.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Favorite.BackgroundTransparency = 0.400
    Favorite.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Favorite.BorderSizePixel = 0
    Favorite.Position = UDim2.new(0.0189999994, 0, -0.108000003, 0)
    Favorite.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    Favorite.Image = "rbxassetid://124025954365505"

    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = Favorite

    SpeedBox.Name = "SpeedBox"
    SpeedBox.Parent = emotesWheel
    SpeedBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedBox.BackgroundTransparency = 0.400
    SpeedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SpeedBox.BorderSizePixel = 0
    SpeedBox.Position = UDim2.new(0.0189999398, 0, -0.000499992399, 0)
    SpeedBox.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    SpeedBox.Visible = false
    SpeedBox.Font = Enum.Font.SourceSansBold
    SpeedBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    SpeedBox.Text = "1"
    SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBox.TextScaled = true
    SpeedBox.TextWrapped = true
    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
       SpeedBox.Text = SpeedBox.Text:gsub("[^%d.]", "")
    end)
    SpeedBox.ZIndex = 2

    UICorner_4.CornerRadius = UDim.new(0, 10)
    UICorner_4.Parent = SpeedBox

    SpeedEmote.Name = "SpeedEmote"
    SpeedEmote.Parent = emotesWheel
    SpeedEmote.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedEmote.BackgroundTransparency = 0.400
    SpeedEmote.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SpeedEmote.BorderSizePixel = 0
    SpeedEmote.Position = UDim2.new(0.888999999, 0, -0, 0)
    SpeedEmote.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    SpeedEmote.Image = "rbxassetid://116056570415896"
    SpeedEmote.ZIndex = 2

    UICorner_2.CornerRadius = UDim.new(0, 10)
    UICorner_2.Parent = SpeedEmote

Changepage.Name = "Changepage"
Changepage.Parent = emotesWheel
Changepage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Changepage.BackgroundTransparency = 0.400
Changepage.BorderColor3 = Color3.fromRGB(0, 0, 0)
Changepage.BorderSizePixel = 0
Changepage.Position = UDim2.new(0.019, 0,1.021, 0)
Changepage.Size = UDim2.new(0.087, 0,0.087, 0)
Changepage.ZIndex = 3
Changepage.Image = "rbxassetid://13285615740"

UICorner_5.CornerRadius = UDim.new(0, 10)
UICorner_5.Parent = Changepage

Reload.Name = "Reload"
Reload.Parent = emotesWheel
Reload.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Reload.BackgroundTransparency = 0.400
Reload.BorderColor3 = Color3.fromRGB(0, 0, 0)
Reload.BorderSizePixel = 0
Reload.Position = UDim2.new(0.888999999, 0, 1.02100003, 0)
Reload.Size = UDim2.new(0.0869999975, 0, 0.0869999975, 0)
Reload.ZIndex = 3
Reload.Image = "rbxassetid://127493377027615"

UICorner_6.CornerRadius = UDim.new(0, 10)
UICorner_6.Parent = Reload

    loadSpeedEmoteConfig()

    connectEvents()
    isGUICreated = true
    
    ApplyTheme(themes[currentThemeName] or themes.Default)
    
    updateGUIColors()
    
    ApplyUIVisibility()
    
    return true
end

local function updatePageDisplay()
    if _4pages and _2Routenumber then
        _4pages.Text = tostring(totalPages)
        _2Routenumber.Text = tostring(currentPage)
    end
    if currentMode == "animation" then
        Config.AnimationPage = currentPage
    else
        Config.EmotePage = currentPage
    end
    SaveConfig()
end


local function toggleFavorite(emoteId, emoteName)
    local found = false

    local index = 0

    for i, fav in pairs(favoriteEmotes) do
        if fav.id == emoteId then
            found = true
            index = i
            break
        end
    end

    if found then
        table.remove(favoriteEmotes, index)
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '🗑️ Removed "' .. emoteName .. '" from favorites',
            Duration = 3
        })
    else
        table.insert(favoriteEmotes, {
            id = emoteId,
            name = emoteName .. " - ⭐"
        })
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '✅ Added "' .. emoteName .. '" to favorites',
            Duration = 3
        })
    end

    favoriteSetVersion = favoriteSetVersion + 1
    saveFavorites()
    totalPages = calculateTotalPages()
    updatePageDisplay()
    updateEmotes()
    updateAllFavoriteIcons()
end


local function toggleFavoriteAnimation(animationData)
    local found = false


    local index = 0

    for i, fav in pairs(favoriteAnimations) do
        if fav.id == animationData.id then
            found = true
            index = i
            break
        end
    end

    if found then
        table.remove(favoriteAnimations, index)
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = '🗑️ Removed "' .. animationData.name .. '" from favorites',
            Duration = 3
        })
    else
        table.insert(favoriteAnimations, {
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

    favoriteSetVersion = favoriteSetVersion + 1
    saveFavoritesAnimations()
    totalPages = calculateTotalPages()
    updatePageDisplay()
    updateAnimations()
    updateAllFavoriteIcons()
end


local function setupEmoteClickDetection()
    if isMonitoringClicks then
        return
    end
   
    local function monitorEmotes()
        while favoriteEnabled do
            local success, frontFrame = pcall(function()
                return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
            end)
           
            if success and frontFrame then
                for _, connection in pairs(emoteClickConnections) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                emoteClickConnections = {}
               
                for _, child in pairs(frontFrame:GetChildren()) do
                    if child:IsA("ImageLabel") and child.Image ~= "" then
                        local imageUrl = child.Image
                        local assetId = extractAssetId(imageUrl)
                        if assetId then
                            local isFavorite = isInFavorites(assetId)
                            updateFavoriteIcon(child, assetId, isFavorite)
                        end
                        child.Active = not favoriteEnabled
                    end
                end
                frontFrame.Active = not favoriteEnabled
            end
           
            task.wait(0.1)
        end
       
        for _, connection in pairs(emoteClickConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        emoteClickConnections = {}
        isMonitoringClicks = false
    end
   
    if favoriteEnabled then
        isMonitoringClicks = true
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

local lastActionTick = 0
local function handleSectorAction(index)
    if tick() - lastActionTick < 0.25 then return end
    lastActionTick = tick()
    
    task.wait(0.05)

    local favoritesToUse = (currentMode == "animation") and (_G.filteredFavoritesAnimationsForDisplay or favoriteAnimations) or (_G.filteredFavoritesForDisplay or favoriteEmotes)
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
    local isInFavoritesPages = currentPage <= favoritePagesCount

    local function getEmoteAtIndex(idx)
        if isInFavoritesPages and hasFavorites then
            local startIndex = (currentPage - 1) * itemsPerPage + 1
            return favoritesToUse[startIndex + idx - 1]
        else
            local filteredList = (currentMode == "animation") and filteredAnimations or filteredEmotes
            local normalList = {}
            for _, item in pairs(filteredList) do
                if not isInFavorites(item.id) then
                    table.insert(normalList, item)
                end
            end
            local adjustedPage = currentPage - favoritePagesCount
            local startIndex = (adjustedPage - 1) * itemsPerPage + 1
            return normalList[startIndex + idx - 1]
        end
    end

    local itemData = getEmoteAtIndex(index)
    if not itemData then return end

    lastRadialActionTime = tick()


    if favoriteEnabled then
        if currentMode == "animation" then
            toggleFavoriteAnimation(itemData)
        else
            toggleFavorite(itemData.id, itemData.name)
        end
    else
        if currentMode == "animation" then
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
    while currentMode == "animation" do
        local success, frontFrame = pcall(function()
            return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
        end)
        
        if success and frontFrame then
            for _, connection in pairs(emoteClickConnections) do
                if connection then
                    connection:Disconnect()
                end
            end
            emoteClickConnections = {}
            
            local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or favoriteAnimations
            local hasFavorites = #favoritesToUse > 0
            local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
            local isInFavoritesPages = currentPage <= favoritePagesCount
            
            local currentPageAnimations = {}
            
            if isInFavoritesPages and hasFavorites then
                local startIndex = (currentPage - 1) * itemsPerPage + 1
                local endIndex = math.min(startIndex + itemsPerPage - 1, #favoritesToUse)
                
                for i = startIndex, endIndex do
                    if favoritesToUse[i] then
                        table.insert(currentPageAnimations, favoritesToUse[i])
                    end
                end
            else
                local normalAnimations = {}
                for _, animation in pairs(filteredAnimations) do
                    if not isInFavorites(animation.id) then
                        table.insert(normalAnimations, animation)
                    end
                end
                
                local adjustedPage = currentPage - favoritePagesCount
                local startIndex = (adjustedPage - 1) * itemsPerPage + 1
                local endIndex = math.min(startIndex + itemsPerPage - 1, #normalAnimations)
                
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
                        
                        if favoriteEnabled then
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
    isMonitoringClicks = false
    
    for _, connection in pairs(emoteClickConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    emoteClickConnections = {}
    
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
    if isLoading then
        return
    end
    isLoading = true
    emotesData = {}
    totalEmotesLoaded = 0

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
                table.insert(emotesData, emoteData)
                totalEmotesLoaded = totalEmotesLoaded + 1
            end
        end
    else
        emotesData = {
            {id = 3360686498, name = "Stadium"},
            {id = 3360692915, name = "Tilt"},
            {id = 3576968026, name = "Shrug"},
            {id = 3360689775, name = "Salute"}
        }
        totalEmotesLoaded = #emotesData
    end

    originalEmotesData = emotesData
    filteredEmotes = emotesData
    emoteCacheVersion = emoteCacheVersion + 1

    totalPages = calculateTotalPages()
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

local function fetchAllAnimations()
    if isLoading then
        return
    end
    isLoading = true
    animationsData = {}
    
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
                table.insert(animationsData, animationData)
            end
        end
    end

    originalAnimationsData = animationsData
    filteredAnimations = animationsData
    animationCacheVersion = animationCacheVersion + 1
    isLoading = false
end

local function searchEmotes(searchTerm)
    if isLoading then
        getgenv().Notify({
            Title = '7yd7 | Emote',
            Content = '⚠️ Loading please wait...',
            Duration = 5
        })
        return
    end

    searchTerm = searchTerm:lower()

    if searchTerm == "" then
        filteredEmotes = originalEmotesData
        emoteCacheVersion = emoteCacheVersion + 1
        if _G.originalFavoritesBackup then
            _G.originalFavoritesBackup = nil
        end
        _G.filteredFavoritesForDisplay = nil
    else
        local isIdSearch = searchTerm:match("^%d%d%d%d%d+$")
        
        local newFilteredList = {}
        
        if isIdSearch then
            for _, emote in pairs(originalEmotesData) do
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
                    
                    table.insert(originalEmotesData, newEmote)
                    table.insert(newFilteredList, newEmote)
                end
            end
        else
            for _, emote in pairs(originalEmotesData) do
                if emote.name:lower():find(searchTerm) then
                    table.insert(newFilteredList, emote)
                end
            end
        end
        
        filteredEmotes = newFilteredList
        emoteCacheVersion = emoteCacheVersion + 1

        if not isIdSearch then
            if not _G.originalFavoritesBackup then
                _G.originalFavoritesBackup = {}
                for i, favorite in pairs(favoriteEmotes) do
                    _G.originalFavoritesBackup[i] = {
                        id = favorite.id,
                        name = favorite.name
                    }
                end
            end

            _G.filteredFavoritesForDisplay = {}
            for _, favorite in pairs(favoriteEmotes) do
                if favorite.name:lower():find(searchTerm) then
                    table.insert(_G.filteredFavoritesForDisplay, favorite)
                end
            end
        end
    end

    totalPages = calculateTotalPages()
    currentPage = 1
    updatePageDisplay()
    updateEmotes()
end

local function searchAnimations(searchTerm)
    if isLoading then
        getgenv().Notify({
            Title = '7yd7 | Animation',
            Content = '⚠️ Loading please wait...',
            Duration = 5
        })
        return
    end

    searchTerm = searchTerm:lower()

    if searchTerm == "" then
        filteredAnimations = originalAnimationsData
        animationCacheVersion = animationCacheVersion + 1
        if _G.originalAnimationFavoritesBackup then
            _G.originalAnimationFavoritesBackup = nil
        end
        _G.filteredFavoritesAnimationsForDisplay = nil
    else
        local isIdSearch = searchTerm:match("^%d+$")
        
        local newFilteredList = {}
        
        if isIdSearch then
            for _, animation in pairs(originalAnimationsData) do
                if tostring(animation.id) == searchTerm then
                    table.insert(newFilteredList, animation)
                end
            end
        else
            for _, animation in pairs(originalAnimationsData) do
                if animation.name:lower():find(searchTerm) then
                    table.insert(newFilteredList, animation)
                end
            end
        end
        
        filteredAnimations = newFilteredList
        animationCacheVersion = animationCacheVersion + 1

        if not isIdSearch then
            if not _G.originalAnimationFavoritesBackup then
                _G.originalAnimationFavoritesBackup = {}
                for i, favorite in pairs(favoriteAnimations) do
                    _G.originalAnimationFavoritesBackup[i] = {
                        id = favorite.id,
                        name = favorite.name,
                        bundledItems = favorite.bundledItems
                    }
                end
            end

            _G.filteredFavoritesAnimationsForDisplay = {}
            for _, favorite in pairs(favoriteAnimations) do
                if favorite.name:lower():find(searchTerm) then
                    table.insert(_G.filteredFavoritesAnimationsForDisplay, favorite)
                end
            end
        end
    end

    totalPages = calculateTotalPages()
    currentPage = 1
    updatePageDisplay()
    updateAnimations()
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

local function stopCurrentEmote()
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
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
        currentEmoteTrack = animTrack
        currentEmoteTrack.Priority = Enum.AnimationPriority.Action
        currentEmoteTrack.Looped = true
        task.wait(0.1)
        if speedEmoteEnabled or emotesWalkEnabled then
            currentEmoteTrack:Play()

            if speedEmoteEnabled then
                local speedValue = tonumber(SpeedBox.Text) or 1
                currentEmoteTrack:AdjustSpeed(speedValue)
            end
        end
    end
end

local function onCharacterAdded(character)
    currentCharacter = character
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

            if emotesWalkEnabled then
                if currentEmoteTrack then
                    local currentEmoteId = urlToId(currentEmoteTrack.Animation.AnimationId)
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

            if speedEmoteEnabled and not emotesWalkEnabled then
                if currentEmoteTrack then
                    local currentEmoteId = urlToId(currentEmoteTrack.Animation.AnimationId)
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
    emotesWalkEnabled = false
    speedEmoteEnabled = false
    favoriteEnabled = false
    currentEmoteTrack = nil

    stopEmotes()
        stopCurrentEmote()
    end)
end

local function toggleEmoteWalk()
    emotesWalkEnabled = not emotesWalkEnabled

    if emotesWalkEnabled then
        getgenv().Notify({
            Title = '7yd7 | Emote Freeze',
            Content = "🔒 Emote freeze ON",
            Duration = 5
        })

        EmoteWalkButton.Image = enabledButtonImage
        task.wait(0.1)
        stopCurrentEmote()
        if currentEmoteTrack and currentEmoteTrack.IsPlaying then
            currentEmoteTrack:AdjustSpeed(1)
        end
    else
        getgenv().Notify({
            Title = '7yd7 | Emote Freeze',
            Content = '🔓 Emote freeze OFF',
            Duration = 5
        })
        EmoteWalkButton.Image = defaultButtonImage
        task.wait(0.1)
        stopCurrentEmote()

        if currentEmoteTrack and currentEmoteTrack.IsPlaying and speedEmoteEnabled then
            local speedValue = tonumber(SpeedBox.Text) or 1
            currentEmoteTrack:AdjustSpeed(speedValue)
        elseif currentEmoteTrack and currentEmoteTrack.IsPlaying then
            currentEmoteTrack:AdjustSpeed(1)
        end
    end
end
print(Players.LocalPlayer.Name)
local function toggleSpeedEmote()
    speedEmoteEnabled = not speedEmoteEnabled

    SpeedBox.Visible = speedEmoteEnabled

    if speedEmoteEnabled then
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

    Config.EmoteSpeedEnabled = speedEmoteEnabled
    Config.EmoteSpeed = tonumber(SpeedBox.Text) or 1
    SaveConfig()
end

local function toggleFavoriteMode()
    favoriteEnabled = not favoriteEnabled

    if favoriteEnabled then
        ApplyFavoriteButtonVisual()
        getgenv().Notify({
            Title = '7yd7 | Favorite System',
            Content = "🔒 Favorite ON",
            Duration = 5
        })

        if currentMode == "emote" then
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
        
        if currentMode == "emote" then
            stopEmoteClickDetection()
        else
            updateAllFavoriteIcons()
        end
    end

    pcall(function()
        local frontFrame = CoreGui.RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
        frontFrame.Active = not favoriteEnabled
        for _, child in pairs(frontFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Active = not favoriteEnabled
            end
        end
    end)
end

local clickCooldown = {}
local CLICK_COOLDOWN_TIME = 0.1

local function safeButtonClick(buttonName, callback)
    local currentTime = tick()
    if not clickCooldown[buttonName] or (currentTime - clickCooldown[buttonName]) > CLICK_COOLDOWN_TIME then
        clickCooldown[buttonName] = currentTime
        callback()
    end
end

local function setupAnimationClickDetection()
    if isMonitoringClicks then
        return
    end
    
    if currentMode == "animation" then
        isMonitoringClicks = true
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

    if _1left then
        table.insert(guiConnections, _1left.MouseButton1Click:Connect(function()
            safeButtonClick("PrevPage", previousPage)
        end))
    end

    if _9right then
        table.insert(guiConnections, _9right.MouseButton1Click:Connect(function()
            safeButtonClick("NextPage", nextPage)
        end))
    end

      if _2Routenumber then
        table.insert(guiConnections, _2Routenumber.FocusLost:Connect(function(enterPressed)
            local pageNum = tonumber(_2Routenumber.Text)
            if pageNum then
                goToPage(pageNum)
            else
                _2Routenumber.Text = tostring(currentPage)
            end
        end))
    end

    if Search then
        table.insert(guiConnections, Search.Changed:Connect(function(property)
            if property == "Text" then
                if currentMode == "emote" then
                    emoteSearchTerm = Search.Text
                    searchEmotes(emoteSearchTerm)
                else
                    animationSearchTerm = Search.Text
                    searchAnimations(animationSearchTerm)
                end
            end
        end))
    end

    local SECTOR_COUNT = 8
    local SECTOR_ANGLE = 360 / SECTOR_COUNT

    table.insert(guiConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        if not (favoriteEnabled or currentMode == "animation") then return end

        local exists, emotesWheel = checkEmotesMenuExists()
        local isRecentlyVisible = (tick() - lastWheelVisibleTime < 0.15)
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

    if EmoteWalkButton then
        table.insert(guiConnections, EmoteWalkButton.MouseButton1Click:Connect(function()
            safeButtonClick("EmoteWalk", toggleEmoteWalk)
        end))
    end

    if Favorite then
        table.insert(guiConnections, Favorite.MouseButton1Click:Connect(function()
            safeButtonClick("Favorite", toggleFavoriteMode)
        end))
    end

    if SpeedEmote then
        table.insert(guiConnections, SpeedEmote.MouseButton1Click:Connect(function()
            safeButtonClick("SpeedEmote", toggleSpeedEmote)
        end))
    end

    if Reload then
    table.insert(guiConnections, Reload.MouseButton1Click:Connect(function()
        safeButtonClick("AutoReload", toggleAutoReload)
    end))
end

if Changepage then
    table.insert(guiConnections, Changepage.MouseButton1Click:Connect(function()
        safeButtonClick("ChangePage", function()
        stopEmoteClickDetection()
        
        if currentMode == "emote" then
            currentMode = "animation"
            
            spawn(function()
                fetchAllAnimations()
                Search.Text = animationSearchTerm
                currentPage = Config.AnimationPage or 1
                totalPages = calculateTotalPages()
                updatePageDisplay()
                updateEmotes()
                isMonitoringClicks = true
                task.spawn(monitorAnimations)
            end)
            
            getgenv().Notify({
                Title = '7yd7 | Animation',
                Content = '📄 Changed to Emote > Animation Mode',
                Duration = 3
            })

        else
            currentMode = "emote"
            Search.Text = emoteSearchTerm
            currentPage = Config.EmotePage or 1
            totalPages = calculateTotalPages()
            updatePageDisplay() 
            updateEmotes()
            
            if favoriteEnabled then
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

    if SpeedBox then
        table.insert(guiConnections, SpeedBox.FocusLost:Connect(function()
            Config.EmoteSpeed = tonumber(SpeedBox.Text) or 1
            SaveConfig()
        end))
    end
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

player.CharacterAdded:Connect(function(character)
    onCharacterAdded(character)
    task.wait(0.3) 
    spawn(function()
        while not checkEmotesMenuExists() do
            task.wait(0.1) 
        end
        task.wait(0.3) 
        stopEmotes()
        if createGUIElements() then
            if #emotesData > 0 then
                updatePageDisplay()
                updateEmotes()
                loadSpeedEmoteConfig()
            end
        end
    end)
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    emotesWalkEnabled = false
    speedEmoteEnabled = false
    favoriteEnabled = false
    currentEmoteTrack = nil
    stopEmotes()
end)


local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not isGUICreated then
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
    if humanoid and currentEmoteTrack and currentEmoteTrack.IsPlaying then
        if humanoid.MoveDirection.Magnitude > 0 then
            if speedEmoteEnabled and not emotesWalkEnabled then
                currentEmoteTrack:Stop()
                currentEmoteTrack = nil
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
    loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/OpenEmote.lua"))()
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
