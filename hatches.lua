local WebHook = {
    ChatHook = "https://discord.com/api/webhooks/1369534074733072394/n6X0aorhGZuvRN0Z-UKBdd2HWfWyKSnorq967X4ah76zXhkY-H1UnSuHaFJDGkkSNBQu"
}

-- UserID Mapping (Roblox -> Discord)
local discordUserMap = {
    ["ShadowfoxOvO"] = "781423808602177536",
    ["JamexIsH3re"] = "1066881053219881050",
    ["jamexalt"] = "1066881053219881050",
    ["Banana_X8000"] = "1240513870272008273"
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

function SendWebhook(message, embed)
    local data = {
        ["content"] = message or nil,
        ["embeds"] = embed and {embed} or nil
    }
    
    local success, response = pcall(function()
        HttpService:PostAsync(WebHook.ChatHook, HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("Webhook failed:", response)
    end
end

function ProcessChatMessage(player, message)
    -- 🎉 Pet hatch detection
    if message:find("🎉") then
        local playerName = player.Name
        local petName = message:match("a (.+) %(") or "Unknown Pet"
        local petOdds = message:match("%((.+)%)") or "Unknown Odds"
        
        local leaderstats = player:FindFirstChild("leaderstats")
        local totalHatches = leaderstats and leaderstats:FindFirstChild("🥚") and leaderstats["🥚"].Value or "N/A"
        local totalBubbles = leaderstats and leaderstats:FindFirstChild("Bubbles") and leaderstats.Bubbles.Value or "N/A"
        
        local discordID = discordUserMap[playerName]
        local mention = discordID and ("<@"..discordID..">") or playerName
        
        local embed = {
            ["title"] = petName .. " Hatched! ("..petOdds..")",
            ["description"] = string.format(
                "**Player:** %s\n**Total Hatches:** %s\n**Total Bubbles:** %s",
                mention, totalHatches, totalBubbles
            ),
            ["color"] = tonumber(0x00FF00),
            ["thumbnail"] = {
                ["url"] = "https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&userId="..player.UserId,
                ["height"] = 100,
                ["width"] = 100
            },
            ["footer"] = {
                ["text"] = "by jajts <3"
            },
            ["fields"] = {
                {
                    ["name"] = "Server Job-ID:",
                    ["value"] = "(`"..game.JobId.."`)",
                    ["inline"] = false
                },
                {
                    ["name"] = "Game Name & Place ID:",
                    ["value"] = "Name: "..MarketplaceService:GetProductInfo(game.PlaceId).Name..", PlaceID: "..game.PlaceId,
                    ["inline"] = false
                }
            }
        }
        
        SendWebhook(nil, embed)
        return
    
    -- 🍀 Luck boost detection
    elseif message:find("🍀") then
        local boostAmount = message:match("%+(%d+)%%") or "?"
        local endTime = os.time() + 300
        SendWebhook(string.format("🍀 **Server Luck Boosted: `%s%%` - Ends <t:%d:R> 🍀", boostAmount, endTime))
        return
    
    -- 🎲 Game egg detection
    elseif message:find("🎲") then
        local endTime = os.time() + 600
        SendWebhook(string.format("🎲 **Game Egg Timer Increased!** Ends <t:%d:R>", endTime))
        return
    end
end

-- Main chat monitoring
for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        if string.find(message, "@") then
            message = message:gsub("@", "(at)")
        end
        ProcessChatMessage(player, message)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if string.find(message, "@") then
            message = message:gsub("@", "(at)")
        end
        ProcessChatMessage(player, message)
    end)
end)

print("Chat logger activated! Watching for 🎉, 🍀, and 🎲 triggers")
