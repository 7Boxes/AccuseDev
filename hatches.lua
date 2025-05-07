local webhookURL = "https://discord.com/api/webhooks/1369534074733072394/n6X0aorhGZuvRN0Z-UKBdd2HWfWyKSnorq967X4ah76zXhkY-H1UnSuHaFJDGkkSNBQu"

-- UserID Mapping (Roblox -> Discord)
local discordUserMap = {
    ["ShadowfoxOvO"] = "781423808602177536",
    ["JamexIsH3re"] = "1066881053219881050",
    ["jamexalt"] = "1066881053219881050",
    ["Banana_X8000"] = "1240513870272008273"
    -- Add more mappings as needed
}

-- Improved webhook sender with error handling
function SendWebhook(url, message, embed)
    local http = game:GetService("HttpService")
    local headers = {["Content-Type"] = "application/json"}
    
    local data = {
        ["content"] = message or nil,
        ["embeds"] = embed and {embed} or nil
    }
    
    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = http:JSONEncode(data)
        })
    end)
    
    if not success then
        warn("Webhook failed: " .. tostring(response))
    end
end

-- Process server messages with emoji triggers
function ProcessServerMessage(message)
    -- 🎉 Pet hatch detection
    if message:find("🎉") then
        local playerName = message:match("🎉 (.+) just hatched")
        local petName = message:match("a (.+) %(")
        local petOdds = message:match("%((.+)%)")
        
        if playerName and petName then
            local player = game:GetService("Players"):FindFirstChild(playerName)
            if player then
                local leaderstats = player:FindFirstChild("leaderstats")
                if leaderstats then
                    local totalHatches = leaderstats:FindFirstChild("🥚") and leaderstats["🥚"].Value or "N/A"
                    local totalBubbles = leaderstats:FindFirstChild("Bubbles") and leaderstats.Bubbles.Value or "N/A"
                    
                    local discordID = discordUserMap[playerName] or nil
                    local mention = discordID and ("<@"..discordID..">") or "Someone"
                    
                    local embed = {
                        title = petName .. " Hatched!",
                        description = string.format("**%s**\nTotal Hatches: %s\nTotal Bubbles: %s", mention, totalHatches, totalBubbles),
                        color = 0x00FF00, -- Green
                        footer = {text = "by jajts <3"}
                    }
                    
                    SendWebhook(webhookURL, nil, embed)
                end
            end
        end
    
    -- 🍀 Luck boost detection
    elseif message:find("🍀") then
        local boostAmount = message:match("%+(%d+)%%")
        if boostAmount then
            local endTime = os.time() + 300 -- 5 minutes from now
            local content = string.format("🍀 **Server Luck Boosted: `%s%%` - <t:%d:R> 🍀", boostAmount, endTime)
            SendWebhook(webhookURL, content)
        end
    
    -- 🎲 Game egg detection
    elseif message:find("🎲") then
        local endTime = os.time() + 600 -- 10 minutes from now
        SendWebhook(webhookURL, string.format("🎲 **Game Egg Timer Increased!** Ends <t:%d:R>", endTime))
    end
end

-- Main chat listener
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    player.Chatted:Connect(function(message)
        if player == game:GetService("Players").LocalPlayer then return end -- Skip own messages
        ProcessServerMessage(message)
    end)
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        ProcessServerMessage(message)
    end)
end)

print("Chat filter webhook system activated!")
