local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- الاضافات

local GamePlaceId = game.PlaceId
local GameName = game:GetService("MarketplaceService"):GetProductInfo(GamePlaceId).Name
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerName = Players.LocalPlayer.name
local GameJobId = game.JobId
local AccountAge = player.AccountAge
local hasPremium = player.MembershipType == Enum.MembershipType.Premium

local Window = Fluent:CreateWindow({
    Title = "7yd7 | Hub | " .. GameName .. " | " .. playerName,
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl 
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "info" }),
    Gameworks = Window:AddTab({ Title = "unknown", Icon = "gamepad-2" }),
    Script = Window:AddTab({ Title = "Script", Icon = "scroll" }),
     game = Window:AddTab({ Title = "Game", Icon = "usb" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do


local time = os.time()
local date = os.date("*t", time)

local hour = date.hour % 12
if hour == 0 then
    hour = 12
end

local min = string.format("%02d", date.min)
local sec = string.format("%02d", date.sec)

local ampm = date.hour >= 12 and "PM" or "AM"


-- معلومات عن سكربت

Tabs.Main:AddSection("info")

Tabs.Main:AddParagraph({
    Title = "Welcome " ..playerName.. " !"
})

Tabs.Main:AddParagraph({
    Title = "name game: " .. GameName
})

Tabs.Main:AddParagraph({
    Title = "id game: " .. GamePlaceId
})

Tabs.Main:AddParagraph({
    Title = "JobId game: " .. GameJobId
})

Tabs.Main:AddParagraph({
    Title = "Account Age: " .. AccountAge
})

Tabs.Main:AddParagraph({
    Title = "Player Premium: " .. (hasPremium and "yes" or "no")
})

Tabs.Main:AddParagraph({
    Title = "script run time: " .. date.day .. "/" .. date.month .. "/" .. date.year .. " " .. hour .. ":" .. min .. ":" .. sec .. " " .. ampm
})


Tabs.Main:AddParagraph({
    Title = "https://github.com/7yd7/Hub"
})

-- لا يوجد ماب

Tabs.Gameworks:AddParagraph({
    Title = "WARNING!",
    Content = "It seems that the game you entered is either unknown or has not been added to the game script."
})

-- سكربت جميع مابات

		Tabs.Script:AddSection("player")


    local Slider = Tabs.Script:AddSlider("Slider", {
        Title = "WalkSpeed",
        Description = "Adjust the speed of a personal player",
        Default = 16,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })

        Tabs.Script:AddButton({
        Title = "Reset WalkSpeed",
        Description = "Reset WalkSpeed normal",
        Callback = function()
            Window:Dialog({
                Title = "Reset WalkSpeed",
                Content = "Are you sure you want to reset the WalkSpeed?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                   game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })


    
    local Slider = Tabs.Script:AddSlider("Slider", {
        Title = "JumpPower",
        Description = "Adjust the JumpPower of a personal player",
        Default = 50,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    })

        Tabs.Script:AddButton({
        Title = "Reset JumpPower",
        Description = "Reset JumpPower normal",
        Callback = function()
            Window:Dialog({
                Title = "Reset JumpPower",
                Content = "Are you sure you want to reset the JumpPower?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                   game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })
    
    local Toggle = Tabs.Script:AddToggle("AntiAFKEnableds", {Title = "Anti AFK", Default = false})

    Toggle:OnChanged(function()
        getgenv().AntiAFKEnabled = Options.AntiAFKEnableds.Value
    
        if getgenv().AntiAFKEnabled then
            startAntiAFK()
        else
            getgenv().AntiAFKEnabled = false
        end
    end)
    
    function startAntiAFK()
        spawn(function()
            getgenv().antiAfkEnabled = true
    
            local VirtualUser = game:GetService("VirtualUser")
    
            game:GetService("Players").LocalPlayer.Idled:connect(function()
                while getgenv().antiAfkEnabled do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    print("Anti-AFK: Prevented AFK kick.")
                    wait(60)
                end
            end)
        end)
    end    
    
    Tabs.Script:AddSection("Script")


    Tabs.Script:AddButton({
        Title = "Infinite Yield",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Infinite Yield",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

                            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
                                end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

    Tabs.Script:AddButton({
        Title = "fates admin",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "fates admin",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

                            loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))()
                                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

    Tabs.Script:AddButton({
        Title = "Hydroxide",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Hydroxide",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

 local owner = "Upbolt"
local branch = "revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
                                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

    Tabs.Script:AddButton({
        Title = "SimpleSpy",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "SimpleSpy",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

                            loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
                                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

    Tabs.Script:AddButton({
        Title = "Dex V4",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Dex V4",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

                            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
                                        end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

    Tabs.Script:AddButton({
        Title = "Dex V3",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Dex V3",
                Content = "Are you sure you want to activate the script?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()

                            loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true))()
                                                end
                    },
                    {
                        Title = "No",
                        Callback = function()
                        end
                    }
                }
            })
        end
    })

-- سكربت لذي موجوده العاب


		Tabs.game:AddSection("Game Works Script")

        Tabs.game:AddParagraph({
            Title = "Important Warning",
            Content = "There are three different status levels for the map:\n🟢 Fully Functional (100%): The script operates perfectly within the map.\n🟠 Partially Functional (50%): The script has a 50% success rate; some commands may or may not work as intended.\n🔴 Non-Functional (0%): The script is not operational; commands are either not executed at all or have an extremely low chance of functioning correctly."
        })

        local api_url = "https://api.github.com/repos/7yd7/Hub/contents/Script?ref=Branch"

        local success, response = pcall(function()
            return request({
                Url = api_url,
                Method = "GET",
                Headers = {
                    ["Content-Type"] = "application/json"
                }
            })
        end)
        
        if success and response.StatusCode == 200 then
            local http = game:GetService("HttpService")
            local data = http:JSONDecode(response.Body)
        
            for _, file in pairs(data) do
                local fullName = file.name
                
                local mapName, mapId, status = fullName:match("^(.-)|(%d+)|(.+)$")
                
                if mapName and mapId and status then
                    mapId = tonumber(mapId)
        
                    Tabs.game:AddButton({
                        Title = mapName .. " | " .. status,
                        Description = "Game Script",
                        Callback = function()
                            Window:Dialog({
                                Title = "Teleport",
                                Content = "Teleport to game " .. mapName,
                                Buttons = {
                                    {
                                        Title = "Confirm",
                                        Callback = function()
                                            game:GetService("TeleportService"):Teleport(mapId, game:GetService("Players").LocalPlayer)
                                        end
                                    },
                                    {
                                        Title = "Cancel",
                                        Callback = function() end
                                    }
                                }
                            })
                        end
                    })
                else
                    print("Invalid format for file: " .. fullName)
                end
            end
        else
            print("Error fetching data: " .. (response and response.StatusMessage or "Unknown error"))
        end
        

-- نهايه

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)


SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

Window:SelectTab(1)


SaveManager:LoadAutoloadConfig()


InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

    end
