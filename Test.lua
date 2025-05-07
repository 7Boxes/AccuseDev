--[[
=======================================================================
BUBBLE & EGG QUEST AUTOMATION SCRIPT
=======================================================================
Features:
- Auto-executes on script start
- Loops continuously checking for new quests
- Falls back to Infinity Egg when no quests found
- Maintains all original functionality
- Proper error handling
=======================================================================
--]]

--[[
=======================================================================
CONFIGURATION SECTION
=======================================================================
--]]

local Config = {
    EGG_QUANTITY = 4,                  -- How many eggs to hatch at once
    MAIN_LOOP_DELAY = 60,              -- Delay between full cycles (seconds)
    INFINITY_EGG_POSITION = Vector3.new(-104.86, 19.05, -27.06)  -- Infinity Egg location
}

--[[
=======================================================================
CORE FUNCTIONS SECTION
=======================================================================
--]]

local function SetupNetwork()
    local networkPath = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
                      :WaitForChild("Framework"):WaitForChild("Network")
                      :WaitForChild("Remote"):WaitForChild("Event")
    return networkPath
end

local function MoveToPosition(position, duration)
    duration = duration or 10
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(
        humanoidRootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    return true
end

--[[
=======================================================================
BUBBLE QUEST AUTOMATION
=======================================================================
--]]

local function RunBubbleQuests()
    local BUBBLE_TARGET_POSITION = Vector3.new(76.38, 9.20, -112.68)
    local CHECK_INTERVAL = 5
    local TWEEN_DURATION = 10
    local BUBBLE_RATE = 0.25

    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer.PlayerGui
    local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

    -- Network Setup
    local bubbleEvent = SetupNetwork()
    if not bubbleEvent then
        warn("Bubble network setup failed")
        return false
    end

    -- Quest Detection
    local function GetIncompleteBubbleQuests()
        local basePath = ScreenGui.Season.Frame.Content.Challenges
        local questTypes = {"Daily", "Hourly"}
        local bubbleQuests = {}
        
        for _, questType in ipairs(questTypes) do
            for i = 1, 3 do
                local questName = questType:lower().."-challenge-"..i
                local questList = basePath[questType].List
                if questList and questList[questName] then
                    local questPath = questList[questName].Content
                    if questPath and questPath.Label and questPath.Bar and questPath.Bar.Label then
                        local questText = questPath.Label.Text
                        local percentage = tonumber(questPath.Bar.Label.Text:match("%d+")) or 0
                        if percentage < 100 and questText:lower():find("bubble") then
                            table.insert(bubbleQuests, {
                                path = questPath,
                                text = questText,
                                type = questType,
                                index = i
                            })
                        end
                    end
                end
            end
        end
        return bubbleQuests
    end

    local bubbleQuests = GetIncompleteBubbleQuests()
    if #bubbleQuests == 0 then
        print("No incomplete bubble quests found")
        return false
    end

    print("Starting bubble quest automation...")
    MoveToPosition(BUBBLE_TARGET_POSITION)

    local bubbleCoroutine = coroutine.create(function()
        while true do
            local args = {"BlowBubble"}
            pcall(function() 
                bubbleEvent:FireServer(unpack(args)) 
            end)
            wait(BUBBLE_RATE)
        end
    end)
    coroutine.resume(bubbleCoroutine)

    -- Progress monitoring
    local startTime = os.time()
    while #GetIncompleteBubbleQuests() > 0 do
        local currentQuests = GetIncompleteBubbleQuests()
        for _, quest in ipairs(currentQuests) do
            local percentage = tonumber(quest.path.Bar.Label.Text:match("%d+")) or 0
            print("[Bubble] "..quest.text..": "..percentage.."%")
        end
        
        if os.time() - startTime > 120 then
            MoveToPosition(BUBBLE_TARGET_POSITION)
            startTime = os.time()
        end
        
        wait(CHECK_INTERVAL)
    end

    coroutine.close(bubbleCoroutine)
    print("Bubble quests completed!")
    return true
end

--[[
=======================================================================
EGG QUEST AUTOMATION
=======================================================================
--]]

local function RunEggQuests()
    local EGG_LOCATIONS = {
        ["Common"] = Vector3.new(-12.40, 15.66, -81.87),
        ["Spotted"] = Vector3.new(-12.63, 15.61, -70.52),
        ["Iceshard"] = Vector3.new(-12.57, 16.50, -59.62),
        ["Spikey"] = Vector3.new(-127.92, 16.25, 9.43),
        ["Magma"] = Vector3.new(-137.79, 15.58, 3.08),
        ["Crystal"] = Vector3.new(-144.64, 15.98, -5.11),
        ["Lunar"] = Vector3.new(-148.69, 15.88, -15.29),
        ["Void"] = Vector3.new(-149.83, 15.75, -26.63),
        ["Hell"] = Vector3.new(-149.49, 15.57, -36.71),
        ["Nightmare"] = Vector3.new(-146.16, 14.51, -47.57),
        ["Rainbow"] = Vector3.new(-139.45, 16.20, -55.40),
        ["Showman"] = Vector3.new(-130.84, 19.16, -63.48),
        ["Mining"] = Vector3.new(-121.83, 16.45, -67.70),
        ["Cyber"] = Vector3.new(-92.24, 16.11, -66.20),
        ["Infinity"] = Config.INFINITY_EGG_POSITION
    }
    
    local CHECK_INTERVAL = 5
    local TWEEN_DURATION = 10
    local HATCH_RATE = 0.5

    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer.PlayerGui
    local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

    -- Network Setup
    local hatchEvent = SetupNetwork()
    if not hatchEvent then
        warn("Egg network setup failed")
        return false
    end

    -- Quest Detection
    local function GetIncompleteEggQuests()
        local basePath = ScreenGui.Season.Frame.Content.Challenges
        local questTypes = {"Daily", "Hourly"}
        local eggQuests = {}
        
        for _, questType in ipairs(questTypes) do
            for i = 1, 3 do
                local questName = questType:lower().."-challenge-"..i
                local questList = basePath[questType].List
                if questList and questList[questName] then
                    local questPath = questList[questName].Content
                    if questPath and questPath.Label and questPath.Bar and questPath.Bar.Label then
                        local questText = questPath.Label.Text
                        local percentage = tonumber(questPath.Bar.Label.Text:match("%d+")) or 0
                        
                        if percentage < 100 and questText:lower():find("hatch") then
                            local eggType = "Common"
                            
                            for eggName in pairs(EGG_LOCATIONS) do
                                if questText:lower():find(eggName:lower()) then
                                    eggType = eggName
                                    break
                                end
                            end
                            
                            table.insert(eggQuests, {
                                path = questPath,
                                text = questText,
                                type = questType,
                                index = i,
                                eggName = eggType,
                                percentage = percentage
                            })
                        end
                    end
                end
            end
        end
        return eggQuests
    end

    local eggQuests = GetIncompleteEggQuests()
    
    -- Fallback to Infinity Egg if no quests found
    if #eggQuests == 0 then
        print("No egg quests found - defaulting to Infinity Egg")
        eggQuests = {
            {
                path = nil,
                text = "Infinity Egg (Default)",
                type = "Default",
                index = 0,
                eggName = "Infinity",
                percentage = 0
            }
        }
    end

    -- Process each egg quest
    for _, quest in ipairs(eggQuests) do
        local eggName = quest.eggName
        local targetPosition = EGG_LOCATIONS[eggName]
        
        if not targetPosition then
            warn("No position found for egg type: "..eggName)
            continue
        end

        print("Processing: "..quest.text)
        print("Egg type: "..eggName.." | Position: "..tostring(targetPosition))
        
        -- Move to position
        MoveToPosition(targetPosition)
        wait(TWEEN_DURATION)

        -- Start hatching coroutine
        local eggCoroutine = coroutine.create(function()
            while true do
                local args = {"HatchEgg", eggName.." Egg", Config.EGG_QUANTITY}
                pcall(function()
                    hatchEvent:FireServer(unpack(args))
                end)
                wait(HATCH_RATE)
            end
        end)
        coroutine.resume(eggCoroutine)

        -- Progress monitoring
        local startTime = os.time()
        local function ShouldContinue()
            if quest.type == "Default" then return true end -- Always continue Infinity Egg
            if not quest.path then return false end
            local percentage = tonumber(quest.path.Bar.Label.Text:match("%d+")) or 100
            return percentage < 100
        end

        while ShouldContinue() do
            if quest.path then
                local percentage = tonumber(quest.path.Bar.Label.Text:match("%d+")) or 0
                print(string.format("[%s] Progress: %d%%", eggName, percentage))
            else
                print(string.format("[%s] Hatching...", eggName))
            end
            
            -- Re-position periodically
            if os.time() - startTime > 120 then
                MoveToPosition(targetPosition)
                startTime = os.time()
            end
            
            wait(CHECK_INTERVAL)
        end

        coroutine.close(eggCoroutine)
        print("Completed: "..quest.text)
    end

    return true
end

--[[
=======================================================================
MAIN EXECUTION LOOP
=======================================================================
--]]

local function MainLoop()
    while true do
        print("\n=== Starting new quest cycle ===")
        
        -- Try bubble quests first
        if not RunBubbleQuests() then
            -- If no bubble quests, run egg quests (which includes Infinity fallback)
            RunEggQuests()
        else
            -- After bubbles, check for egg quests
            RunEggQuests()
        end
        
        print("=== Cycle completed ===")
        wait(Config.MAIN_LOOP_DELAY)
    end
end

-- Auto-execute
coroutine.wrap(function()
    wait(5) -- Initial delay to ensure game loads
    MainLoop()
end)()
