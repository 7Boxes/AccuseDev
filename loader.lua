local scripts = {
    "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/anticrash.lua",
    "https://raw.githubusercontent.com/IdiotHub/Scripts/main/BGSI/main.lua",
    "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/fps.lua"
}

wait(20)

for i, url in pairs(scripts) do
    pcall(function()
        loadstring(game:HttpGet(url))()
        print("✅ Loaded script "..i)
    end)
    
    if i < #scripts then
        wait(10)
    end
end
