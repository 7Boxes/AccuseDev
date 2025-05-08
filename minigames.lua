-- Wait 14 seconds before starting
print("[DEBUG] Waiting 14 seconds before starting the loop...")
wait(14)

while true do
    -- Cart Escape Minigame
    print("[DEBUG] Starting Cart Escape minigame...")
    local startArgs = {
        "StartMinigame",
        "Cart Escape",
        "Insane"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared")
        :WaitForChild("Framework"):WaitForChild("Network")
        :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(startArgs))
    
    -- Wait a moment for the minigame to start
    wait(1)
    
    -- Finish Cart Escape
    print("[DEBUG] Finishing Cart Escape minigame...")
    local finishArgs = {
        "FinishMinigame"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared")
        :WaitForChild("Framework"):WaitForChild("Network")
        :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(finishArgs))
    
    -- 2 second delay
    print("[DEBUG] Waiting 2 seconds before next minigame...")
    wait(2)
    
    -- Pet Match Minigame
    print("[DEBUG] Starting Pet Match minigame...")
    local startArgs2 = {
        "StartMinigame",
        "Pet Match",
        "Insane"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared")
        :WaitForChild("Framework"):WaitForChild("Network")
        :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(startArgs2))
    
    -- Wait a moment for the minigame to start
    wait(1)
    
    -- Finish Pet Match
    print("[DEBUG] Finishing Pet Match minigame...")
    local finishArgs2 = {
        "FinishMinigame"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared")
        :WaitForChild("Framework"):WaitForChild("Network")
        :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(finishArgs2))
    
    -- 2 second delay before looping
    print("[DEBUG] Waiting 2 seconds before restarting loop...")
    wait(2)
end
