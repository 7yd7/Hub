local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local _7yd7Settings = Instance.new("Folder")
_7yd7Settings.Name = "7yd7-Settings"
_7yd7Settings.Parent = game.CoreGui:FindFirstChild("RobloxGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

local SettingsUI = Instance.new("ScreenGui")
SettingsUI.Name = "SettingsUI"
SettingsUI.ResetOnSpawn = false
SettingsUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SettingsUI.DisplayOrder = 100
SettingsUI.Parent = _7yd7Settings

local UIScale = Instance.new("UIScale")
UIScale.Parent = SettingsUI

local function UpdateUIScale()
    local ViewportSize = workspace.CurrentCamera.ViewportSize
    local Scale = math.min(ViewportSize.X / 1000, ViewportSize.Y / 800)
    UIScale.Scale = math.clamp(Scale, 0.6, 1.1)
end

UpdateUIScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateUIScale)

local Theme = {
    Background = Color3.fromRGB(28, 30, 32),
    Header = Color3.fromRGB(35, 38, 41),
    Section = Color3.fromRGB(35, 38, 41),
    Accent = Color3.fromRGB(0, 255, 150),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 140),
    Error = Color3.fromRGB(220, 60, 60),
    CornerRadius = UDim.new(0, 10),
    FontBold = Enum.Font.GothamBold,
    FontRegular = Enum.Font.Gotham
}

local ThemedObjects = {}
local function UpdateTheme(newTheme)
    for k, v in pairs(newTheme) do
        Theme[k] = v
    end
    for _, item in pairs(ThemedObjects) do
        pcall(function()
            item.obj[item.prop] = Theme[item.key]
        end)
    end
end

local function RegisterThemed(obj, prop, key)
    table.insert(ThemedObjects, {obj = obj, prop = prop, key = key})
    if Theme[key] then
        pcall(function() obj[prop] = Theme[key] end)
    end
end

local ConfigPath = "7yd7/Themes.json"
local function SaveThemes(themes)
    if not isfolder("7yd7") then makefolder("7yd7") end
    writefile(ConfigPath, HttpService:JSONEncode(themes))
end

local function LoadThemes()
    if isfile(ConfigPath) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigPath)) end)
        if success and type(decoded) == "table" then
            return decoded
        end
    end
    return {
        Default = {
            Background = {28, 30, 32},
            Accent = {0, 255, 150},
            Header = {35, 38, 41},
            Section = {35, 38, 41},
            Text = {255, 255, 255},
            TextDim = {140, 140, 140}
        }
    }
end

local function ColorToTable(c) return {math.round(c.R*255), math.round(c.G*255), math.round(c.B*255)} end
local function TableToColor(t) return Color3.fromRGB(t[1], t[2], t[3]) end

local Lib = {}

function Lib:Tween(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
end

function Lib:Create(className, properties, children)
    local obj = Instance.new(className)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local MainFrame = Lib:Create("Frame", {
    Name = "MainFrame",
    Parent = SettingsUI,
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -160, 0.5, -210),
    Size = UDim2.new(0, 320, 0, 420)
}, {
    Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius})
})
RegisterThemed(MainFrame, "BackgroundColor3", "Background")

local Dragging, DragInput, DragStart, StartPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and Dragging then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

local Header = Lib:Create("Frame", {
    Name = "Header",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 50)
})

local NavContainer = Lib:Create("Frame", {
    Name = "NavContainer",
    Parent = Header,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.05, 0, 0.2, 0),
    Size = UDim2.new(0.9, 0, 0, 30)
}, {
    Lib:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
})

local CloseBtn = Lib:Create("TextButton", {
    Name = "Close",
    Parent = Header,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -35, 0, 10),
    Size = UDim2.new(0, 25, 0, 25),
    Font = Theme.FontBold,
    Text = "x",
    TextColor3 = Theme.Text,
    TextScaled = true
}, {
    Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)})
})
CloseBtn.MouseButton1Click:Connect(function() SettingsUI.Enabled = false end)

local TabContainers = {}
local ActiveTab = nil

local Components = {}

