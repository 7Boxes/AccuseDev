local scripts = {
    "https://raw.githubusercontent.com/IdiotHub/Scripts/main/BGSI/main.lua",
    "https://getmoonx.cc/script",
    "https://raw.githubusercontent.com/7Boxes/AccuseDev/refs/heads/main/fps.lua"
}

for i, url in pairs(scripts) do
    pcall(function()
        loadstring(game:HttpGet(url))()
        print("✅ Loaded script "..i)
    end)
    wait(0.5)
end
