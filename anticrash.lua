function AntiCrash()
function Part1()
game:GetService("RunService").RenderStepped:connect(function() 
    table.foreach(user.Backpack:GetChildren(),function(a,b) if b.Name == "-" then game.StarterGui:SetCore('SendNotification', {Title='AntiCrash'; Text='Hey '..name..'! Someone tried to crash you!'}) end end)
end)
end
function nou()
    aa=Instance.new("Model",workspace);a.Name=name
    Instance.new("Humanoid",aa)
    b=Instance.new("Part",aa);b.Name="Torso";b.CanCollide=false;b.Transparency=1
    user.Character=aa
end
function aaa()
game:GetService("RunService").RenderStepped:connect(function() 
    table.foreach(user.Backpack:GetChildren(),function(a,b) if b.Name == "-" then nou() end end)
end)
end
game:GetService("RunService").RenderStepped:connect(function() 
    table.foreach(user.Backpack:GetChildren(),function(a,b) if b.Name == "-" then user.Backpack:ClearAllChildren() end end)
end)
Part1()
aaa()
game.StarterGui:SetCore('SendNotification', {Title='AntiCrash'; Text='Hey '..name..'! AntiCrash ran successfully'})
a.Text = "(Might not work) Anti Crash loaded"
end