function Components:AddItem(parent, title, description)
    local hasDesc = description and description ~= ""
    local ItemContainer = Lib:Create("Frame", {
        Name = title,
        Parent = parent,
        BackgroundColor3 = Theme.Section,
        Size = UDim2.new(0.95, 0, 0, hasDesc and 60 or 45)
    }, {
        Lib:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Lib:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, hasDesc and 12 or 0),
            Size = UDim2.new(0.6, 0, hasDesc and 0 or 1, hasDesc and 18 or 0),
            Font = Theme.FontBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })
    
    if hasDesc then
        Lib:Create("TextLabel", {
            Name = "Desc",
            Parent = ItemContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 32),
            Size = UDim2.new(0.6, 0, 0, 15),
            Font = Theme.FontRegular,
            Text = description,
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    return ItemContainer
end

function Components:AddToggle(container, title, description, default, callback)
    local item = self:AddItem(container, title, description)
    local state = default or false
    
    local ToggleBg = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = state and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(55, 58, 62),
        Position = UDim2.new(1, -55, 0.5, -10),
        Size = UDim2.new(0, 42, 0, 20),
        Text = ""
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
    
    local Knob = Lib:Create("Frame", {
        Parent = ToggleBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(state and 1 or 0, state and -19 or 3, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16)
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
    
    ToggleBg.MouseButton1Click:Connect(function()
        state = not state
        Lib:Tween(ToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0, 220, 130) or Color3.fromRGB(55, 58, 62)})
        Lib:Tween(Knob, TweenInfo.new(0.15), {Position = UDim2.new(state and 1 or 0, state and -19 or 3, 0.5, -8)})
        callback(state)
    end)
end

function Components:AddDropdown(container, title, options, default, callback)
    local item = self:AddItem(container, title, nil)
    local selected = default or options[1]
    
    local DropBtn = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = Color3.fromRGB(25, 27, 30),
        Position = UDim2.new(1, -110, 0.5, -14),
        Size = UDim2.new(0, 100, 0, 28),
        Font = Theme.FontRegular,
        Text = selected .. "  ▼",
        TextColor3 = Theme.Text,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    
    local IsOpen = false
    local DropList = Lib:Create("Frame", {
        Parent = SettingsUI,
        BackgroundColor3 = Color3.fromRGB(25, 27, 30),
        Size = UDim2.fromOffset(100, 0),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 200
    }, {
        Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        Lib:Create("UIStroke", {Color = Theme.Accent, Thickness = 1})
    })
    
    local ListScroll = Lib:Create("ScrollingFrame", {
        Parent = DropList,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.new(1, 0, 1, -28),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, { Lib:Create("UIListLayout", {Padding = UDim.new(0, 1)}) })

    local SearchBox = Lib:Create("TextBox", {
        Parent = DropList,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -8, 0, 22),
        Font = Theme.FontRegular,
        PlaceholderText = "Search...",
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 11
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
    
    local function RefreshOptions(filter)
        for _, v in pairs(ListScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, opt in pairs(options) do
            if not filter or string.find(string.lower(opt), string.lower(filter)) then
                local b = Lib:Create("TextButton", {
                    Parent = ListScroll,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Theme.FontRegular,
                    Text = opt,
                    TextColor3 = Theme.Text,
                    TextSize = 11
                })
                b.MouseButton1Click:Connect(function()
                    selected = opt
                    DropBtn.Text = opt .. "  ▼"
                    IsOpen = false
                    DropList.Visible = false
                    callback(opt)
                end)
            end
        end
    end
    
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function() RefreshOptions(SearchBox.Text) end)
    
    local Dropdown = {
        Button = DropBtn,
        Refresh = RefreshOptions
    }
    
    RefreshOptions()
    
    DropBtn.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        if IsOpen then
            local scale = UIScale.Scale
            DropList.Position = UDim2.fromOffset(DropBtn.AbsolutePosition.X / scale, (DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 2) / scale)
            DropList.Visible = true
            RefreshOptions(SearchBox.Text)
            DropList.Size = UDim2.fromOffset(100, math.min(#options * 24 + 28, 140))
        else
            DropList.Visible = false
        end
    end)
    
    return Dropdown
end

function Components:AddSection(container, title)
    local lbl = Lib:Create("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.95, 0, 0, 25),
        Font = Theme.FontBold,
        Text = " — " .. title:upper() .. " — ",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    RegisterThemed(lbl, "TextColor3", "Accent")
    return lbl
end

function Components:AddButton(container, title, callback)
    local item = self:AddItem(container, title, nil)
    local Btn = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(1, -75, 0.5, -12),
        Size = UDim2.new(0, 65, 0, 24),
        Font = Theme.FontBold,
        Text = "Click",
        TextColor3 = Theme.Background,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    
    RegisterThemed(Btn, "BackgroundColor3", "Accent")
    RegisterThemed(Btn, "TextColor3", "Background")
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

function Components:AddInput(container, title, placeholder, default, callback)
    local item = self:AddItem(container, title, nil)
    local Input = Lib:Create("TextBox", {
        Parent = item,
        BackgroundColor3 = Color3.fromRGB(25, 27, 30),
        Position = UDim2.new(1, -110, 0.5, -12),
        Size = UDim2.new(0, 100, 0, 24),
        Font = Theme.FontRegular,
        PlaceholderText = placeholder or "...",
        Text = default or "",
        TextColor3 = Theme.Text,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    
    Input.FocusLost:Connect(function()
        callback(Input.Text)
    end)
    return Input
end

function Components:AddTextArea(container, title, placeholder, default, callback)
    local item = self:AddItem(container, title, nil)
    item.Size = UDim2.new(0.95, 0, 0, 120)
    
    local TextArea = Lib:Create("TextBox", {
        Parent = item,
        BackgroundColor3 = Color3.fromRGB(25, 27, 30),
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 0, 80),
        Font = Theme.FontRegular,
        PlaceholderText = placeholder or "...",
        Text = default or "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    
    TextArea.FocusLost:Connect(function()
        callback(TextArea.Text)
    end)
    return TextArea
end

function Components:AddIconButton(container, imageId, callback)
    local Btn = Lib:Create("ImageButton", {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Image = "rbxassetid://" .. tostring(imageId):gsub("rbxassetid://", ""),
        ScaleType = Enum.ScaleType.Fit
    })
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

function Components:AddFolder(container, title)
    local IsOpen = false
    local FolderBtn = Lib:Create("TextButton", {
        Parent = container,
        BackgroundColor3 = Theme.Section,
        Size = UDim2.new(0.95, 0, 0, 35),
        Font = Theme.FontBold,
        Text = "  ▶  " .. title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}) })
    
    local Content = Lib:Create("Frame", {
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true
    }, {
        Lib:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    })
    
    FolderBtn.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        FolderBtn.Text = (IsOpen and "  ▼  " or "  ▶  ") .. title
        Content.Visible = IsOpen
        Content.Size = IsOpen and UDim2.new(1, 0, 0, Content.UIListLayout.AbsoluteContentSize.Y + 5) or UDim2.new(1, 0, 0, 0)
    end)
    
    Content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if IsOpen then
            Content.Size = UDim2.new(1, 0, 0, Content.UIListLayout.AbsoluteContentSize.Y + 5)
        end
    end)
    
    return Content
end

function Components:AddColorPicker(container, title, default, callback)
    local item = self:AddItem(container, title, nil)
    local color = default or Theme.Accent
    local h, s, v = color:ToHSV()
    
    local ColorBtn = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = color,
        Position = UDim2.new(1, -42, 0.5, -10),
        Size = UDim2.new(0, 22, 0, 22),
        Text = ""
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 5)}) })
    
    local PickerFrame = Lib:Create("Frame", {
        Parent = SettingsUI,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(260, 200),
        Visible = false,
        ZIndex = 500
    }, {
        Lib:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Lib:Create("UIStroke", {Color = Theme.Section, Thickness = 2}),
        Lib:Create("TextLabel", {
            Position = UDim2.fromOffset(12, 8),
            Size = UDim2.new(1, -30, 0, 18),
            BackgroundTransparency = 1,
            Font = Theme.FontBold,
            Text = "COLOR SELECTOR",
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local closePicker = Lib:Create("TextButton", {
        Parent = PickerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.fromOffset(25, 25),
        Font = Theme.FontBold,
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 22
    })
    closePicker.MouseButton1Click:Connect(function() PickerFrame.Visible = false end)

    local SatValArea = Lib:Create("ImageButton", {
        Parent = PickerFrame,
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Position = UDim2.fromOffset(12, 35),
        Size = UDim2.fromOffset(140, 140),
        Image = "rbxassetid://4155801252",
        BorderSizePixel = 0
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    local SatValCursor = Lib:Create("Frame", {
        Parent = SatValArea,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(4, 4),
        Position = UDim2.fromScale(s, 1-v)
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Lib:Create("UIStroke", {Thickness = 1}) })

    local HueSlider = Lib:Create("ImageButton", {
        Parent = PickerFrame,
        Position = UDim2.fromOffset(162, 35),
        Size = UDim2.fromOffset(18, 140),
        Image = "rbxassetid://4155806652",
        BorderSizePixel = 0
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    local HueCursor = Lib:Create("Frame", {
        Parent = HueSlider,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.fromScale(0, 1-h)
    }, { Lib:Create("UIStroke", {Thickness = 1}) })

    local function CreateIn(name, x, y, parent)
        Lib:Create("TextLabel", { Parent = parent, Position = UDim2.fromOffset(x, y-15), Size = UDim2.fromOffset(65, 12), BackgroundTransparency = 1, Font = Theme.FontBold, Text = name, TextColor3 = Theme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left })
        return Lib:Create("TextBox", {
            Parent = parent,
            BackgroundColor3 = Color3.fromRGB(0, 220, 130),
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(65, 30),
            Font = Theme.FontRegular,
            Text = "255",
            TextColor3 = Theme.Text,
            TextSize = 14
        }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    end

    local rI = CreateIn("Red:", 192, 45, PickerFrame)
    local gI = CreateIn("Green:", 192, 95, PickerFrame)
    local bI = CreateIn("Blue:", 192, 145, PickerFrame)

    local function UpdateAll()
        color = Color3.fromHSV(h, s, v)
        SatValArea.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        SatValCursor.Position = UDim2.fromScale(s, 1-v)
        HueCursor.Position = UDim2.fromScale(0, 1-h)
        ColorBtn.BackgroundColor3 = color
        rI.Text = math.round(color.R * 255)
        gI.Text = math.round(color.G * 255)
        bI.Text = math.round(color.B * 255)
        callback(color)
    end

    local mDown = false
    local hDown = false

    SatValArea.MouseButton1Down:Connect(function() mDown = true end)
    HueSlider.MouseButton1Down:Connect(function() hDown = true end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            mDown = false
            hDown = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not PickerFrame.Visible then return end
        
        if mDown then
            local pos = UserInputService:GetMouseLocation()
            local relX = (pos.X - SatValArea.AbsolutePosition.X) / SatValArea.AbsoluteSize.X
            local relY = (pos.Y - SatValArea.AbsolutePosition.Y - 36) / SatValArea.AbsoluteSize.Y
            s = math.clamp(relX, 0, 1)
            v = 1 - math.clamp(relY, 0, 1)
            UpdateAll()
        end

        if hDown then
            local pos = UserInputService:GetMouseLocation()
            local relY = (pos.Y - HueSlider.AbsolutePosition.Y - 36) / HueSlider.AbsoluteSize.Y
            h = 1 - math.clamp(relY, 0, 1)
            UpdateAll()
        end
    end)

    ColorBtn.MouseButton1Click:Connect(function() PickerFrame.Visible = true end)
    UpdateAll()
end

local function CreateTab(name, order)
    local TabContainer = Lib:Create("ScrollingFrame", {
        Name = name .. "Page",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(1, -20, 1, -70),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        Visible = order == 1,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, { Lib:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center}) })
    
    local TabBtn = Lib:Create("TextButton", {
        Name = name,
        Parent = NavContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        Font = Theme.FontBold,
        Text = name:gsub("%d", ""),
        TextColor3 = order == 1 and Theme.Text or Color3.fromRGB(120, 120, 120),
        TextSize = 14,
        LayoutOrder = order
    })
    
    local Underline = Lib:Create("Frame", {
        Parent = TabBtn,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(-0.05, 0, 1, 3),
        Size = UDim2.new(1.1, 0, 0, 2),
        Visible = order == 1
    })

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab == name then return end
        for tName, container in pairs(TabContainers) do container.Visible = (tName == name) end
        for _, btn in pairs(NavContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(120, 120, 120)
                if btn:FindFirstChild("Frame") then btn.Frame.Visible = false end
            end
        end
        TabBtn.TextColor3 = Theme.Text
        Underline.Visible = true
        ActiveTab = name
    end)
    
    TabContainers[name] = TabContainer
    return TabContainer
end

--[[
local GeneralTab = CreateTab("1General", 1)
local ButtonsTab = CreateTab("2Buttons", 2)
local ThemeTab = CreateTab("3Theme", 3)

Components:AddToggle(GeneralTab, "Background Music", "Adjust the volume of the music", true, function(v) print("Music:", v) end)
Components:AddToggle(GeneralTab, "Particle Effects", "Toggle visual particle quality", false, function(v) print("Particles:", v) end)

Components:AddDropdown(ButtonsTab, "Graphics Quality", {"Low", "Medium", "High", "Ultra"}, "Ultra", function(v) print("Quality:", v) end)

Components:AddColorPicker(ThemeTab, "Accent Color", Theme.Accent, function(c) 
    Theme.Accent = c
end)
]]

local Library = {
    UI = SettingsUI,
    CreateTab = CreateTab,
    AddToggle = function(...) return Components:AddToggle(...) end,
    AddDropdown = function(...) return Components:AddDropdown(...) end,
    AddColorPicker = function(...) return Components:AddColorPicker(...) end,
    AddButton = function(...) return Components:AddButton(...) end,
    AddInput = function(...) return Components:AddInput(...) end,
    AddSection = function(...) return Components:AddSection(...) end,
    AddTextArea = function(...) return Components:AddTextArea(...) end,
    AddIconButton = function(...) return Components:AddIconButton(...) end,
    AddFolder = function(...) return Components:AddFolder(...) end,
    CreateThemeTab = function(self)
        local ThemeTab = self.CreateTab("Theme", 4)
        local MgmtSection = Components:AddSection(ThemeTab, "Management")
        
        local BtnRow = Lib:Create("Frame", {
            Parent = ThemeTab,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.95, 0, 0, 40)
        }, {
            Lib:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 15),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            })
        })
        
        local themes = LoadThemes()
        local function GetNames()
            local n = {}
            for name, _ in pairs(themes) do table.insert(n, name) end
            table.sort(n)
            return n
        end
        
        local currentThemeName = "Default"
        local Dropdown
        
        local function RefreshDrop()
            if Dropdown then
                Dropdown.Refresh(GetNames())
            end
        end

        -- Add Button
        Components:AddIconButton(BtnRow, "132703748384380", function()
            local InputPanel = Lib:Create("Frame", {
                Parent = SettingsUI,
                BackgroundColor3 = Theme.Background,
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromOffset(200, 100),
                ZIndex = 1000
            }, {
                Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Lib:Create("UIStroke", {Color = Theme.Accent, Thickness = 1})
            })
            
            local In = Lib:Create("TextBox", {
                Parent = InputPanel,
                Size = UDim2.new(0.8, 0, 0, 30),
                Position = UDim2.new(0.1, 0, 0.2, 0),
                BackgroundColor3 = Theme.Section,
                TextColor3 = Theme.Text,
                PlaceholderText = "Theme Name...",
                Text = ""
            }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            
            local Save = Lib:Create("TextButton", {
                Parent = InputPanel,
                Size = UDim2.new(0.4, 0, 0, 25),
                Position = UDim2.new(0.1, 0, 0.65, 0),
                BackgroundColor3 = Theme.Accent,
                TextColor3 = Theme.Background,
                Text = "Save"
            }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            
            local Cancel = Lib:Create("TextButton", {
                Parent = InputPanel,
                Size = UDim2.new(0.4, 0, 0, 25),
                Position = UDim2.new(0.5, 0, 0.65, 0),
                BackgroundColor3 = Theme.Header,
                TextColor3 = Theme.Text,
                Text = "Cancel"
            }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            
            Save.MouseButton1Click:Connect(function()
                if In.Text ~= "" and not themes[In.Text] then
                    local newThemeData = {}
                    for k, v in pairs(Theme) do
                        if typeof(v) == "Color3" then
                            newThemeData[k] = ColorToTable(v)
                        end
                    end
                    themes[In.Text] = newThemeData
                    SaveThemes(themes)
                    RefreshDrop()
                    InputPanel:Destroy()
                end
            end)
            Cancel.MouseButton1Click:Connect(function() InputPanel:Destroy() end)
        end)
        
        -- Delete Button
        Components:AddIconButton(BtnRow, "75735986214273", function()
            if currentThemeName ~= "Default" then
                themes[currentThemeName] = nil
                SaveThemes(themes)
                currentThemeName = "Default"
                RefreshDrop()
                Dropdown.Button.Text = "Default  ▼"
            end
        end)
        
        -- Rename Button
        Components:AddIconButton(BtnRow, "71590943900322", function()
            if currentThemeName == "Default" then return end
            -- Similar InputPanel logic for rename
            local InputPanel = Lib:Create("Frame", {
                Parent = SettingsUI, BackgroundColor3 = Theme.Background, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(200, 100), ZIndex = 1000
            }, { Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}), Lib:Create("UIStroke", {Color = Theme.Accent, Thickness = 1}) })
            local In = Lib:Create("TextBox", { Parent = InputPanel, Size = UDim2.new(0.8, 0, 0, 30), Position = UDim2.new(0.1, 0, 0.2, 0), BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text, Text = currentThemeName })
            local Save = Lib:Create("TextButton", { Parent = InputPanel, Size = UDim2.new(0.4, 0, 0, 25), Position = UDim2.new(0.1, 0, 0.65, 0), BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background, Text = "Rename" })
            Save.MouseButton1Click:Connect(function()
                if In.Text ~= "" and not themes[In.Text] then
                    themes[In.Text] = themes[currentThemeName]
                    themes[currentThemeName] = nil
                    currentThemeName = In.Text
                    SaveThemes(themes)
                    RefreshDrop()
                    Dropdown.Button.Text = In.Text .. "  ▼"
                    InputPanel:Destroy()
                end
            end)
            local Cancel = Lib:Create("TextButton", { Parent = InputPanel, Size = UDim2.new(0.4, 0, 0, 25), Position = UDim2.new(0.5, 0, 0.65, 0), BackgroundColor3 = Theme.Header, TextColor3 = Theme.Text, Text = "Cancel" })
            Cancel.MouseButton1Click:Connect(function() InputPanel:Destroy() end)
        end)
        
        -- Import Button
        Components:AddIconButton(BtnRow, "125970262144752", function()
            local panel = Lib:Create("Frame", { Parent = SettingsUI, BackgroundColor3 = Theme.Background, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(250, 150), ZIndex = 1000 })
            local box = Lib:Create("TextBox", { Parent = panel, Size = UDim2.new(0.9, 0, 0.6, 0), Position = UDim2.fromOffset(12, 12), MultiLine = true, TextWrapped = true, BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text, Text = "", PlaceholderText = "Paste JSON here..." })
            local importBtn = Lib:Create("TextButton", { Parent = panel, Size = UDim2.new(0.9, 0, 0, 25), Position = UDim2.new(0.05, 0, 0.75, 0), BackgroundColor3 = Theme.Accent, Text = "Import" })
            importBtn.MouseButton1Click:Connect(function()
                local s, d = pcall(function() return HttpService:JSONDecode(box.Text) end)
                if s and type(d) == "table" and d.name then
                    themes[d.name] = d.data
                    SaveThemes(themes)
                    RefreshDrop()
                    panel:Destroy()
                end
            end)
        end)
        
        -- Export Button
        Components:AddIconButton(BtnRow, "75021596852918", function()
            local exportData = { name = currentThemeName, data = themes[currentThemeName] }
            local json = HttpService:JSONEncode(exportData)
            local panel = Lib:Create("Frame", { Parent = SettingsUI, BackgroundColor3 = Theme.Background, Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(250, 150), ZIndex = 1000 })
            local box = Lib:Create("TextBox", { Parent = panel, Size = UDim2.new(0.9, 0, 0.6, 0), Position = UDim2.fromOffset(12, 12), MultiLine = true, TextWrapped = true, BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text, Text = json })
            local copyBtn = Lib:Create("TextButton", { Parent = panel, Size = UDim2.new(0.9, 0, 0, 25), Position = UDim2.new(0.05, 0, 0.75, 0), BackgroundColor3 = Theme.Accent, Text = "Copy to Clipboard" })
            copyBtn.MouseButton1Click:Connect(function()
                setclipboard(json)
                copyBtn.Text = "Copied!"
                task.delay(1, function() copyBtn.Text = "Copy to Clipboard" end)
            end)
        end)
        
        Dropdown = Components:AddDropdown(ThemeTab, "Select Theme", GetNames(), "Default", function(v)
            currentThemeName = v
            local selected = themes[v]
            if selected then
                local converted = {}
                for k, col in pairs(selected) do
                    if type(col) == "table" then
                        converted[k] = TableToColor(col)
                    end
                end
                UpdateTheme(converted)
            end
        end)
        
        local bgFolder = Components:AddFolder(ThemeTab, "Colors & Background")
        Components:AddColorPicker(bgFolder, "Background", Theme.Background, function(c) 
            UpdateTheme({Background = c}) 
            if themes[currentThemeName] then themes[currentThemeName].Background = ColorToTable(c); SaveThemes(themes) end
        end)
        Components:AddColorPicker(bgFolder, "Accent", Theme.Accent, function(c) 
            UpdateTheme({Accent = c}) 
            if themes[currentThemeName] then themes[currentThemeName].Accent = ColorToTable(c); SaveThemes(themes) end
        end)
        
        local imageFolder = Components:AddFolder(ThemeTab, "Images & Emotes")
        Components:AddColorPicker(imageFolder, "Image Color", Color3.new(1,1,1), function(c)
            -- This will be used in Emotes.lua to color images
            _G.ImageColor = c
        end)
    end
}

return Library
