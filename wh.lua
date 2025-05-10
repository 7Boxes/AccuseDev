local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1310034563162046484/2aWtiIuFreQ-XRxdEBAm2NrcURi7ZKMGkWy7UfeHM4wWYx4dMlnhl_7AdknPkP2Tx5Vq" -- Replace with your actual webhook URL
local CHECK_INTERVAL = 0.1 -- Check 10 times per second (1/10)
local RARE_ODDS = {
    ["1/50000"] = true,
    ["0.002%"] = true,
    -- Add any other equivalent rare odds formats here
}

-- Error logging function
local function logError(stage, message)
    warn("[ERROR][" .. stage .. "] " .. message)
end

-- Debug logging function
local function logDebug(message)
    print("[DEBUG] " .. message)
end

-- Get pet data
local petData = require(ReplicatedStorage.Shared.Data.Pets)
local allPets = {}

-- Convert pet data to a more accessible format
for petName, petInfo in pairs(petData) do
    local images = {}
    if petInfo.Image then
        images.normal = petInfo.Image[1] or "rbxassetid://0"
        images.shiny = petInfo.Image[2] or images.normal
    else
        images.normal = "rbxassetid://0"
        images.shiny = "rbxassetid://0"
    end
    
    allPets[petName] = {
        rarity = petInfo.Rarity or "Unknown",
        stats = petInfo.Stat or {},
        images = images
    }
end

-- Webhook sending function
local function SendWebhook(petName, odds, rarity, stats, imageAssetId, isShiny)
    local displayName = isShiny and "Shiny " .. petName or petName
    local imageUrl = "https://ps99.biggamesapi.io/image/" .. (imageAssetId or "0")
    
    -- Format stats
    local statText = ""
    if stats then
        for statName, statValue in pairs(stats) do
            statText = statText .. string.format("%s: %.1f\n", statName, statValue)
        end
    else
        statText = "No stats available"
    end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "New Hatch!",
            ["color"] = 65280, -- Green color
            ["thumbnail"] = {
                ["url"] = imageUrl
            },
            ["fields"] = {
                {
                    ["name"] = "Pet",
                    ["value"] = displayName,
                    ["inline"] = true
                },
                {
                    ["name"] = "Rarity",
                    ["value"] = rarity,
                    ["inline"] = true
                },
                {
                    ["name"] = "Odds",
                    ["value"] = odds,
                    ["inline"] = true
                },
                {
                    ["name"] = "Stats",
                    ["value"] = statText,
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Pet Hatch Notifier"
            }
        }}
    }
    
    local modifiedWebhook = string.gsub(WEBHOOK_URL, "https://discord.com", "https://webhook.lewisakura.moe")
    
    spawn(function()
        local headers = {
            ["Content-Type"] = "application/json"
        }
        
        local body = HttpService:JSONEncode(data)
        local success, response = pcall(function()
            return HttpService:PostAsync(modifiedWebhook, body, Enum.HttpContentType.ApplicationJson)
        end)
        
        if not success then
            logError("SEND_WEBHOOK", "Failed to send webhook: " .. tostring(response))
        else
            logDebug("Webhook sent successfully for pet: " .. displayName)
        end
    end)
end

-- Main checking function with updated path finding
local function CheckForRareHatch()
    local player = Players.LocalPlayer
    if not player then
        logError("CHECK_HATCH", "LocalPlayer not found")
        return
    end
    
    local gui = player.PlayerGui:FindFirstChild("ScreenGui")
    if not gui then
        logError("CHECK_HATCH", "ScreenGui not found")
        return
    end
    
    local hatching = gui:FindFirstChild("Hatching")
    if not hatching then
        logError("CHECK_HATCH", "Hatching frame not found")
        return
    end
    
    local lastHatch = hatching:FindFirstChild("Last")
    if not lastHatch then
        logError("CHECK_HATCH", "Last hatch frame not found")
        return
    end
    
    -- Find all pet name frames (Kitty, Doggy, Bunny, etc.)
    for _, petFrame in ipairs(lastHatch:GetChildren()) do
        if petFrame:IsA("Frame") or petFrame:IsA("TextButton") then
            local chanceElement = petFrame:FindFirstChild("Chance")
            if chanceElement then
                local petName = petFrame.Name
                local chanceText = chanceElement.Text
                
                if chanceText and chanceText ~= "" then
                    logDebug("Found pet: " .. petName .. " with chance: " .. chanceText)
                    
                    -- Check if the odds are rare enough
                    local isRare = false
                    if RARE_ODDS[chanceText] then
                        isRare = true
                    else
                        local numericValue = chanceText:match("([0-9.]+)%%")
                        if numericValue then
                            numericValue = tonumber(numericValue)
                            if numericValue and numericValue <= 0.002 then
                                isRare = true
                            end
                        end
                    end
                    
                    if isRare then
                        logDebug("Rare pet detected: " .. petName .. " (" .. chanceText .. ")")
                        
                        -- Find icon for shiny detection
                        local icon = petFrame:FindFirstChild("Icon")
                        local isShiny = false
                        local imageAssetId = ""
                        
                        if icon then
                            local iconLabel = icon:FindFirstChild("Label")
                            if iconLabel then
                                imageAssetId = iconLabel.Text or ""
                                logDebug("Found image asset ID: " .. imageAssetId)
                                
                                -- Check if shiny
                                local petInfo = allPets[petName]
                                if petInfo and petInfo.images then
                                    if imageAssetId == petInfo.images.shiny then
                                        isShiny = true
                                        logDebug("Pet is shiny")
                                    elseif imageAssetId ~= petInfo.images.normal then
                                        logDebug("Unknown pet image ID: " .. imageAssetId)
                                    end
                                end
                            end
                        end
                        
                        -- Get pet info
                        local petInfo = allPets[petName] or {
                            rarity = "Unknown",
                            stats = {}
                        }
                        
                        logDebug("Sending webhook for pet: " .. petName)
                        SendWebhook(petName, chanceText, petInfo.rarity, petInfo.stats, imageAssetId, isShiny)
                    end
                end
            end
        end
    end
end

-- Main loop
while true do
    local success, err = pcall(CheckForRareHatch)
    if not success then
        logError("MAIN_LOOP", "Error in CheckForRareHatch: " .. tostring(err))
    end
    wait(CHECK_INTERVAL)
end
