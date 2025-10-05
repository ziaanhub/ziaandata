-- Load ZiaanUI melalui loadstring
local ZiaanUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/ZiaanUI/main/ZiaanUI.lua"))()

-- Contoh penggunaan
local hub = ZiaanUI.new({
    Name = "ZiaanUI Hub",
    Theme = "Dark",
    AccentColor = Color3.fromRGB(0, 255, 170),
    Size = UDim2.new(0, 550, 0, 450)
})

-- Tambahkan tab
local mainTab = hub:AddTab("Main")
local playerTab = hub:AddTab("Player")
local visualTab = hub:AddTab("Visual")

-- Tambahkan section
local combatSection = hub:AddSection(mainTab, "Combat")
local movementSection = hub:AddSection(mainTab, "Movement")
local playerSection = hub:AddSection(playerTab, "Player Settings")

-- Tambahkan elemen UI
hub:AddButton(combatSection, "Kill All", function()
    print("Kill All executed!")
end)

hub:AddToggle(combatSection, "Aimbot", false, function(value)
    print("Aimbot:", value)
end)

hub:AddSlider(combatSection, "Aimbot FOV", 1, 360, 90, function(value)
    print("Aimbot FOV:", value)
end)

hub:AddDropdown(combatSection, "Weapon", {"AK-47", "Shotgun", "Sniper", "Pistol"}, "AK-47", function(value)
    print("Selected weapon:", value)
end)

hub:AddKeybind(combatSection, "Toggle Menu", Enum.KeyCode.RightShift, function(key)
    hub:Toggle()
end)

hub:AddLabel(combatSection, "Combat Settings")

-- Toggle UI dengan keybind
hub:Show()
