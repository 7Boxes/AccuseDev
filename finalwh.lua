-- Pet Hatch Notifier Main Script
return function(config)
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Validate config
    config = config or {}
    if not config.WEBHOOK_URL then
        error("WEBHOOK_URL is required in config")
    end
    
    -- Set defaults for optional configs
    config.CHECK_INTERVAL = config.CHECK_INTERVAL or 0.1
    config.MIN_RARE_PERCENTAGE = config.MIN_RARE_PERCENTAGE or 0.2
    config.ANTI_SPAM_DELAY = config.ANTI_SPAM_DELAY or 1
    config.DEBUG = config.DEBUG or false
    
    -- Track last sent webhooks
    local lastWebhookTimes = {}
    
    -- Logging functions
    local function logError(message)
        warn("[ERROR] " .. message)
    end

    local function logDebug(message)
        if config.DEBUG then
            print("[DEBUG] " .. message)
        end
    end

    -- Universal request function for webhooks
    local function request(data)
        if syn and syn.request then
            return syn.request(data)
        elseif http and http.request then
            return http.request(data)
        elseif fluxus and fluxus.request then
            return fluxus.request(data)
        elseif request then
            return request(data)
        elseif http_request then
            return http_request(data)
        else
            local response = nil
            pcall(function()
                response = HttpService:PostAsync(data.Url, data.Body, Enum.HttpContentType.ApplicationJson)
            end)
            return {StatusCode = response and 200 or 0}
        end
    end

    -- Load and process pet data
    local petData = require(ReplicatedStorage.Shared.Data.Pets)
    local allPets = {}

    for petName, petInfo in pairs(petData) do
        local stats = {}
        
        if petInfo.Stat then
            if petInfo.Stat.Bubbles then
                stats.Bubbles = type(petInfo.Stat.Bubbles) == "table" and petInfo.Stat.Bubbles._am or petInfo.Stat.Bubbles
            end
            
            if petInfo.Stat.Coins then
                stats.Coins = type(petInfo.Stat.Coins) == "table" and petInfo.Stat.Coins._am or petInfo.Stat.Coins
            end
            
            if petInfo.Stat.Gems then
                stats.Gems = type(petInfo.Stat.Gems) == "table" and petInfo.Stat.Gems._am or petInfo.Stat.Gems
            end
        end
        
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
            stats = stats,
            images = images
        }
        
        logDebug("Loaded pet: "..petName.." | Rarity: "..allPets[petName].rarity)
    end

    -- Webhook sender with anti-spam
    local function SendWebhook(petName, odds, rarity, stats, imageAssetId, isShiny)
        local currentTime = os.time()
        if lastWebhookTimes[petName] and (currentTime - lastWebhookTimes[petName] < config.ANTI_SPAM_DELAY) then
            logDebug("Skipping webhook for " .. petName .. " (anti-spam)")
            return
        end
        
        lastWebhookTimes[petName] = currentTime
        
        local displayName = isShiny and "Shiny " .. petName or petName
        local imageUrl = "https://ps99.biggamesapi.io/image/" .. (imageAssetId or "0")
        
        local statText = ""
        if stats then
            if stats.Bubbles then
                statText = statText .. string.format("Bubbles: %.1f\n", stats.Bubbles)
            end
            
            if stats.Coins then
                statText = statText .. string.format("Coins: %.1f\n", stats.Coins)
            end
            
            for statName, statValue in pairs(stats) do
                if statName ~= "Bubbles" and statName ~= "Coins" then
                    statText = statText .. string.format("%s: %.1f\n", statName, statValue)
                end
            end
        else
            statText = "No stats available"
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
        
        spawn(function()
            local newdata = HttpService:JSONEncode(data)
            local headers = {
                ["content-type"] = "application/json"
            }
            
            local requestData = {
                Url = string.gsub(config.WEBHOOK_URL, "https://discord.com", "https://webhook.lewisakura.moe"),
                Body = newdata,
                Method = "POST",
                Headers = headers
            }
            
            local success, response = pcall(function()
                local res = request(requestData)
                return res.StatusCode == 200
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
        
        local gui = player.PlayerGui:FindFirstChild("ScreenGui") or player.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
        if not gui then return end
        
        local hatching = gui:FindFirstChild("Hatching") or 
                       gui:FindFirstChild("MainGui") and gui.MainGui:FindFirstChild("Hatching")
        if not hatching then return end
        
        local lastHatch = hatching:FindFirstChild("Last") or 
                         hatching:FindFirstChild("Recent") and hatching.Recent:FindFirstChild("Last")
        if not lastHatch then return end
        
        for _, petFrame in ipairs(lastHatch:GetChildren()) do
            if petFrame:IsA("Frame") or petFrame:IsA("TextButton") then
                local chanceElement = petFrame:FindFirstChild("Chance") or
                                    petFrame:FindFirstChild("TextLabel") and 
                                    petFrame.TextLabel:FindFirstChild("Chance")
                
                if chanceElement and chanceElement:IsA("TextLabel") then
                    local petName = petFrame.Name
                    local chanceText = chanceElement.Text
                    
                    if chanceText then
                        local percentage = tonumber(chanceText:match("([%d%.]+)%%")) or 0
                        local fractionMatch = chanceText:match("1/(%d+)")
                        
                        if fractionMatch then
                            local denominator = tonumber(fractionMatch)
                            if denominator and denominator >= 50000 then
                                percentage = 100/denominator
                            end
                        end
                        
                        if percentage <= config.MIN_RARE_PERCENTAGE then
                            logDebug("RARE PET: " .. petName .. " (" .. chanceText .. ")")
                            
                            local icon = petFrame:FindFirstChild("Icon")
                            local isShiny = false
                            local imageAssetId = ""
                            
                            if icon then
                                local iconLabel = icon:FindFirstChild("Label")
                                if iconLabel and iconLabel:IsA("ImageLabel") then
                                    local imageId = iconLabel.Image
                                    if imageId then
                                        imageAssetId = imageId:match("rbxassetid://(%d+)") or ""
                                        logDebug("Found image asset ID: " .. imageAssetId)
                                        
                                        local petInfo = allPets[petName]
                                        if petInfo and petInfo.images then
                                            local normalId = petInfo.images.normal:match("rbxassetid://(%d+)") or ""
                                            local shinyId = petInfo.images.shiny:match("rbxassetid://(%d+)") or ""
                                            
                                            if imageAssetId == shinyId then
                                                isShiny = true
                                                logDebug("Shiny detected!")
                                            end
                                        end
                                    end
                                end
                            end
                            
                            local petInfo = allPets[petName] or {
                                rarity = "Unknown",
                                stats = {}
                            }
                            
                            SendWebhook(petName, chanceText, petInfo.rarity, petInfo.stats, imageAssetId, isShiny)
                        end
                    end
                end
            end
        end
    end

    -- Start the main loop
    coroutine.wrap(function()
        while true do
            local success, err = pcall(CheckForRareHatch)
            if not success then
                logError("Main loop error: " .. tostring(err))
            end
            wait(config.CHECK_INTERVAL)
        end
    end)()
end
