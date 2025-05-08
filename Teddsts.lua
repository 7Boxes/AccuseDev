local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local network = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")

-- Target position for initial tween
local targetPosition = Vector3.new(9828.36, 34.59, 171.16)

-- Improved tween function with error handling
local function tweenToPosition(position, duration)
    local success, err = pcall(function()
        local tweenInfo = TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
        tween:Play()
        tween.Completed:Wait()
    end)
    if not success then
        warn("Tween failed:", err)
    end
end

-- Enhanced remote call function
local function callRemote(remoteType, remoteName, args)
    local success, result = pcall(function()
        local remote = network:WaitForChild(remoteType, 5)
        if not remote then error("Remote not found") end
        if remoteType == "Function" then
            return remote:InvokeServer(unpack(args))
        else
            remote:FireServer(unpack(args))
            return true
        end
    end)
    if not success then
        warn("Remote call failed ["..remoteName.."]:", result)
        return false
    end
    return result
end

-- Optimized item finder with exact matching
local function getClawItems()
    local items = {}
    local success, gui = pcall(function()
        return localPlayer.PlayerGui:WaitForChild("ScreenGui", 2)
    end)
    
    if success and gui then
        for _, child in ipairs(gui:GetDescendants()) do
            if child:IsA("GuiObject") and string.find(child.Name, "^ClawItem") then
                table.insert(items, child.Name)
            end
        end
    else
        warn("ScreenGui not found")
    end
    return items
end

-- Ultimate collection function with zero-items verification
local function collectAllItems()
    local totalCollected = 0
    local safetyCounter = 0
    local maxAttempts = 30
    
    repeat
        local currentItems = getClawItems()
        if #currentItems > 0 then
            print("Found", #currentItems, "items remaining")
            
            -- Process all current items
            for _, itemId in ipairs(currentItems) do
                print("Attempting to grab:", itemId)
                if callRemote("Event", "GrabMinigameItem", {"GrabMinigameItem", itemId}) then
                    totalCollected = totalCollected + 1
                end
                wait(0.2) -- Precise delay between grabs
            end
            
            -- Allow game to update
            wait(0.5)
        end
        
        safetyCounter = safetyCounter + 1
        currentItems = getClawItems() -- Refresh item list
        
    until #currentItems == 0 or safetyCounter >= maxAttempts
    
    if #getClawItems() == 0 then
        print("✅ All items collected successfully! Total:", totalCollected)
        return true
    else
        warn("⚠️ Timeout reached with", #getClawItems(), "items remaining")
        return false
    end
end

-- Main automation sequence
local function runAutomation()
    -- Initial setup
    tweenToPosition(targetPosition, 1)
    wait(10)
    
    -- Background tasks
    local function runClaims()
        while true do
            for i = 1, 10 do
                callRemote("Function", "ClaimPlaytime", {"ClaimPlaytime", i})
                wait(1)
            end
        end
    end
    
    local function runEggs()
        while true do
            callRemote("Event", "HatchEgg", {"HatchEgg", "Game Egg", 4})
            wait(1.5)
        end
    end
    
    coroutine.wrap(runClaims)()
    coroutine.wrap(runEggs)()
    
    -- Main game loop
    while true do
        print("\n=== NEW MINIGAME CYCLE ===")
        
        -- Setup minigame
        callRemote("Event", "WorldTeleport", {"WorldTeleport", "Minigame Paradise"})
        wait(1.5)
        
        callRemote("Event", "SkipMinigameCooldown", {"SkipMinigameCooldown", "Robot Claw"})
        wait(1)
        
        callRemote("Event", "StartMinigame", {"StartMinigame", "Robot Claw", "Insane"})
        wait(1.5)
        
        -- Collect until empty
        collectAllItems()
        
        -- Finalize
        callRemote("Event", "FinishMinigame", {"FinishMinigame"})
        print("Cycle complete. Waiting 5 seconds...\n")
        wait(5)
    end
end

-- Character management
local function initCharacter(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    coroutine.wrap(runAutomation)()
end

localPlayer.CharacterAdded:Connect(initCharacter)

-- Initial execution
if character then
    coroutine.wrap(runAutomation)()
end
