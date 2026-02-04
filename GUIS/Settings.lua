local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local function ColorToHex(c)
    return string.format("#%02x%02x%02x", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
end

local function HexToColor(hex)
    local success, result = pcall(function()
        hex = hex:gsub("#", "")
        return Color3.fromRGB(tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16))
    end)
    return success and result or nil
end

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

local PickerFrame = nil
local currentPickerCallback = nil
local pickerColor = Color3.new(1, 1, 1)

function Lib:OpenPicker(default, callback)
    if PickerFrame then PickerFrame:Destroy() end
    currentPickerCallback = callback
    pickerColor = default or Theme.Accent
    local h, s, v = pickerColor:ToHSV()

    PickerFrame = Lib:Create("Frame", {
        Name = "ColorPicker",
        Parent = SettingsUI,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(300, 380), -- Slightly wider for better breathing room
        ZIndex = 2000
    }, {
        Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
        Lib:Create("UIStroke", {Color = Theme.Section, Thickness = 2}),
        Lib:Create("TextLabel", {
            Position = UDim2.fromOffset(15, 12),
            Size = UDim2.new(1, -30, 0, 25),
            BackgroundTransparency = 1,
            Font = Theme.FontBold,
            Text = "COLOR SELECTOR",
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local closeBtn = Lib:Create("TextButton", {
        Parent = PickerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 10),
        Size = UDim2.fromOffset(25, 25),
        Font = Theme.FontBold,
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 24
    })
    closeBtn.MouseButton1Click:Connect(function() PickerFrame:Destroy(); PickerFrame = nil end)

    -- Main Area (Wheel + Slider)
    local MainArea = Lib:Create("Frame", {
        Parent = PickerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 50),
        Size = UDim2.new(1, -30, 0, 160)
    })

    local Wheel = Lib:Create("ImageButton", {
        Parent = MainArea,
        Size = UDim2.fromOffset(160, 160),
        Position = UDim2.fromOffset(10, 0),
        Image = "rbxassetid://6039290073",
        BackgroundTransparency = 1
    })

    local WheelCursor = Lib:Create("Frame", {
        Parent = Wheel,
        Size = UDim2.fromOffset(12, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 5
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Lib:Create("UIStroke", {Thickness = 2, Color = Color3.new(0,0,0)}) })

    local Slider = Lib:Create("ImageButton", {
        Parent = MainArea,
        Position = UDim2.fromOffset(210, 5),
        Size = UDim2.fromOffset(25, 150),
        BackgroundColor3 = Color3.new(1,1,1)
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 12)}) })

    local SliderGradient = Lib:Create("UIGradient", {
        Parent = Slider,
        Rotation = 90,
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0))
    })

    local SliderCursor = Lib:Create("Frame", {
        Parent = Slider,
        Size = UDim2.new(1.2, 0, 0, 6),
        AnchorPoint = Vector2.new(0.1, 0.5),
        Position = UDim2.fromScale(0, 1-v),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 5
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Lib:Create("UIStroke", {Thickness = 1}) })

    -- Hex and Actions row
    local ActionsRow = Lib:Create("Frame", {
        Parent = PickerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 220),
        Size = UDim2.new(1, -40, 0, 35)
    })

    local ColorPreview = Lib:Create("Frame", {
        Parent = ActionsRow,
        Size = UDim2.fromOffset(45, 30),
        BackgroundColor3 = pickerColor
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 8)}), Lib:Create("UIStroke", {Thickness = 1, Color = Theme.Section}) })

    local HexBox = Lib:Create("TextBox", {
        Parent = ActionsRow,
        Position = UDim2.fromOffset(55, 0),
        Size = UDim2.fromOffset(90, 30),
        BackgroundColor3 = Theme.Section,
        Font = Theme.FontRegular,
        Text = ColorToHex(pickerColor),
        TextColor3 = Theme.Text,
        TextSize = 13
    }, { Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}) })

    local function CreateActionBtn(img, x, parent, color)
        local btn = Lib:Create("ImageButton", {
            Parent = parent,
            Position = UDim2.fromOffset(x, 0),
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = Theme.Section,
            Image = img,
            ImageColor3 = color or Theme.Text,
            PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)
        }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 8)}) })
        return btn
    end

    local ApplyBtn = CreateActionBtn("rbxassetid://11419713314", 190, ActionsRow, Theme.Accent)
    local CancelBtn = CreateActionBtn("rbxassetid://11419719547", 230, ActionsRow, Theme.Error)

    -- Numeric Inputs Grid
    local Grid = Lib:Create("Frame", {
        Parent = PickerFrame,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 265),
        Size = UDim2.new(1, -40, 0, 95)
    })

    local function CreateInput(label, x, y, parent, default)
        local container = Lib:Create("Frame", {
            Parent = parent,
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(80, 40),
            BackgroundColor3 = Theme.Section
        }, {
            Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
            Lib:Create("TextLabel", {
                Position = UDim2.new(0, 8, 0, -14),
                Size = UDim2.fromOffset(20, 15),
                BackgroundTransparency = 1,
                Font = Theme.FontBold,
                Text = label,
                TextColor3 = Theme.TextDim,
                TextSize = 10
            })
        })
        local box = Lib:Create("TextBox", {
            Parent = container,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Font = Theme.FontRegular,
            Text = tostring(default),
            TextColor3 = Theme.Text,
            TextSize = 13,
            ClearTextOnFocus = false
        })
        return box
    end

    local rI = CreateInput("R", 0, 5, Grid, math.round(pickerColor.R*255))
    local gI = CreateInput("G", 90, 5, Grid, math.round(pickerColor.G*255))
    local bI = CreateInput("B", 180, 5, Grid, math.round(pickerColor.B*255))
    
    local hI = CreateInput("H", 0, 50, Grid, math.round(h*360))
    local sI = CreateInput("S", 90, 50, Grid, string.format("%.2f", s))
    local vI = CreateInput( "V", 180, 50, Grid, string.format("%.2f", v))

    local function SyncAll(source)
        pickerColor = Color3.fromHSV(h, s, v)
        ColorPreview.BackgroundColor3 = pickerColor
        SliderGradient.Color = ColorSequence.new(Color3.fromHSV(h, s, 1), Color3.new(0, 0, 0))
        
        if source ~= "Wheel" then
            local angle = math.rad(h * 360)
            local dist = s * 80
            WheelCursor.Position = UDim2.fromOffset(80 + math.cos(angle) * dist, 80 + math.sin(angle) * dist)
        end
        if source ~= "Slider" then
            SliderCursor.Position = UDim2.fromScale(-0.2, 1-v)
        end
        if source ~= "Hex" then HexBox.Text = ColorToHex(pickerColor) end
        
        if source ~= "RGB" then
            rI.Text = math.round(pickerColor.R * 255)
            gI.Text = math.round(pickerColor.G * 255)
            bI.Text = math.round(pickerColor.B * 255)
        end
        if source ~= "HSV" then
            hI.Text = math.round(h * 360)
            sI.Text = string.format("%.2f", s)
            vI.Text = string.format("%.2f", v)
        end
    end

    -- Interaction Logic
    local wheelDown, sliderDown = false, false
    Wheel.MouseButton1Down:Connect(function() wheelDown = true end)
    Slider.MouseButton1Down:Connect(function() sliderDown = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then wheelDown, sliderDown = false, false end end)

    RunService.RenderStepped:Connect(function()
        if not PickerFrame or not PickerFrame.Visible then return end
        if wheelDown then
            local mouse = UserInputService:GetMouseLocation()
            local rel = Vector2.new(mouse.X - Wheel.AbsolutePosition.X, mouse.Y - Wheel.AbsolutePosition.Y - 36)
            local center = Vector2.new(80, 80)
            local diff = rel - center
            local angle = math.atan2(diff.Y, diff.X)
            local dist = math.min(diff.Magnitude, 80)
            
            h = (math.deg(angle) % 360) / 360
            s = dist / 80
            WheelCursor.Position = UDim2.fromOffset(center.X + math.cos(angle) * dist, center.Y + math.sin(angle) * dist)
            SyncAll("Wheel")
        end
        if sliderDown then
            local mouse = UserInputService:GetMouseLocation()
            local relY = math.clamp((mouse.Y - Slider.AbsolutePosition.Y - 36) / Slider.AbsoluteSize.Y, 0, 1)
            v = 1 - relY
            SyncAll("Slider")
        end
    end)

    HexBox.FocusLost:Connect(function()
        local c = HexToColor(HexBox.Text)
        if c then h, s, v = c:ToHSV(); SyncAll("Hex") else HexBox.Text = ColorToHex(pickerColor) end
    end)

    local function HandleRGB()
        local r, g, b = tonumber(rI.Text) or 0, tonumber(gI.Text) or 0, tonumber(bI.Text) or 0
        local c = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
        h, s, v = c:ToHSV(); SyncAll("RGB")
    end
    rI.FocusLost:Connect(HandleRGB); gI.FocusLost:Connect(HandleRGB); bI.FocusLost:Connect(HandleRGB)

    local function HandleHSV()
        local nh, ns, nv = tonumber(hI.Text) or 0, tonumber(sI.Text) or 0, tonumber(vI.Text) or 0
        h, s, v = (nh%360)/360, math.clamp(ns,0,1), math.clamp(nv,0,1)
        SyncAll("HSV")
    end
    hI.FocusLost:Connect(HandleHSV); sI.FocusLost:Connect(HandleHSV); vI.FocusLost:Connect(HandleHSV)

    ApplyBtn.MouseButton1Click:Connect(function() PickerFrame:Destroy(); PickerFrame = nil; callback(pickerColor) end)
    CancelBtn.MouseButton1Click:Connect(function() PickerFrame:Destroy(); PickerFrame = nil end)
    
    SyncAll()
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
        Refresh = function(newOptions)
            if newOptions then options = newOptions end
            RefreshOptions(SearchBox.Text)
        end
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

    local Reset = Lib:Create("ImageButton", {
        Parent = item,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -135, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://127493377027615",
        ScaleType = Enum.ScaleType.Fit
    })
    Reset.MouseButton1Click:Connect(function()
        Input.Text = default or ""
        callback(Input.Text)
    end)
    
    return {
        SetValue = function(val)
            Input.Text = val
        end
    }
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
    local BtnHolder = Lib:Create("Frame", {
        Parent = container,
        BackgroundColor3 = Color3.fromRGB(45, 48, 55),
        Size = UDim2.new(0, 38, 0, 38)
    }, {
        Lib:Create("UICorner", {CornerRadius = UDim.new(0, 10)})
    })
    
    local Btn = Lib:Create("ImageButton", {
        Parent = BtnHolder,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 22, 0, 22),
        Image = "rbxassetid://" .. tostring(imageId):gsub("rbxassetid://", ""),
        ImageColor3 = Color3.fromRGB(200, 200, 200),
        ScaleType = Enum.ScaleType.Fit
    })
    
    -- Hover effects
    BtnHolder.MouseEnter:Connect(function()
        Lib:Tween(BtnHolder, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 120)})
        Lib:Tween(Btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    BtnHolder.MouseLeave:Connect(function()
        Lib:Tween(BtnHolder, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 48, 55)})
        Lib:Tween(Btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(200, 200, 200)})
    end)
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

