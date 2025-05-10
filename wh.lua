local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1310034563162046484/2aWtiIuFreQ-XRxdEBAm2NrcURi7ZKMGkWy7UfeHM4wWYx4dMlnhl_7AdknPkP2Tx5Vq" -- Replace with your actual webhook URL
local CHECK_INTERVAL = 0.1 -- Check 10 times per second
local MIN_RARE_PERCENTAGE = 0.2 -- 0.2%

-- Enable HTTP requests
HttpService.HttpEnabled = true

-- Error logging
local function logError(message)
    warn("[ERROR] " .. message)
end

local function logDebug(message)
    print("[DEBUG] " .. message)
end

-- Load pet data
local petData = require(ReplicatedStorage.Shared.Data.Pets)
local allPets = {}

for petName, petInfo in pairs(petData) do
    local images = {}
    if petInfo.Image then
        images.normal = petInfo.Image[1] or "rbxassetid://0"
        images.shiny = petInfo.Image[2] or images.normal
    end
    
    allPets[petName] = {
        rarity = petInfo.Rarity or "Unknown",
        stats = petInfo.Stat or {},
        images = images
    }
end

-- Webhook sender
local function SendWebhook(petName, odds, rarity, stats, imageAssetId, isShiny)
    local displayName = isShiny and "Shiny " .. petName or petName
    local imageUrl = "https://ps99.biggamesapi.io/image/" .. (imageAssetId or "0")
    
    -- Format stats
    local statText = ""
    for statName, statValue in pairs(stats) do
        statText = statText .. string.format("%s: %.1f\n", statName, statValue)
    end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "New Hatch!",
            ["color"] = 65280,
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

-- Main checker
local function CheckForRareHatch()
    local player = Players.LocalPlayer
    if not player then return end
    
    local gui = player.PlayerGui:FindFirstChild("ScreenGui")
    if not gui then return end
    
    local hatching = gui:FindFirstChild("Hatching")
    if not hatching then return end
    
    local lastHatch = hatching:FindFirstChild("Last")
    if not lastHatch then return end
    
    -- Check all pet frames
    for _, petFrame in ipairs(lastHatch:GetChildren()) do
        if petFrame:IsA("Frame") or petFrame:IsA("TextButton") then
            local chanceElement = petFrame:FindFirstChild("Chance")
            if chanceElement and chanceElement:IsA("TextLabel") then
                local petName = petFrame.Name
                local chanceText = chanceElement.Text
                
                if chanceText then
                    -- Parse percentage
                    local percentage = tonumber(chanceText:match("([%d%.]+)%%")) or 0
                    
                    if percentage <= MIN_RARE_PERCENTAGE then
                        logDebug("RARE PET: " .. petName .. " (" .. chanceText .. ")")
                        
                        -- Check shiny
                        local icon = petFrame:FindFirstChild("Icon")
                        local isShiny = false
                        local imageAssetId = ""
                        
                        if icon then
                            local iconLabel = icon:FindFirstChild("Label")
                            if iconLabel then
                                imageAssetId = iconLabel.Text or ""
                                local petInfo = allPets[petName]
                                if petInfo and petInfo.images then
                                    isShiny = (imageAssetId == petInfo.images.shiny)
                                end
                            end
                        end
                        
                        -- Get pet info
                        local petInfo = allPets[petName] or {
                            rarity = "Unknown",
                            stats = {}
                        }
                        
                        -- Send webhook
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
        logError("Check failed: " .. tostring(err))
    end
    wait(CHECK_INTERVAL)
end
