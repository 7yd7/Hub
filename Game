local function encodeURL(url)
    url = string.gsub(url, "|", "%%7C")
    url = string.gsub(url, "🟢", "%%F0%%9F%%9F%%A2")
    url = string.gsub(url, "🟠", "%%F0%%9F%%9F%%A0") 
    url = string.gsub(url, "🔴", "%%F0%%9F%%94%%B4")
    return url
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local api_url = "https://api.github.com/repos/7yd7/Hub/contents/Script?ref=Branch"

local PlaceId = game.PlaceId

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

    local found = false
    for _, file in pairs(data) do
        local fullName = file.name
        local nameParts = string.split(fullName, "|")
        
        local mapName = nameParts[1]
        local mapId = tonumber(nameParts[2])
        local status = nameParts[3]
        local download_url = file.download_url

        if download_url and PlaceId == mapId then
            print("Game is running: " .. mapName)

            Fluent:Notify({
                Title = "7yd7 | Hub",
                Content = "Script has been run",
                Duration = 8
            })

            local encoded_url = encodeURL(download_url)
            print("Encoded URL: " .. encoded_url)

            loadstring(game:HttpGet(encoded_url))()
            found = true
            break
        end
    end
    
    if not found then
        print("No script found for this Game.")

        Fluent:Notify({
            Title = "7yd7 | Hub",
            Content = "No script found for this Game.",
            Duration = 8
        })

        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/NoGame.lua"))()
    end
else
    print("Error fetching data: " .. (response and response.StatusMessage or "Unknown error"))
end
