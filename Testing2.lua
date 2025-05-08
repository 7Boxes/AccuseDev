local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network")
local RemoteFunction = Network:WaitForChild("Remote"):WaitForChild("Function")
local RemoteEvent = Network:WaitForChild("Remote"):WaitForChild("Event")

local diceTypes = {
    "Dice",
    "Giant Dice",
    "Golden Dice"
}

local function rollDice(diceType)
    local args = {
        "RollDice",
        diceType
    }
    print(`[Rolling] {diceType}...`)
    RemoteFunction:InvokeServer(unpack(args))
end

local function claimTile()
    local args = { "ClaimTile" }
    print("[Claiming] Tile...")
    RemoteEvent:FireServer(unpack(args))
end

while true do
    for _, diceType in ipairs(diceTypes) do
        rollDice(diceType) -- Roll dice
        wait(5) -- Wait 5 seconds
        claimTile() -- Claim tile
        wait(5) -- Wait 5 seconds before next dice
        print(`[Cycle] Moving to next dice...`)
    end
    print("[Cycle] Restarting sequence...")
end
