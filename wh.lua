local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1310034563162046484/2aWtiIuFreQ-XRxdEBAm2NrcURi7ZKMGkWy7UfeHM4wWYx4dMlnhl_7AdknPkP2Tx5Vq" -- Replace with your actual webhook URL
local CHECK_INTERVAL = 0.1 -- 10 checks per second
local MIN_RARE_PERCENTAGE = 0.2 -- 0.2% threshold

-- Enable HTTP requests
HttpService.HttpEnabled = true

-- Logging functions
local function logError(message)
    warn("[ERROR] " .. message)
end

local function logDebug(message)
    print("[DEBUG] " .. message)
end

-- Load and process pet data
local petData = require(ReplicatedStorage.Shared.Data.Pets)
local allPets = {}

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

-- Webhook sender with all requested features
local function SendWebhook(petName, odds, rarity, stats, imageAssetId, isShiny)
    local displayName = isShiny and "Shiny " .. petName or petName
    local imageUrl = "https://ps99.biggamesapi.io/image/" .. (imageAssetId or "0")
    
    -- Format stats dynamically
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
            ["color"] = 65280, -- Green
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
    
    -- Webhook URL modification as requested
    local modifiedWebhook = string.gsub(WEBHOOK_URL, "https://discord.com", "https://webhook.lewisakura.moe")
    
    spawn(function()
        local success, response = pcall(function()
            local body = HttpService:JSONEncode(data)
            return HttpService:PostAsync(modifiedWebhook, body, Enum.HttpContentType.ApplicationJson)
        end)
        
        if not success then
            logError("Webhook failed: " .. tostring(response))
        else
            logDebug("Webhook sent for " .. displayName)
        end
    end)
end

-- Main checker with all fixes
local function CheckForRareHatch()
    local player = Players.LocalPlayer
    if not player then
        logError("Player not found")
        return
    end
    
    local gui = player.PlayerGui:FindFirstChild("ScreenGui") or player.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    if not gui then
        logError("ScreenGui not found")
        return
    end
    
    local hatching = gui:FindFirstChild("Hatching") or 
                   gui:FindFirstChild("MainGui") and gui.MainGui:FindFirstChild("Hatching")
    if not hatching then
        logError("Hatching frame not found")
        return
    end
    
    local lastHatch = hatching:FindFirstChild("Last") or 
                     hatching:FindFirstChild("Recent") and hatching.Recent:FindFirstChild("Last")
    if not lastHatch then
        logError("Last hatch frame not found")
        return
    end
    
    -- Check all potential pet frames
    for _, petFrame in ipairs(lastHatch:GetChildren()) do
        if petFrame:IsA("Frame") or petFrame:IsA("TextButton") then
            -- Find chance element with multiple possible locations
            local chanceElement = petFrame:FindFirstChild("Chance") or
                                petFrame:FindFirstChild("TextLabel") and 
                                petFrame.TextLabel:FindFirstChild("Chance")
            
            if chanceElement and chanceElement:IsA("TextLabel") then
                local petName = petFrame.Name
                local chanceText = chanceElement.Text
                
                if chanceText then
                    -- Parse percentage (handles both "0.2%" and "1/50000" formats)
                    local percentage = tonumber(chanceText:match("([%d%.]+)%%")) or 0
                    local fractionMatch = chanceText:match("1/(%d+)")
                    
                    if fractionMatch then
                        local denominator = tonumber(fractionMatch)
                        if denominator and denominator >= 50000 then
                            percentage = 100/denominator
                        end
                    end
                    
                    if percentage <= MIN_RARE_PERCENTAGE then
                        logDebug("RARE PET: " .. petName .. " (" .. chanceText .. ")")
                        
                        -- Find icon and get image asset ID (fixed to use Image property)
                        local icon = petFrame:FindFirstChild("Icon") or 
                                   petFrame:FindFirstChild("aicon") or
                                   petFrame:FindFirstChildOfClass("ImageLabel")
                        
                        local isShiny = false
                        local imageAssetId = ""
                        
                        if icon then
                            local imageId = icon.Image
                            if imageId then
                                imageAssetId = imageId:match("rbxassetid://(%d+)") or ""
                                logDebug("Image asset ID: " .. imageAssetId)
                                
                                -- Check for shiny status
                                local petInfo = allPets[petName]
                                if petInfo and petInfo.images then
                                    local normalId = petInfo.images.normal:match("rbxassetid://(%d+)") or ""
                                    local shinyId = petInfo.images.shiny:match("rbxassetid://(%d+)") or ""
                                    
                                    if imageAssetId == shinyId then
                                        isShiny = true
                                        logDebug("Shiny detected!")
                                    elseif imageAssetId ~= normalId then
                                        logDebug("Unknown image ID")
                                    end
                                end
                            end
                        end
                        
                        -- Get pet info with fallbacks
                        local petInfo = allPets[petName] or {
                            rarity = "Unknown",
                            stats = {}
                        }
                        
                        -- Send webhook with all collected info
                        SendWebhook(petName, chanceText, petInfo.rarity, petInfo.stats, imageAssetId, isShiny)
                    end
                end
            end
        end
    end
end

-- Main loop with error handling
while true do
    local success, err = pcall(CheckForRareHatch)
    if not success then
        logError("Main loop error: " .. tostring(err))
    end
    wait(CHECK_INTERVAL)
end