function Components:AddFolder(container, title)
    -- Wrapper to hold both Button and Content together for LayoutOrder sorting
    local FolderContainer = Lib:Create("Frame", {
        Name = title .. "_Folder",
        Parent = container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.95, 0, 0, 35), -- Initial height (only button)
        AutomaticSize = Enum.AutomaticSize.Y
    }, {
         Lib:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) })
    })

    local IsOpen = false
    local FolderBtn = Lib:Create("TextButton", {
        Parent = FolderContainer,
        BackgroundColor3 = Theme.Section,
        Size = UDim2.new(1, 0, 0, 35),
        LayoutOrder = 0, -- Always top of wrapper
        Font = Theme.FontBold,
        Text = "  ▶  " .. title,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { Lib:Create("UICorner", {CornerRadius = Theme.CornerRadius}) })
    
    local Content = Lib:Create("Frame", {
        Parent = FolderContainer,
        BackgroundTransparency = 1,
        LayoutOrder = 1, -- Below button
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true
    }, {
        Lib:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
    })
    
    FolderBtn.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        FolderBtn.Text = (IsOpen and "  ▼  " or "  ▶  ") .. title
        Content.Visible = IsOpen
        -- Size is handled by AutomaticSize of wrapper if Content grows
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

    ColorBtn.MouseButton1Click:Connect(function()
        Lib:OpenPicker(color, function(newColor)
            color = newColor
            ColorBtn.BackgroundColor3 = color
            callback(color)
        end)
    end)
    
    local Reset = Lib:Create("ImageButton", {
        Parent = item,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://127493377027615",
        ScaleType = Enum.ScaleType.Fit
    })
    Reset.MouseButton1Click:Connect(function()
        color = default or Theme.Accent
        ColorBtn.BackgroundColor3 = color
        callback(color)
    end)

    return {
        SetValue = function(c)
            color = c
            ColorBtn.BackgroundColor3 = color
        end
    }
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
    }, { Lib:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}) })
    
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

