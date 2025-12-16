--[[
Hey! 👋
Simple counter for active users.
Only stores your UserId temporarily - no personal data.
Live count: http://botscripts.lol/api/count.php
]]

local SCRIPT_VERSION = "2.1"
local API_URL = "http://botscripts.lol/api"

task.spawn(function()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local sessionId = tostring(player.UserId)

        if not _G.BotScriptsRegistered then
            _G.BotScriptsRegistered = true
            _G.BotScriptsVersion = SCRIPT_VERSION

            local httpRequest = request or http_request or (syn and syn.request) or http.request or fluxus and fluxus.request

            if httpRequest then
                
                local function sendHeartbeat(isStartup)
                    local success, result = pcall(function()
                        local payload = {
                            sessionId = sessionId,
                            version = SCRIPT_VERSION
                        }
                        if isStartup then
                            payload.startup = true
                        end
                        
                        local data = HttpService:JSONEncode(payload)
                        
                        httpRequest({
                            Url = API_URL .. "/heartbeat.php",
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = data
                        })
                    end)
                end

                local function onLeave()
                    pcall(function()
                        local data = HttpService:JSONEncode({
                            sessionId = sessionId,
                            version = SCRIPT_VERSION
                        })
                        httpRequest({
                            Url = API_URL .. "/leave.php",
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = data
                        })
                    end)
                end

                task.spawn(function()
                    -- Heartbeat every 40 seconds
                    while task.wait(600) do
                        sendHeartbeat(false)
                    end
                end)

                -- Initial Heartbeat (Counts as Execution)
                sendHeartbeat(true)

                Players.LocalPlayer.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        onLeave()
                    end
                end)
            end
        end
    end)
end)
