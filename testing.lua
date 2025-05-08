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

-- Function to get all claw item IDs from ScreenGui
local function getClawItemIds()
    local clawItems = {}
    local screenGui = localPlayer.PlayerGui:WaitForChild("ScreenGui")
    
    for _, child in pairs(screenGui:GetDescendants()) do
        if child.Name:find("ClawItem") then
            local itemId = child.Name:gsub("ClawItem", "")
            table.insert(clawItems, itemId)
        end
    end
    
    return clawItems
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

-- Function to collect all items with proper delays
local function collectAllItems()
    local clawItems = getClawItemIds()
    
    -- Collect each item with 0.5 second delay
    for _, itemId in pairs(clawItems) do
        callRemote("Event", "GrabMinigameItem", {"GrabMinigameItem", itemId})
        wait(0.5)
    end
    
    -- Additional 0.5 second delay after last item
    wait(0.5)
end

-- Main execution function
local function executeAutomation()
    -- Initial tween
    tweenToPosition(targetPosition, 1)
    wait(10)
    
    -- Start continuous claim playtime in a separate thread
    coroutine.wrap(function()
        while true do
            for i = 1, 10 do
                callRemote("Function", "ClaimPlaytime", {"ClaimPlaytime", i})
                wait(1)
            end
        end
    end)()
    
    -- Start continuous egg hatching in a separate thread
    coroutine.wrap(function()
        while true do
            callRemote("Event", "HatchEgg", {"HatchEgg", "Game Egg", 4})
            wait(1)
        end
    end)()
    
    -- Main minigame loop
    while true do
        -- Step 1: World Teleport
        callRemote("Event", "WorldTeleport", {"WorldTeleport", "Minigame Paradise"})
        wait(1)
        
        -- Step 2: Skip Cooldown
        callRemote("Event", "SkipMinigameCooldown", {"SkipMinigameCooldown", "Robot Claw"})
        wait(1)
        
        -- Step 3: Start Minigame
        callRemote("Event", "StartMinigame", {"StartMinigame", "Robot Claw", "Insane"})
        wait(1)
        
        -- Step 4: Grab all items with proper timing
        collectAllItems()
        
        -- Step 5: Finish Minigame (only after all items collected)
        callRemote("Event", "FinishMinigame", {"FinishMinigame"})
        
        -- Wait before next iteration
        wait(5)
    end
end

-- Character handling to ensure script works after respawn
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    executeAutomation()
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Start the automation
if character then
    executeAutomation()
end
