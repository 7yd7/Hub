--[[
 Script not made by me, My process has been made easy.
 
 By: HeardKometa ( unsure )
]]

local CONFIG = {
    AUTO_COPY_TO_CLIPBOARD = false,
    AUTO_TELEPORT = true 
}

local md5 = {}
local hmac = {}
local base64 = {}

do
    local MD5_CONSTANTS = {
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    }

    local function safeAdd(a, b)
        local lsw = bit32.band(a, 0xFFFF) + bit32.band(b, 0xFFFF)
        local msw = bit32.rshift(a, 16) + bit32.rshift(b, 16) + bit32.rshift(lsw, 16)
        return bit32.bor(bit32.lshift(msw, 16), bit32.band(lsw, 0xFFFF))
    end

    local function rotateLeft(x, n)
        return bit32.bor(bit32.lshift(x, n), bit32.rshift(x, 32 - n))
    end

    local function F(x, y, z) return bit32.bor(bit32.band(x, y), bit32.band(bit32.bnot(x), z)) end
    local function G(x, y, z) return bit32.bor(bit32.band(x, z), bit32.band(y, bit32.bnot(z))) end
    local function H(x, y, z) return bit32.bxor(x, bit32.bxor(y, z)) end
    local function I(x, y, z) return bit32.bxor(y, bit32.bor(x, bit32.bnot(z))) end

    function md5.sum(message)
        local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
        local messageLen = #message
        local paddedMessage = message .. "\128"
        
        while #paddedMessage % 64 ~= 56 do
            paddedMessage = paddedMessage .. "\0"
        end

        local lenBytes = ""
        local lenBits = messageLen * 8
        for i = 0, 7 do
            lenBytes = lenBytes .. string.char(bit32.band(bit32.rshift(lenBits, i * 8), 0xFF))
        end
        paddedMessage = paddedMessage .. lenBytes

        for i = 1, #paddedMessage, 64 do
            local chunk = paddedMessage:sub(i, i + 63)
            local X = {}
            for j = 0, 15 do
                local b1, b2, b3, b4 = chunk:byte(j * 4 + 1, j * 4 + 4)
                X[j] = bit32.bor(b1 or 0, bit32.lshift(b2 or 0, 8), bit32.lshift(b3 or 0, 16), bit32.lshift(b4 or 0, 24))
            end

            local aa, bb, cc, dd = a, b, c, d
            local shifts = {7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21}

            for j = 0, 63 do
                local f, k, shiftIndex
                if j < 16 then
                    f = F(b, c, d)
                    k = j
                    shiftIndex = j % 4
                elseif j < 32 then
                    f = G(b, c, d)
                    k = (1 + 5 * j) % 16
                    shiftIndex = 4 + (j % 4)
                elseif j < 48 then
                    f = H(b, c, d)
                    k = (5 + 3 * j) % 16
                    shiftIndex = 8 + (j % 4)
                else
                    f = I(b, c, d)
                    k = (7 * j) % 16
                    shiftIndex = 12 + (j % 4)
                end

                local temp = safeAdd(safeAdd(safeAdd(a, f), X[k]), MD5_CONSTANTS[j + 1])
                temp = rotateLeft(temp, shifts[shiftIndex + 1])
                temp = safeAdd(b, temp)

                a, b, c, d = d, temp, b, c
            end

            a, b, c, d = safeAdd(a, aa), safeAdd(b, bb), safeAdd(c, cc), safeAdd(d, dd)
        end

        local function toLittleEndianHex(n)
            local result = ""
            for i = 0, 3 do
                result = result .. string.char(bit32.band(bit32.rshift(n, i * 8), 0xFF))
            end
            return result
        end

        return toLittleEndianHex(a) .. toLittleEndianHex(b) .. toLittleEndianHex(c) .. toLittleEndianHex(d)
    end

    function hmac.new(key, msg, hashFunc)
        if #key > 64 then
            key = hashFunc(key)
        end

        local oKeyPad, iKeyPad = "", ""
        for i = 1, 64 do
            local byte = (i <= #key and string.byte(key, i)) or 0
            oKeyPad = oKeyPad .. string.char(bit32.bxor(byte, 0x5C))
            iKeyPad = iKeyPad .. string.char(bit32.bxor(byte, 0x36))
        end

        return hashFunc(oKeyPad .. hashFunc(iKeyPad .. msg))
    end

    local BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    function base64.encode(data)
        return ((data:gsub('.', function(x)
            local r, bVal = '', x:byte()
            for i = 8, 1, -1 do
                r = r .. (bVal % 2^i - bVal % 2^(i-1) > 0 and '1' or '0')
            end
            return r;
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c = 0
            for i = 1, 6 do
                c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0)
            end
            return BASE64_CHARS:sub(c+1,c+1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1])
    end
end

local function generateSecureUUID()
    local template = 'xxxx-xxxx-4xxx-yxxx-xxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function GenerateReservedServerCode(placeId)
    if not placeId or placeId <= 0 then
        error("Invalid Place ID provided")
    end

    local uuid = {}
    for i = 1, 16 do
        uuid[i] = math.random(0, 255)
    end

    uuid[7] = bit32.bor(bit32.band(uuid[7], 0x0F), 0x40)
    uuid[9] = bit32.bor(bit32.band(uuid[9], 0x3F), 0x80) 

    local firstBytes = ""
    for i = 1, 16 do
        firstBytes = firstBytes .. string.char(uuid[i])
    end

    local gameCode = string.format(
        "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
        table.unpack(uuid)
    )

    local placeIdBytes = ""
    local tempPlaceId = placeId
    for _ = 1, 8 do
        placeIdBytes = placeIdBytes .. string.char(tempPlaceId % 256)
        tempPlaceId = math.floor(tempPlaceId / 256)
    end

    local content = firstBytes .. placeIdBytes

    local ROBLOX_SECRET_KEY = "e4Yn8ckbCJtw2sv7qmbg"
    local signature = hmac.new(ROBLOX_SECRET_KEY, content, md5.sum)

    local accessCodeBytes = signature .. content
    local accessCode = base64.encode(accessCodeBytes)
    
    accessCode = accessCode:gsub("+", "-"):gsub("/", "_")

    local padding = 0
    accessCode, _ = accessCode:gsub("=", function()
        padding = padding + 1
        return ""
    end)

    accessCode = accessCode .. tostring(padding)

    return accessCode, gameCode
end

local function TeleportToPrivateServer(placeId, accessCode)
    local success, err = pcall(function()
        game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(placeId, "", accessCode)
    end)
    

        return false
end

local function safeCopyToClipboard(text)
    if not CONFIG.AUTO_COPY_TO_CLIPBOARD then return false end
    
    local success, err = pcall(function()
        setclipboard(text)
    end)
    
        return false
    end

local function main()
    local success, result = pcall(function()
        local currentPlaceId = game.PlaceId
        
        if not currentPlaceId or currentPlaceId <= 0 then
            error("Cannot get valid Place ID")
        end

        
        local accessCode, gameCode = GenerateReservedServerCode(currentPlaceId)
        
        print("=== PRIVATE SERVER INFO ===")
        print("Place ID: " .. currentPlaceId)
        print("Access Code: " .. accessCode)
        print("Game Code: " .. gameCode)
        print("==========================")
        
        safeCopyToClipboard(accessCode)
        
        if CONFIG.AUTO_TELEPORT then
            TeleportToPrivateServer(currentPlaceId, accessCode)
        end
        
        return accessCode
    end)
    
    if success then
        return result
    else
        error("Script failed: " .. tostring(result))
    end
end

local function manualTeleport(accessCode)
    if not accessCode or accessCode == "" then
        return false
    end
    
    return TeleportToPrivateServer(game.PlaceId, accessCode)
end

local generatedAccessCode = main()


_G.TeleportToPrivateServer = manualTeleport
_G.GenerateNewServerCode = main
_G.GetLastAccessCode = function() return generatedAccessCode end

--[[
==============================================
USAGE EXAMPLES:

1. Manual teleport with custom code:
   _G.TeleportToPrivateServer("your_access_code_here")

2. Generate new server code:
   local newCode = _G.GenerateNewServerCode()

3. Get last generated code:
   local lastCode = _G.GetLastAccessCode()

==============================================
]]--
