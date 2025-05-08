local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local network = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")

-- Target position for initial tween
local targetPosition = Vector3.new(9828.36, 34.59, 171.16)

-- Function to tween character to position
local function tweenToPosition(position, duration)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

-- Function to execute remote calls with error handling
local function callRemote(remoteType, remoteName, args)
    local success, result = pcall(function()
        local remote = network:WaitForChild(remoteType)
        if remoteType == "Function" then
            return remote:InvokeServer(unpack(args))
        else
            remote:FireServer(unpack(args))
            return true
        end
    end)
    
    if not success then
        warn("Failed to call", remoteName, ":", result)
        return false
    end
    return result
end

-- Function to find all current claw items
local function getCurrentClawItems()
    local clawItems = {}
    local success, screenGui = pcall(function()
        return localPlayer.PlayerGui:WaitForChild("ScreenGui", 5)
    end)
    
    if success and screenGui then
        for _, child in pairs(screenGui:GetDescendants()) do
            if child.Name:sub(1, 8) == "ClawItem" then
                table.insert(clawItems, child.Name)
            end
        end
    end
    return clawItems
end

-- Function to collect all available items with dynamic checking
local function collectAllItems()
    local attempts = 0
    local maxAttempts = 20  -- Prevent infinite loops
    local itemsCollected = 0
    
    repeat
        local clawItems = getCurrentClawItems()
        if #clawItems > 0 then
            print("Found", #clawItems, "items to collect")
            
            for _, itemId in ipairs(clawItems) do
                print("Grabbing:", itemId)
                callRemote("Event", "GrabMinigameItem", {"GrabMinigameItem", itemId})
                itemsCollected = itemsCollected + 1
                wait(0.2)  -- Delay between grabs
            end
            
            -- Short delay before checking again
            wait(0.5)
        else
            break
        end
        
        attempts = attempts + 1
    until #getCurrentClawItems() == 0 or attempts >= maxAttempts
    
    print("Collection complete. Total items grabbed:", itemsCollected)
    return itemsCollected > 0
end

-- Main execution function
local function executeAutomation()
    -- Initial tween
    tweenToPosition(targetPosition, 1)
    wait(10)
    
    -- Background tasks
    coroutine.wrap(function()
        while true do
            -- Claim playtime
            for i = 1, 10 do
                callRemote("Function", "ClaimPlaytime", {"ClaimPlaytime", i})
                wait(1)
            end
        end
    end)()
    
    coroutine.wrap(function()
        while true do
            -- Hatch eggs
            callRemote("Event", "HatchEgg", {"HatchEgg", "Game Egg", 4})
            wait(1)
        end
    end)()
    
    -- Main minigame loop
    while true do
        -- Setup minigame
        callRemote("Event", "WorldTeleport", {"WorldTeleport", "Minigame Paradise"})
        wait(1)
        
        callRemote("Event", "SkipMinigameCooldown", {"SkipMinigameCooldown", "Robot Claw"})
        wait(1)
        
        callRemote("Event", "StartMinigame", {"StartMinigame", "Robot Claw", "Insane"})
        wait(1)
        
        -- Collect items until none remain
        collectAllItems()
        
        -- Finish minigame
        callRemote("Event", "FinishMinigame", {"FinishMinigame"})
        wait(5)  -- Cooldown between cycles
    end
end

-- Initialize
localPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    executeAutomation()
end)

if character then
    executeAutomation()
end
