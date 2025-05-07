local scripts = {
    "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/anticrash.lua",
    "https://raw.githubusercontent.com/IdiotHub/Scripts/main/BGSI/main.lua",
    "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/fps.lua"
}

-- Only add hatches.lua if the player is jamexalt
if game:GetService("Players").LocalPlayer.Name == "jamexalt" then
    table.insert(scripts, "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/hatches.lua")
    print("✅ Added hatches.lua (jamexalt only)")
end

wait(0.1)

for i, url in pairs(scripts) do
    pcall(function()
        loadstring(game:HttpGet(url))()
        print("✅ Loaded script "..i)
    end)
    
    if i < #scripts then
        wait(2)
    end
end
