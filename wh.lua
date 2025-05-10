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

-- Get pet data with error handling
local petData
local allPets = {}

local function loadPetData()
    local success, result = pcall(function()
        return require(ReplicatedStorage.Shared.Data.Pets)
    end)
    
    if not success then
        logError("LOAD_PET_DATA", "Failed to load pet data: " .. tostring(result))
        return {}
    end
    return result
end

petData = loadPetData()

-- Convert pet data to a more accessible format with error handling
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

-- Webhook sending function with proper HTTP request
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
        local success, response = pcall(function()
            -- Using HttpService:PostAsync instead of request
            return HttpService:PostAsync(modifiedWebhook, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
        end)
        
        if not success then
            logError("SEND_WEBHOOK", "Failed to send webhook: " .. tostring(response))
        else
            logDebug("Webhook sent successfully for pet: " .. displayName)
        end
    end)
end

-- Rest of the script remains the same...

-- Improved function to find UI elements
local function findDescendant(parent, names)
    if type(names) == "string" then
        names = {names}
    end
    
    local current = parent
    for _, name in ipairs(names) do
        current = current:FindFirstChild(name)
        if not current then
            return nil
        end
    end
    return current
end

-- Main checking function with detailed logging
local function CheckForRareHatch()
    logDebug("Starting hatch check...")
    
    local player = Players.LocalPlayer
    if not player then
        logError("CHECK_HATCH", "LocalPlayer not found")
        return
    end
    
    logDebug("Found LocalPlayer: " .. player.Name)
    
    -- Try to find the UI elements using multiple possible paths
    local gui = player.PlayerGui:FindFirstChild("ScreenGui") or player.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    if not gui then
        logError("CHECK_HATCH", "ScreenGui not found in PlayerGui")
        return
    end
    
    logDebug("Found ScreenGui")
    
    local hatching = findDescendant(gui, {"Hatching"}) or 
                     findDescendant(gui, {"Main", "Hatching"}) or
                     findDescendant(gui, {"MainGui", "Hatching"})
    
    if not hatching then
        logError("CHECK_HATCH", "Hatching frame not found")
        return
    end
    
    logDebug("Found Hatching frame")
    
    local lastHatch = findDescendant(hatching, {"Last"}) or
                      findDescendant(hatching, {"Recent", "Last"}) or
                      findDescendant(hatching, {"HatchHistory", "Last"})
    
    if not lastHatch then
        logError("CHECK_HATCH", "Last hatch frame not found")
        return
    end
    
    logDebug("Found Last hatch frame")
    
    -- Find the pet name UI element
    local petNameElement
    for _, child in ipairs(lastHatch:GetChildren()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Name ~= "Chance" then
            petNameElement = child
            break
        end
    end
    
    if not petNameElement then
        logError("CHECK_HATCH", "Pet name element not found in Last hatch")
        return
    end
    
    local petName = petNameElement.Text
    if not petName or petName == "" then
        logDebug("No pet name found (empty text)")
        return
    end
    
    logDebug("Found pet name: " .. petName)
    
    -- Find the chance UI element
    local chanceElement = findDescendant(lastHatch, {"Chance"}) or
                         findDescendant(lastHatch, {"TextLabel", "Chance"})
    
    if not chanceElement then
        logError("CHECK_HATCH", "Chance element not found")
        return
    end
    
    local chanceText = chanceElement.Text
    if not chanceText or chanceText == "" then
        logDebug("No chance text found (empty)")
        return
    end
    
    logDebug("Found chance text: " .. chanceText)
    
    -- Check if the odds are rare enough
    local isRare = false
    if RARE_ODDS[chanceText] then
        isRare = true
    else
        -- Check for numeric comparison if the format is different
        local numericValue = chanceText:match("([0-9.]+)%%")
        if numericValue then
            numericValue = tonumber(numericValue)
            if numericValue and numericValue <= 0.002 then
                isRare = true
            end
        end
    end
    
    if not isRare then
        logDebug("Pet not rare enough: " .. chanceText)
        return
    end
    
    logDebug("Rare pet detected: " .. petName .. " (" .. chanceText .. ")")
    
    -- Find the icon to check for shiny status
    local icon = findDescendant(lastHatch, {"Icon"}) or
                findDescendant(lastHatch, {"PetIcon", "Icon"})
    
    local isShiny = false
    local imageAssetId = ""
    
    if icon then
        local iconLabel = findDescendant(icon, {"Label"}) or
                        findDescendant(icon, {"ImageLabel", "Label"})
        
        if iconLabel then
            imageAssetId = iconLabel.Text or ""
            logDebug("Found image asset ID: " .. imageAssetId)
            
            -- Check if this is a shiny version
            local petInfo = allPets[petName]
            if petInfo and petInfo.images then
                if imageAssetId == petInfo.images.shiny then
                    isShiny = true
                    logDebug("Pet is shiny")
                elseif imageAssetId ~= petInfo.images.normal then
                    logDebug("Unknown pet image ID: " .. imageAssetId)
                end
            end
        else
            logDebug("Icon label not found")
        end
    else
        logDebug("Icon not found")
    end
    
    -- Get pet info
    local petInfo = allPets[petName] or {
        rarity = "Unknown",
        stats = {}
    }
    
    logDebug("Sending webhook for pet: " .. petName)
    SendWebhook(petName, chanceText, petInfo.rarity, petInfo.stats, imageAssetId, isShiny)
end

-- Main loop with error handling
while true do
    local success, err = pcall(CheckForRareHatch)
    if not success then
        logError("MAIN_LOOP", "Error in CheckForRareHatch: " .. tostring(err))
    end
    wait(CHECK_INTERVAL)
end