function Components:AddInputWithColor(container, title, placeholder, defaultText, defaultColor, callback)
    local item = self:AddItem(container, title, nil)
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    local text = defaultText or ""
    
    local Input = Lib:Create("TextBox", {
        Parent = item,
        BackgroundColor3 = Color3.fromRGB(25, 27, 30),
        Position = UDim2.new(1, -140, 0.5, -12),
        Size = UDim2.new(0, 90, 0, 24),
        Font = Theme.FontRegular,
        PlaceholderText = placeholder or "...",
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })
    
    local ColorBtn = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = color,
        Position = UDim2.new(1, -42, 0.5, -10),
        Size = UDim2.new(0, 22, 0, 22),
        Text = ""
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 5)}) })

    ColorBtn.MouseButton1Click:Connect(function()
        Lib:OpenPicker(color, function(newColor)
            color = newColor
            ColorBtn.BackgroundColor3 = color
            callback(text, color)
        end)
    end)

    Input.FocusLost:Connect(function() text = Input.Text; callback(text, color) end)
    
    local Reset = Lib:Create("ImageButton", {
        Parent = item,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -165, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://127493377027615",
        ScaleType = Enum.ScaleType.Fit
    })
    Reset.MouseButton1Click:Connect(function()
        text, color = defaultText or "", defaultColor or Color3.fromRGB(255,255,255)
        Input.Text = text
        ColorBtn.BackgroundColor3 = color
        callback(text, color)
    end)

    return {
        SetValue = function(t, c)
            text = t or ""
            color = c or Color3.fromRGB(255, 255, 255)
            Input.Text = text
            ColorBtn.BackgroundColor3 = color
        end
    }
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

