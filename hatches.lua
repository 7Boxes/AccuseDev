local webhookURL = "https://discord.com/api/webhooks/1369534074733072394/n6X0aorhGZuvRN0Z-UKBdd2HWfWyKSnorq967X4ah76zXhkY-H1UnSuHaFJDGkkSNBQu"

-- UserID Mapping (Roblox -> Discord)
local discordUserMap = {
    ["ShadowfoxOvO"] = "781423808602177536",
    ["JamexIsH3re"] = "1066881053219881050",
    ["jamexalt"] = "1066881053219881050",
    ["Banana_X8000"] = "1240513870272008273"
    -- Add more mappings as needed
}

-- Debug mode (prints processing info to console)
local DEBUG_MODE = true

function logDebug(...)
    if DEBUG_MODE then
        print("[DEBUG]", ...)
    end
end

function SendWebhook(url, message, embed)
    local http = game:GetService("HttpService")
    local headers = {["Content-Type"] = "application/json"}
    
    local data = {
        ["content"] = message or nil,
        ["embeds"] = embed and {embed} or nil
    }
    
    logDebug("Sending webhook:", http:JSONEncode(data))
    
    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = http:JSONEncode(data)
        })
    end)
    
    if not success then
        warn("Webhook failed:", response)
    else
        logDebug("Webhook sent successfully")
    end
end

function ProcessChatMessage(message)
    logDebug("Processing message:", message)
    
    -- 🎉 Pet hatch detection
    if message:find("🎉") then
        logDebug("Found 🎉 trigger")
        local playerName = message:match("🎉%s+(.-)%s+just hatched") or "Someone"
        local petName = message:match("a (.+) %(") or "Unknown Pet"
        local petOdds = message:match("%((.+)%)") or "Unknown Odds"
        
        logDebug("Extracted data:", playerName, petName, petOdds)
        
        local player = game:GetService("Players"):FindFirstChild(playerName)
        local totalHatches = "N/A"
        local totalBubbles = "N/A"
        
        if player then
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                totalHatches = leaderstats:FindFirstChild("🥚") and leaderstats["🥚"].Value or "N/A"
                totalBubbles = leaderstats:FindFirstChild("Bubbles") and leaderstats.Bubbles.Value or "N/A"
            end
        end
        
        local discordID = discordUserMap[playerName]
        local mention = discordID and ("<@"..discordID..">") or playerName
        
        local embed = {
            title = petName .. " Hatched! ("..petOdds..")",
            description = string.format(
                "**Player:** %s\n**Total Hatches:** %s\n**Total Bubbles:** %s",
                mention, totalHatches, totalBubbles
            ),
            color = 0x00FF00,
            footer = {text = "by jajts <3"}
        }
        
        SendWebhook(webhookURL, nil, embed)
        return
    
    -- 🍀 Luck boost detection
    elseif message:find("🍀") then
        logDebug("Found 🍀 trigger")
        local boostAmount = message:match("%+(%d+)%%") or "?"
        local endTime = os.time() + 300 -- 5 minutes from now
        SendWebhook(webhookURL, string.format("🍀 **Server Luck Boosted: `%s%%` - Ends <t:%d:R> 🍀", boostAmount, endTime))
        return
    
    -- 🎲 Game egg detection
    elseif message:find("🎲") then
        logDebug("Found 🎲 trigger")
        local endTime = os.time() + 600 -- 10 minutes from now
        SendWebhook(webhookURL, string.format("🎲 **Game Egg Timer Increased!** Ends <t:%d:R>", endTime))
        return
    end
    
    logDebug("No triggers found in message")
end

-- Main chat monitoring system
local function SetupChatMonitor()
    logDebug("Setting up chat monitor...")
    
    -- Process existing messages (optional)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        player.Chatted:Connect(function(message)
            logDebug("New message from", player.Name)
            ProcessChatMessage(message)
        end)
    end
    
    -- Handle new players
    game:GetService("Players").PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            logDebug("New message from", player.Name)
            ProcessChatMessage(message)
        end)
    end)
    
    -- Check for system messages (from server)
    local chatEvents = {
        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"),
        game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest"),
        game:GetService("ReplicatedStorage"):FindFirstChild("ChatService")
    }
    
    for _, eventContainer in ipairs(chatEvents) do
        if eventContainer then
            if eventContainer:FindFirstChild("OnMessageDoneFiltering") then
                eventContainer.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
                    if data.FromSpeaker and data.Message then
                        logDebug("System message from", data.FromSpeaker)
                        ProcessChatMessage(data.Message)
                    end
                end)
            end
        end
    end
    
    logDebug("Chat monitor setup complete")
end

-- Initialize
SetupChatMonitor()
print("Chat monitoring system activated! Debug mode:", DEBUG_MODE)
