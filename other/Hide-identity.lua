--[[ Hide some client information or cheat bypass I don't know

getgenv().IdentityConfig = getgenv().IdentityConfig or {
    FakeName = "???",
    FakeUserId = 1,
    FakeHWID = "???",
    FakePremium = true,
    FakeJobId = "???",
    FakePlaceId = 106656461757128,
    FakeGameName = "???",
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/other/Hide-identity.lua"))()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

getgenv().IdentityHider = getgenv().IdentityHider or {}
local savedData = getgenv().IdentityHider

if not savedData.originalName then
    savedData.originalName = Players.LocalPlayer.Name
    savedData.originalDisplayName = Players.LocalPlayer.DisplayName
    savedData.originalUserId = Players.LocalPlayer.UserId
    savedData.appliedChanges = {}
end

savedData.changedLocations = savedData.changedLocations or {}

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldIndex = mt.__index
    mt.__index = function(obj, key)
        if obj == game and key == "JobId" then
            return getgenv().IdentityConfig.FakeJobId
        end
        if obj == game and key == "PlaceId" then
            return getgenv().IdentityConfig.FakePlaceId
        end
        if obj == game and key == "Name" then
            return getgenv().IdentityConfig.FakeGameName
        end
        if tostring(obj) == "MembershipType" and key == "EnumItem" then
            return getgenv().IdentityConfig.FakePremium and Enum.MembershipType.Premium or Enum.MembershipType.None
        end
        return oldIndex(obj, key)
    end

    local oldNamecall = mt.__namecall
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if method == "GetClientId" and tostring(self) == "RbxAnalyticsService" then
            return getgenv().IdentityConfig.FakeHWID
        end
        return oldNamecall(self, ...)
    end
end)

local function isLocationChanged(object, property)
    local fullName = object:GetFullName() .. "." .. property
    return savedData.changedLocations[fullName] == true
end

local function markLocationChanged(object, property)
    local fullName = object:GetFullName() .. "." .. property
    savedData.changedLocations[fullName] = true
end

local function applyPlayerChanges()
    local localPlayer = Players.LocalPlayer
    
    if localPlayer.Name == savedData.originalName and not isLocationChanged(localPlayer, "Name") then
        localPlayer.Name = getgenv().IdentityConfig.FakeName
        markLocationChanged(localPlayer, "Name")
    end
    
    if localPlayer.DisplayName == savedData.originalDisplayName and not isLocationChanged(localPlayer, "DisplayName") then
        localPlayer.DisplayName = getgenv().IdentityConfig.FakeName
        markLocationChanged(localPlayer, "DisplayName")
    end
    
    if localPlayer.UserId == savedData.originalUserId and not isLocationChanged(localPlayer, "UserId") then
        pcall(function()
            localPlayer.UserId = getgenv().IdentityConfig.FakeUserId
            markLocationChanged(localPlayer, "UserId")
        end)
    end
end

local function updateWorkspaceNames(object)
    for _, child in pairs(object:GetChildren()) do
        if child.Name == savedData.originalName and not isLocationChanged(child, "Name") then
            child.Name = getgenv().IdentityConfig.FakeName
            markLocationChanged(child, "Name")
        end
        
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child.Text == savedData.originalName and not isLocationChanged(child, "Text") then
                child.Text = getgenv().IdentityConfig.FakeName
                markLocationChanged(child, "Text")
            elseif child.Text == savedData.originalDisplayName and not isLocationChanged(child, "Text") then
                child.Text = getgenv().IdentityConfig.FakeName
                markLocationChanged(child, "Text")
            end
        end
        updateWorkspaceNames(child)
    end
end

local function updatePlayerGui()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        updateWorkspaceNames(playerGui)
    end
end

local function updateCoreGui()
    local success, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success and coreGui then
        for _, gui in pairs(coreGui:GetChildren()) do
            updateWorkspaceNames(gui)
        end
    end
end

local function applyAllChanges()
    applyPlayerChanges()
    updateWorkspaceNames(workspace)
    updatePlayerGui()
    updateCoreGui()
end

local function setupMonitoring()
    workspace.ChildAdded:Connect(function(child)
        task.wait(0.1)
        updateWorkspaceNames(child)
    end)
    
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    playerGui.ChildAdded:Connect(function(child)
        task.wait(0.1)
        updateWorkspaceNames(child)
    end)
    
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        coreGui.ChildAdded:Connect(function(child)
            task.wait(0.1)
            updateWorkspaceNames(child)
        end)
        
        for _, gui in pairs(coreGui:GetChildren()) do
            gui.ChildAdded:Connect(function(newChild)
                task.wait(0.1)
                updateWorkspaceNames(newChild)
            end)
        end
    end)
    
    Players.LocalPlayer.Changed:Connect(function(property)
        if property == "Name" or property == "DisplayName" or property == "UserId" then
            task.wait(0.1)
            applyPlayerChanges()
        end
    end)
end

local function startContinuousLoop()
    task.spawn(function()
        while true do
            task.wait(2)
            
            applyPlayerChanges()
            
            pcall(function()
                updateWorkspaceNames(workspace)
            end)
            
            pcall(function()
                updatePlayerGui()
            end)
            
            pcall(function()
                updateCoreGui()
            end)
        end
    end)
end

applyAllChanges()
setupMonitoring()
startContinuousLoop()

getgenv().restoreIdentity = function()
    local localPlayer = Players.LocalPlayer
    localPlayer.Name = savedData.originalName
    localPlayer.DisplayName = savedData.originalDisplayName
    pcall(function()
        localPlayer.UserId = savedData.originalUserId
    end)
end