function Components:AddAssetColor(container, title, placeholder, defaultText, defaultColor, callback)
    local item = self:AddItem(container, title, nil)
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    local text = defaultText or ""
    
    local ColorBtn = Lib:Create("TextButton", {
        Parent = item,
        BackgroundColor3 = color,
        Position = UDim2.new(1, -42, 0.5, -10),
        Size = UDim2.new(0, 22, 0, 22),
        Text = ""
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 5)}) })

    local EditBtn = Lib:Create("ImageButton", {
        Parent = item,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -75, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://117761881427472", -- Edit icon
        ImageColor3 = Color3.fromRGB(200, 200, 200),
        ScaleType = Enum.ScaleType.Fit
    })

    -- Asset Input Panel (Mini)
    local InputPanel = Lib:Create("Frame", {
        Parent = item:FindFirstAncestor("SettingsUI"),
        BackgroundColor3 = Theme.Background,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(220, 80),
        Visible = false,
        ZIndex = 1100
    }, {
        Lib:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Lib:Create("UIStroke", {Color = Theme.Section, Thickness = 2})
    })

    local In = Lib:Create("TextBox", {
        Parent = InputPanel,
        Size = UDim2.new(0.9, 0, 0, 30),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.new(1,1,1),
        PlaceholderText = placeholder or "Asset ID...",
        Text = text,
        Font = Theme.FontRegular,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    local Save = Lib:Create("TextButton", {
        Parent = InputPanel,
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0.05, 0, 0.65, 0),
        BackgroundColor3 = Theme.Accent,
        Text = "Apply",
        Font = Theme.FontBold,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    local Cancel = Lib:Create("TextButton", {
        Parent = InputPanel,
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0.55, 0, 0.65, 0),
        BackgroundColor3 = Theme.Section,
        Text = "Cancel",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 12
    }, { Lib:Create("UICorner", {CornerRadius = UDim.new(0, 6)}) })

    EditBtn.MouseButton1Click:Connect(function() InputPanel.Visible = true; In.Text = text end)
    Cancel.MouseButton1Click:Connect(function() InputPanel.Visible = false end)
    Save.MouseButton1Click:Connect(function()
        text = In.Text
        InputPanel.Visible = false
        callback(text, color)
    end)

    ColorBtn.MouseButton1Click:Connect(function()
        Lib:OpenPicker(color, function(newColor)
            color = newColor
            ColorBtn.BackgroundColor3 = color
            callback(text, color)
        end)
    end)

    return {
        SetValue = function(t, c)
            text = t or ""
            color = c or Color3.fromRGB(255, 255, 255)
            ColorBtn.BackgroundColor3 = color
            In.Text = text
        end
    }
end

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
    AddItem = function(...) return Components:AddItem(...) end,
    AddInputWithColor = function(...) return Components:AddInputWithColor(...) end,
    AddAssetColor = function(...) return Components:AddAssetColor(...) end
}

return Library
