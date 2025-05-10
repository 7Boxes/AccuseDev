-- Stealthy Movement and Platform Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChildOfClass("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIG SECTION
local config = {
    TargetPosition = Vector3.new(16.95, 16.27, -7.35),  -- Target coordinates
    RemoteValue = 4,                                    -- Remote value to send
    MovementSpeed = 0.8,                               -- Movement speed (0-1)
    PlatformName = "StealthPlatform",                  -- Platform identifier
    PlatformSize = Vector3.new(12, 1.2, 12),          -- Platform dimensions
    CheckInterval = 0.016                             -- Movement check interval
}

-- Stealth movement using physics manipulation
local function stealthMoveToPosition()
    local startPos = humanoidRootPart.Position
    local direction = (config.TargetPosition - startPos).Unit
    local distance = (config.TargetPosition - startPos).Magnitude
    local arrivalThreshold = 1.5  -- How close we need to get
    
    -- Enable movement states
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    humanoid.WalkSpeed = 0  -- We'll control movement manually
    
    -- Movement loop
    local connection
    connection = RunService.Heartbeat:Connect(function(delta)
        local currentPos = humanoidRootPart.Position
        local remainingDist = (config.TargetPosition - currentPos).Magnitude
        
        if remainingDist <= arrivalThreshold then
            connection:Disconnect()
            humanoid.WalkSpeed = 16  -- Restore normal speed
            return true
        end
        
        -- Calculate movement with slight randomness
        local moveDir = (config.TargetPosition - currentPos).Unit
        local randomizedDir = (moveDir + Vector3.new(
            (math.random() - 0.5) * 0.1,
            0,
            (math.random() - 0.5) * 0.1
        )).Unit
        
        -- Apply movement force with varying intensity
        local moveForce = randomizedDir * (humanoidRootPart.AssemblyMass * 50 * config.MovementSpeed)
        humanoidRootPart:ApplyImpulse(moveForce * delta * 60)
        
        -- Small upward force to prevent sticking to ground
        humanoidRootPart:ApplyImpulse(Vector3.new(0, humanoidRootPart.AssemblyMass * 2 * delta * 60, 0))
    end)
    
    return true
end

-- Remote execution with randomized delays
local function executeRemoteStealth()
    local remotePath = ReplicatedStorage
        :WaitForChild("Shared")
        :WaitForChild("Framework")
        :WaitForChild("Network")
        :WaitForChild("Remote")
        :WaitForChild("RemoteEvent")
    
    -- Randomize execution timing
    task.wait(math.random() * 0.5 + 0.3)
    
    -- Fire with slight value variation to appear natural
    local actualValue = config.RemoteValue + (math.random() - 0.5) * 0.1
    remotePath:FireServer(actualValue)
    
    return true
end

-- Platform creation using existing parts as disguise
local function createStealthPlatform()
    -- Find existing baseplate to clone properties from
    local baseplate = workspace:FindFirstChild("Baseplate") or workspace:FindFirstChildWhichIsA("BasePart")
    
    -- Create disguised platform
    local platform = Instance.new("Part")
    platform.Name = config.PlatformName
    platform.Size = config.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.85
    platform.Color = Color3.fromRGB(80, 80, 80)
    platform.Material = Enum.Material.Concrete
    
    -- Copy properties from existing part if available
    if baseplate then
        platform.Transparency = baseplate.Transparency
        platform.Color = baseplate.Color
        platform.Material = baseplate.Material
    end
    
    -- Position platform exactly where needed
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hipHeight = humanoid and humanoid.HipHeight or 2
    local platformYOffset = (character:GetExtentsSize().Y/2) - hipHeight - (platform.Size.Y/2)
    
    platform.Position = humanoidRootPart.Position - Vector3.new(0, platformYOffset, 0)
    platform.CFrame = CFrame.new(platform.Position)
    
    -- Disguise the platform as terrain
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        platform.Name = "Terrain_" .. tostring(math.random(10000,99999))
    end
    
    -- Add touch functionality with randomized delays
    local touchScript = Instance.new("Script", platform)
    touchScript.Name = "TouchScript"
    
    touchScript.Source = [[
        local Debounce = false
        local Cooldown = math.random(3, 8)  -- Random cooldown
        
        script.Parent.Touched:Connect(function(hit)
            local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid and not Debounce then
                Debounce = true
                
                -- Random delay before execution
                task.wait(math.random() * 0.5)
                
                local remotePath = game:GetService("ReplicatedStorage")
                    :WaitForChild("Shared")
                    :WaitForChild("Framework")
                    :WaitForChild("Network")
                    :WaitForChild("Remote")
                    :WaitForChild("RemoteEvent")
                
                -- Fire with slight variation
                remotePath:FireServer(]] .. config.RemoteValue .. [[ + (math.random() - 0.5) * 0.1)
                
                Debounce = false
                task.wait(Cooldown)
            end
        end)
    ]]
    
    platform.Parent = workspace
    return true
end

-- Main execution with randomized timing
task.spawn(function()
    -- Initial delay
    task.wait(math.random(1, 3))
    
    -- Movement phase
    if stealthMoveToPosition() then
        print("Stealth movement completed")
    else
        warn("Movement interrupted")
        return
    end
    
    -- Random wait before platform creation
    task.wait(math.random() * 1.5 + 0.5)
    
    -- Platform creation
    if createStealthPlatform() then
        print("Stealth platform deployed")
    else
        warn("Platform creation failed")
    end
    
    -- Random wait before remote execution
    task.wait(math.random() * 2 + 1)
    
    -- Remote execution
    if executeRemoteStealth() then
        print("Remote executed stealthily")
    else
        warn("Remote execution failed")
    end
end)

-- Cleanup with disguise
game:GetService("UserInputService").WindowFocused:Connect(function(focused)
    if not focused then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == config.PlatformName or string.find(obj.Name, "Terrain_") then
                obj:Destroy()
            end
        end
    end
end)
