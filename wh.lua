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

-- Get pet data
local petData = require(ReplicatedStorage.Shared.Data.Pets)
local allPets = {}

-- Convert pet data to a more accessible format
for petName, petInfo in pairs(petData) do
    allPets[petName] = {
        rarity = petInfo.Rarity,
        stats = petInfo.Stat,
        images = {
            normal = petInfo.Image[1],
            shiny = petInfo.Image[2] or petInfo.Image[1] -- Fallback to normal if no shiny
        }
    }
end

-- Webhook sending function (similar to example)
local function SendWebhook(petName, odds, rarity, stats, imageAssetId, isShiny)
    local displayName = isShiny and "Shiny " .. petName or petName
    local imageUrl = "https://ps99.biggamesapi.io/image/" .. imageAssetId
    
    -- Format stats
    local statText = ""
    for statName, statValue in pairs(stats) do
        statText = statText .. string.format("%s: %.1f\n", statName, statValue)
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
    
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    local body = HttpService:JSONEncode(data)
    local success, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)
    
    if not success then
        warn("Failed to send webhook:", response)
    end
end

-- Main checking function
local function CheckForRareHatch()
    local player = Players.LocalPlayer
    if not player then return end
    
    local gui = player.PlayerGui:FindFirstChild("ScreenGui")
    if not gui then return end
    
    local hatching = gui:FindFirstChild("Hatching")
    if not hatching then return end
    
    local lastHatch = hatching:FindFirstChild("Last")
    if not lastHatch then return end
    
    -- Find the pet name UI element
    local petNameElement = nil
    for _, child in ipairs(lastHatch:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            petNameElement = child
            break
        end
    end
    
    if not petNameElement then return end
    
    local petName = petNameElement.Text
    if not petName or petName == "" then return end
    
    -- Find the chance UI element
    local chanceElement = lastHatch:FindFirstChild("Chance")
    if not chanceElement then return end
    
    local chanceText = chanceElement.Text
    if not chanceText or chanceText == "" then return end
    
    -- Check if the odds are rare enough
    if not RARE_ODDS[chanceText] then
        -- Also check for numeric comparison if the format is different
        local numericValue = chanceText:match("([0-9.]+)%%")
        if numericValue then
            numericValue = tonumber(numericValue)
            if numericValue and numericValue <= 0.002 then
                -- It's rare enough
            else
                return -- Not rare enough
            end
        else
            return -- Not rare enough
        end
    end
    
    -- Find the icon to check for shiny status
    local icon = lastHatch:FindFirstChild("Icon")
    local isShiny = false
    local imageAssetId = ""
    
    if icon then
        local iconLabel = icon:FindFirstChild("Label")
        if iconLabel then
            imageAssetId = iconLabel.Text
            -- Check if this is a shiny version
            local petInfo = allPets[petName]
            if petInfo then
                if imageAssetId == petInfo.images.shiny then
                    isShiny = true
                elseif imageAssetId ~= petInfo.images.normal then
                    -- Pet not found in our data
                    warn("Unknown pet image ID:", imageAssetId)
                end
            end
        end
    end
    
    -- Get pet info
    local petInfo = allPets[petName] or {
        rarity = "Unknown",
        stats = {}
    }
    
    -- Send webhook notification
    SendWebhook(petName, chanceText, petInfo.rarity, petInfo.stats, imageAssetId, isShiny)
end

-- Main loop
while true do
    local success, err = pcall(CheckForRareHatch)
    if not success then
        warn("Error in CheckForRareHatch:", err)
    end
    wait(CHECK_INTERVAL)
end
