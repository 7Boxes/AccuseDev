-- === CONFIG: Set your webhook URLs ===
local STATS_WEBHOOK = "https://discord.com/api/webhooks/1364280354902638666/7axHSb4BpwR8edpGn0YBQ_Yfii1BABokyimxu16CUVOLVUYady9-yZakVChHNsBLht7o"
local HATCH_WEBHOOK = "https://discord.com/api/webhooks/1364280968550023188/FSj2PuWDXYdh88GHJYDc1Sbo72oaTAMB5utsOrcgkJQFFkgAXCArM0zlJOzLTRW3HjiI"

-- === UTILS ===
function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = { ["Content-Type"] = "application/json" }
    local data = { ["content"] = message }
    local body = http:JSONEncode(data)
    request({ Url = url, Method = "POST", Headers = headers, Body = body })
    print("Sent")
end

function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = { ["Content-Type"] = "application/json" }
    local data = {
        ["embeds"] = {{
            ["title"] = embed.title,
            ["description"] = embed.description,
            ["color"] = embed.color,
            ["fields"] = embed.fields,
            ["footer"] = { ["text"] = embed.footer.text }
        }}
    }
    local body = http:JSONEncode(data)
    request({ Url = url, Method = "POST", Headers = headers, Body = body })
    print("Sent")
end

-- === LOCATION FINDER ===
function getCurrentLocation()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local closestIslandPart = nil
    local minDistance = math.huge
    local currentWorld = nil
    local islandName = "Unknown"

    for _, world in ipairs(workspace.Worlds:GetChildren()) do
        if world:IsA("Folder") then
            for _, islandFolder in ipairs(world:IsDescendants()) do
                if islandFolder:IsA("Part") and islandFolder.Name == "Island" then
                    local dist = (islandFolder.Position - root.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestIslandPart = islandFolder
                        currentWorld = world.Name
                    end
                end
            end
        end
    end

    if closestIslandPart then
        islandName = closestIslandPart.Parent and closestIslandPart.Parent.Name or "Unknown"
    end

    return currentWorld or "Unknown", islandName
end

-- === FUNCTION: Send Player Stats ===
function sendPlayerStats()
    local plr = game.Players.LocalPlayer
    local stats = plr:FindFirstChild("leaderstats") or plr:FindFirstChild("Stats") or plr:FindFirstChild("PlayerStats")
    if not stats then return end

    local world, island = getCurrentLocation()

    local fields = {
        { name = "World", value = world, inline = true },
        { name = "Island", value = island, inline = true }
    }

    for _, stat in ipairs(stats:GetChildren()) do
        table.insert(fields, {
            name = stat.Name,
            value = tostring(stat.Value),
            inline = true
        })
    end

    local embed = {
        title = "Player Stats",
        description = "Stats for **" .. plr.Name .. "**",
        color = 5814783,
        fields = fields,
        footer = { text = "Stat Report" }
    }

    SendMessageEMBED(STATS_WEBHOOK, embed)
end

-- === FUNCTION: Hook Hatch Events ===
function hookHatchEvents()
    local mod = require(game:GetService("ReplicatedStorage"):WaitForChild("PetModules"):WaitForChild("PetData"))
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if tostring(method) == "FireServer" and tostring(self) == "HatchPet" then
            local petName = args[1]
            local eggName = args[2] or "Unknown Egg"
            local petData = mod[petName]

            if petData and petData.Rarity then
                local rarity = petData.Rarity
                local raritiesToLog = { ["Legendary"] = true, ["Mythic"] = true, ["Secret"] = true }

                if raritiesToLog[rarity] then
                    local plr = game.Players.LocalPlayer
                    local msg = "**" .. plr.Name .. "** hatched a **" .. rarity .. "** pet: **" .. petName .. "** from **" .. eggName .. "**!"
                    SendMessage(HATCH_WEBHOOK, msg)
                end
            end
        end

        return old(self, unpack(args))
    end)
end

-- === INIT ===
sendPlayerStats()
hookHatchEvents()
