local UIHub = require(path.to.UIHub)

-- Membuat UI Hub baru
local hub = UIHub.new({
	Name = "My UI Hub",
	Theme = "Dark",
	AccentColor = Color3.fromRGB(0, 255, 170),
	Size = UDim2.new(0, 550, 0, 450)
})

-- Menambahkan tab
local mainTab = hub:AddTab("Main")
local settingsTab = hub:AddTab("Settings")

-- Menambahkan section ke tab
local combatSection = hub:AddSection(mainTab, "Combat")
local movementSection = hub:AddSection(mainTab, "Movement")
local visualSection = hub:AddSection(mainTab, "Visual")

-- Menambahkan elemen ke section
hub:AddButton(combatSection, "Kill All", function()
	print("Kill All clicked!")
end)

hub:AddToggle(combatSection, "Aimbot", false, function(value)
	print("Aimbot:", value)
end)

hub:AddSlider(combatSection, "Aimbot FOV", 1, 360, 90, function(value)
	print("Aimbot FOV:", value)
end)

hub:AddDropdown(combatSection, "Weapon", {"AK-47", "Shotgun", "Sniper"}, "AK-47", function(value)
	print("Selected weapon:", value)
end)

hub:AddKeybind(combatSection, "Toggle Menu", Enum.KeyCode.RightShift, function(key)
	hub:Toggle()
end)

hub:AddLabel(combatSection, "Combat Settings")

-- Tampilkan UI
-- hub:Toggle() -- Bisa dipanggil untuk toggle visibility
