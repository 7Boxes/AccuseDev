-- Configuration
local TARGET_ASSET_ID = "rbxassetid://123761193316432"
local CHECK_INTERVAL = 1 -- seconds between checks
local CLAIM_DELAY = 1 -- seconds after roll before claiming
local NEXT_ROLL_DELAY = 0.5 -- seconds after claim before next roll

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get remotes (using exact paths from your images)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Framework = Shared:WaitForChild("Framework")
local Network = Framework:WaitForChild("Network")
local Remote = Network:WaitForChild("Remote")
local RemoteFunction = Remote:WaitForChild("RemoteFunction")
local RemoteEvent = Remote:WaitForChild("RemoteEvent")

-- Check for target image
local function isTargetVisible()
    local success, result = pcall(function()
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local screenGui = playerGui:WaitForChild("ScreenGui")
        local boardHUD = screenGui:WaitForChild("BoardHUD")
        local upcoming = boardHUD:WaitForChild("Upcoming")
        local content = upcoming:WaitForChild("Content")
        
        for _, descendant in ipairs(content:GetDescendants()) do
            if (descendant:IsA("ImageLabel") or descendant:IsA("ImageButton")) then
                if tostring(descendant.Image) == TARGET_ASSET_ID then
                    return true
                end
            end
        end
        return false
    end)
    
    if not success then
        warn("Image check error:", result)
        return false
    end
    
    return result
end

-- Dice rolling function
local function rollDice(diceType)
    local args = {
        "RollDice",
        diceType
    }
    print("[Rolling] "..diceType.."...")
    RemoteFunction:InvokeServer(unpack(args))
end

-- Tile claiming function (modified to include dice type)
local function claimTile(diceType)
    local args = {
        "ClaimTile",
        diceType  -- Added dice type parameter
    }
    print("[Claiming] Tile for "..diceType.."...")
    RemoteEvent:FireServer(unpack(args))
end

-- Main loop
local function main()
    print("=== Starting Dice Controller ===")
    
    while true do
        local targetFound = isTargetVisible()
        local diceType
        
        if targetFound then
            diceType = "Golden Dice"
            print("Targeting Egg Island...")
        else
            diceType = math.random() > 0.5 and "Giant Dice" or "Dice"
            print("DICE TYPE Used (1x) - "..diceType)
        end
        
        rollDice(diceType)
        wait(CLAIM_DELAY)
        claimTile(diceType)  -- Pass diceType to claim function
        wait(NEXT_ROLL_DELAY)
    end
end

-- Start the script
main()
