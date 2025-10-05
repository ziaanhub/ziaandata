-- UI Hub Library
-- Author: [Your Name]
-- Version: 1.0

local UIHub = {}
UIHub.__index = UIHub

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Default Configuration
UIHub.Config = {
	Theme = "Dark",
	AccentColor = Color3.fromRGB(0, 170, 255),
	Font = Enum.Font.Gotham,
	AnimationSpeed = 0.2,
	Rounding = 8,
	BlurBackground = true
}

-- Themes
UIHub.Themes = {
	Dark = {
		Background = Color3.fromRGB(30, 30, 40),
		Topbar = Color3.fromRGB(25, 25, 35),
		Section = Color3.fromRGB(40, 40, 50),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(180, 180, 180),
		Border = Color3.fromRGB(60, 60, 70)
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 245),
		Topbar = Color3.fromRGB(225, 225, 230),
		Section = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(30, 30, 30),
		SubText = Color3.fromRGB(100, 100, 100),
		Border = Color3.fromRGB(220, 220, 225)
	}
}

-- Create new UI Hub
function UIHub.new(options)
	options = options or {}
	
	local self = setmetatable({}, UIHub)
	
	self.Config = {
		Theme = options.Theme or UIHub.Config.Theme,
		AccentColor = options.AccentColor or UIHub.Config.AccentColor,
		Font = options.Font or UIHub.Config.Font,
		AnimationSpeed = options.AnimationSpeed or UIHub.Config.AnimationSpeed,
		Rounding = options.Rounding or UIHub.Config.Rounding,
		BlurBackground = options.BlurBackground or UIHub.Config.BlurBackground,
		Name = options.Name or "UI Hub",
		Size = options.Size or UDim2.new(0, 500, 0, 400),
		Position = options.Position or UDim2.new(0.5, -250, 0.5, -200)
	}
	
	self.Elements = {}
	self.Tabs = {}
	self.ActiveTab = nil
	
	self:CreateUI()
	
	return self
end

-- Create main UI
function UIHub:CreateUI()
	-- ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = self.Config.Name
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	
	-- Background Blur (optional)
	if self.Config.BlurBackground then
		self.Blur = Instance.new("BlurEffect")
		self.Blur.Size = 10
		self.Blur.Parent = game:GetService("Lighting")
	end
	
	-- Main Frame
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = self.Config.Size
	self.MainFrame.Position = self.Config.Position
	self.MainFrame.BackgroundColor3 = self.Themes[self.Config.Theme].Background
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.ClipsDescendants = true
	
	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, self.Config.Rounding)
	corner.Parent = self.MainFrame
	
	-- Drop Shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 12, 1, 12)
	shadow.Position = UDim2.new(0, -6, 0, -6)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Parent = self.MainFrame
	
	-- Top Bar
	self.TopBar = Instance.new("Frame")
	self.TopBar.Name = "TopBar"
	self.TopBar.Size = UDim2.new(1, 0, 0, 40)
	self.TopBar.Position = UDim2.new(0, 0, 0, 0)
	self.TopBar.BackgroundColor3 = self.Themes[self.Config.Theme].Topbar
	self.TopBar.BorderSizePixel = 0
	self.TopBar.Parent = self.MainFrame
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, self.Config.Rounding)
	topBarCorner.Parent = self.TopBar
	
	-- Title
	self.Title = Instance.new("TextLabel")
	self.Title.Name = "Title"
	self.Title.Size = UDim2.new(0, 200, 1, 0)
	self.Title.Position = UDim2.new(0, 15, 0, 0)
	self.Title.BackgroundTransparency = 1
	self.Title.Text = self.Config.Name
	self.Title.TextColor3 = self.Themes[self.Config.Theme].Text
	self.Title.TextSize = 18
	self.Title.Font = self.Config.Font
	self.Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Title.Parent = self.TopBar
	
	-- Close Button
	self.CloseButton = Instance.new("TextButton")
	self.CloseButton.Name = "CloseButton"
	self.CloseButton.Size = UDim2.new(0, 40, 1, 0)
	self.CloseButton.Position = UDim2.new(1, -40, 0, 0)
	self.CloseButton.BackgroundTransparency = 1
	self.CloseButton.Text = "X"
	self.CloseButton.TextColor3 = self.Themes[self.Config.Theme].Text
	self.CloseButton.TextSize = 18
	self.CloseButton.Font = self.Config.Font
	self.CloseButton.Parent = self.TopBar
	
	self.CloseButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	-- Tabs Container
	self.TabsContainer = Instance.new("Frame")
	self.TabsContainer.Name = "TabsContainer"
	self.TabsContainer.Size = UDim2.new(0, 120, 1, -40)
	self.TabsContainer.Position = UDim2.new(0, 0, 0, 40)
	self.TabsContainer.BackgroundColor3 = self.Themes[self.Config.Theme].Topbar
	self.TabsContainer.BorderSizePixel = 0
	self.TabsContainer.Parent = self.MainFrame
	
	-- Content Container
	self.ContentContainer = Instance.new("Frame")
	self.ContentContainer.Name = "ContentContainer"
	self.ContentContainer.Size = UDim2.new(1, -120, 1, -40)
	self.ContentContainer.Position = UDim2.new(0, 120, 0, 40)
	self.ContentContainer.BackgroundColor3 = self.Themes[self.Config.Theme].Background
	self.ContentContainer.BorderSizePixel = 0
	self.ContentContainer.Parent = self.MainFrame
	
	-- Make draggable
	self:Draggable(self.TopBar)
	
	self.MainFrame.Parent = self.ScreenGui
end

-- Make frame draggable
function UIHub:Draggable(frame)
	local dragging = false
	local dragInput, mousePos, framePos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = self.MainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			self.MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
end

-- Toggle UI visibility
function UIHub:Toggle()
	if self.MainFrame.Visible then
		self.MainFrame.Visible = false
		if self.Blur then
			self.Blur.Enabled = false
		end
	else
		self.MainFrame.Visible = true
		if self.Blur then
			self.Blur.Enabled = true
		end
	end
end

-- Add tab
function UIHub:AddTab(name, icon)
	local tab = {}
	tab.Name = name
	tab.Icon = icon
	
	-- Tab Button
	tab.Button = Instance.new("TextButton")
	tab.Button.Name = name .. "Tab"
	tab.Button.Size = UDim2.new(1, 0, 0, 40)
	tab.Button.Position = UDim2.new(0, 0, 0, (#self.Tabs * 40))
	tab.Button.BackgroundTransparency = 1
	tab.Button.Text = "  " .. name
	tab.Button.TextColor3 = self.Themes[self.Config.Theme].SubText
	tab.Button.TextSize = 14
	tab.Button.Font = self.Config.Font
	tab.Button.TextXAlignment = Enum.TextXAlignment.Left
	tab.Button.Parent = self.TabsContainer
	
	-- Tab Content
	tab.Content = Instance.new("ScrollingFrame")
	tab.Content.Name = name .. "Content"
	tab.Content.Size = UDim2.new(1, 0, 1, 0)
	tab.Content.Position = UDim2.new(0, 0, 0, 0)
	tab.Content.BackgroundTransparency = 1
	tab.Content.BorderSizePixel = 0
	tab.Content.ScrollBarThickness = 3
	tab.Content.ScrollBarImageColor3 = self.Themes[self.Config.Theme].Border
	tab.Content.Visible = false
	tab.Content.Parent = self.ContentContainer
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 10)
	uiListLayout.Parent = tab.Content
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingTop = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = tab.Content
	
	-- Tab button click event
	tab.Button.MouseButton1Click:Connect(function()
		self:SwitchTab(tab)
	end)
	
	table.insert(self.Tabs, tab)
	
	-- Set as active if first tab
	if #self.Tabs == 1 then
		self:SwitchTab(tab)
	end
	
	return tab
end

-- Switch to tab
function UIHub:SwitchTab(tab)
	if self.ActiveTab then
		self.ActiveTab.Button.TextColor3 = self.Themes[self.Config.Theme].SubText
		self.ActiveTab.Content.Visible = false
	end
	
	tab.Button.TextColor3 = self.Config.AccentColor
	tab.Content.Visible = true
	self.ActiveTab = tab
end

-- Add section to tab
function UIHub:AddSection(tab, name)
	local section = {}
	section.Name = name
	
	-- Section Frame
	section.Frame = Instance.new("Frame")
	section.Frame.Name = name .. "Section"
	section.Frame.Size = UDim2.new(1, 0, 0, 0) -- Height will be auto
	section.Frame.BackgroundColor3 = self.Themes[self.Config.Theme].Section
	section.Frame.BorderSizePixel = 0
	section.Frame.Parent = tab.Content
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, self.Config.Rounding - 2)
	corner.Parent = section.Frame
	
	-- Section Title
	section.Title = Instance.new("TextLabel")
	section.Title.Name = "Title"
	section.Title.Size = UDim2.new(1, -20, 0, 30)
	section.Title.Position = UDim2.new(0, 10, 0, 0)
	section.Title.BackgroundTransparency = 1
	section.Title.Text = name
	section.Title.TextColor3 = self.Themes[self.Config.Theme].Text
	section.Title.TextSize = 16
	section.Title.Font = self.Config.Font
	section.Title.TextXAlignment = Enum.TextXAlignment.Left
	section.Title.Parent = section.Frame
	
	-- Elements Container
	section.Container = Instance.new("Frame")
	section.Container.Name = "Container"
	section.Container.Size = UDim2.new(1, 0, 1, -30)
	section.Container.Position = UDim2.new(0, 0, 0, 30)
	section.Container.BackgroundTransparency = 1
	section.Container.BorderSizePixel = 0
	section.Container.Parent = section.Frame
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.Parent = section.Container
	
	section.Elements = {}
	
	-- Function to update section size
	local function updateSize()
		local totalHeight = 30 -- Title height
		for _, element in pairs(section.Elements) do
			totalHeight += element.Height + 5 -- Element height + padding
		end
		section.Frame.Size = UDim2.new(1, 0, 0, totalHeight)
	end
	
	section.updateSize = updateSize
	
	return section
end

-- Add button to section
function UIHub:AddButton(section, text, callback)
	local button = {}
	button.Text = text
	button.Callback = callback
	button.Height = 35
	
	-- Button Frame
	button.Frame = Instance.new("TextButton")
	button.Frame.Name = text .. "Button"
	button.Frame.Size = UDim2.new(1, 0, 0, button.Height)
	button.Frame.BackgroundColor3 = self.Themes[self.Config.Theme].Border
	button.Frame.BorderSizePixel = 0
	button.Frame.Text = ""
	button.Frame.AutoButtonColor = false
	button.Frame.Parent = section.Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, self.Config.Rounding - 4)
	corner.Parent = button.Frame
	
	-- Button Label
	button.Label = Instance.new("TextLabel")
	button.Label.Name = "Label"
	button.Label.Size = UDim2.new(1, 0, 1, 0)
	button.Label.Position = UDim2.new(0, 0, 0, 0)
	button.Label.BackgroundTransparency = 1
	button.Label.Text = text
	button.Label.TextColor3 = self.Themes[self.Config.Theme].Text
	button.Label.TextSize = 14
	button.Label.Font = self.Config.Font
	button.Label.Parent = button.Frame
	
	-- Hover effect
	button.Frame.MouseEnter:Connect(function()
		TweenService:Create(button.Frame, TweenInfo.new(0.2), {
			BackgroundColor3 = self.Config.AccentColor
		}):Play()
		TweenService:Create(button.Label, TweenInfo.new(0.2), {
			TextColor3 = Color3.new(1, 1, 1)
		}):Play()
	end)
	
	button.Frame.MouseLeave:Connect(function()
		TweenService:Create(button.Frame, TweenInfo.new(0.2), {
			BackgroundColor3 = self.Themes[self.Config.Theme].Border
		}):Play()
		TweenService:Create(button.Label, TweenInfo.new(0.2), {
			TextColor3 = self.Themes[self.Config.Theme].Text
		}):Play()
	end)
	
	-- Click event
	button.Frame.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
	
	table.insert(section.Elements, button)
	section.updateSize()
	
	return button
end

-- Add toggle to section
function UIHub:AddToggle(section, text, default, callback)
	local toggle = {}
	toggle.Text = text
	toggle.Value = default or false
	toggle.Callback = callback
	toggle.Height = 30
	
	-- Toggle Frame
	toggle.Frame = Instance.new("Frame")
	toggle.Frame.Name = text .. "Toggle"
	toggle.Frame.Size = UDim2.new(1, 0, 0, toggle.Height)
	toggle.Frame.BackgroundTransparency = 1
	toggle.Frame.BorderSizePixel = 0
	toggle.Frame.Parent = section.Container
	
	-- Toggle Label
	toggle.Label = Instance.new("TextLabel")
	toggle.Label.Name = "Label"
	toggle.Label.Size = UDim2.new(0.7, 0, 1, 0)
	toggle.Label.Position = UDim2.new(0, 0, 0, 0)
	toggle.Label.BackgroundTransparency = 1
	toggle.Label.Text = text
	toggle.Label.TextColor3 = self.Themes[self.Config.Theme].Text
	toggle.Label.TextSize = 14
	toggle.Label.Font = self.Config.Font
	toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
	toggle.Label.Parent = toggle.Frame
	
	-- Toggle Button
	toggle.Button = Instance.new("TextButton")
	toggle.Button.Name = "ToggleButton"
	toggle.Button.Size = UDim2.new(0, 40, 0, 20)
	toggle.Button.Position = UDim2.new(1, -40, 0.5, -10)
	toggle.Button.BackgroundColor3 = self.Themes[self.Config.Theme].Border
	toggle.Button.BorderSizePixel = 0
	toggle.Button.Text = ""
	toggle.Button.AutoButtonColor = false
	toggle.Button.Parent = toggle.Frame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toggle.Button
	
	-- Toggle Indicator
	toggle.Indicator = Instance.new("Frame")
	toggle.Indicator.Name = "Indicator"
	toggle.Indicator.Size = UDim2.new(0, 16, 0, 16)
	toggle.Indicator.Position = UDim2.new(0, 2, 0.5, -8)
	toggle.Indicator.BackgroundColor3 = self.Themes[self.Config.Theme].Background
	toggle.Indicator.BorderSizePixel = 0
	toggle.Indicator.Parent = toggle.Button
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 8)
	indicatorCorner.Parent = toggle.Indicator
	
	-- Set initial state
	toggle:SetValue(toggle.Value)
	
	-- Toggle click event
	toggle.Button.MouseButton1Click:Connect(function()
		toggle:SetValue(not toggle.Value)
		if callback then
			callback(toggle.Value)
		end
	end)
	
	table.insert(section.Elements, toggle)
	section.updateSize()
	
	return toggle
end

-- Toggle set value method
function UIHub.Toggle:SetValue(value)
	self.Value = value
	if value then
		TweenService:Create(self.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = self.Config.AccentColor
		}):Play()
		TweenService:Create(self.Indicator, TweenInfo.new(0.2), {
			Position = UDim2.new(1, -18, 0.5, -8),
			BackgroundColor3 = Color3.new(1, 1, 1)
		}):Play()
	else
		TweenService:Create(self.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = self.Themes[self.Config.Theme].Border
		}):Play()
		TweenService:Create(self.Indicator, TweenInfo.new(0.2), {
			Position = UDim2.new(0, 2, 0.5, -8),
			BackgroundColor3 = self.Themes[self.Config.Theme].Background
		}):Play()
	end
end

-- Add slider to section
function UIHub:AddSlider(section, text, min, max, default, callback)
	local slider = {}
	slider.Text = text
	slider.Min = min or 0
	slider.Max = max or 100
	slider.Value = default or min
	slider.Callback = callback
	slider.Height = 60
	
	-- Slider Frame
	slider.Frame = Instance.new("Frame")
	slider.Frame.Name = text .. "Slider"
	slider.Frame.Size = UDim2.new(1, 0, 0, slider.Height)
	slider.Frame.BackgroundTransparency = 1
	slider.Frame.BorderSizePixel = 0
	slider.Frame.Parent = section.Container
	
	-- Slider Label
	slider.Label = Instance.new("TextLabel")
	slider.Label.Name = "Label"
	slider.Label.Size = UDim2.new(1, 0, 0, 20)
	slider.Label.Position = UDim2.new(0, 0, 0, 0)
	slider.Label.BackgroundTransparency = 1
	slider.Label.Text = text
	slider.Label.TextColor3 = self.Themes[self.Config.Theme].Text
	slider.Label.TextSize = 14
	slider.Label.Font = self.Config.Font
	slider.Label.TextXAlignment = Enum.TextXAlignment.Left
	slider.Label.Parent = slider.Frame
	
	-- Value Label
	slider.ValueLabel = Instance.new("TextLabel")
	slider.ValueLabel.Name = "ValueLabel"
	slider.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
	slider.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
	slider.ValueLabel.BackgroundTransparency = 1
	slider.ValueLabel.Text = tostring(slider.Value)
	slider.ValueLabel.TextColor3 = self.Themes[self.Config.Theme].SubText
	slider.ValueLabel.TextSize = 14
	slider.ValueLabel.Font = self.Config.Font
	slider.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	slider.ValueLabel.Parent = slider.Frame
	
	-- Slider Track
	slider.Track = Instance.new("Frame")
	slider.Track.Name = "Track"
	slider.Track.Size = UDim2.new(1, 0, 0, 5)
	slider.Track.Position = UDim2.new(0, 0, 1, -25)
	slider.Track.BackgroundColor3 = self.Themes[self.Config.Theme].Border
	slider.Track.BorderSizePixel = 0
	slider.Track.Parent = slider.Frame
	
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 2)
	trackCorner.Parent = slider.Track
	
	-- Slider Fill
	slider.Fill = Instance.new("Frame")
	slider.Fill.Name = "Fill"
	slider.Fill.Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
	slider.Fill.Position = UDim2.new(0, 0, 0, 0)
	slider.Fill.BackgroundColor3 = self.Config.AccentColor
	slider.Fill.BorderSizePixel = 0
	slider.Fill.Parent = slider.Track
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = slider.Fill
	
	-- Slider Thumb
	slider.Thumb = Instance.new("TextButton")
	slider.Thumb.Name = "Thumb"
	slider.Thumb.Size = UDim2.new(0, 15, 0, 15)
	slider.Thumb.Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -7.5, 0.5, -7.5)
	slider.Thumb.BackgroundColor3 = Color3.new(1, 1, 1)
	slider.Thumb.BorderSizePixel = 0
	slider.Thumb.Text = ""
	slider.Thumb.AutoButtonColor = false
	slider.Thumb.Parent = slider.Track
	
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(0, 7)
	thumbCorner.Parent = slider.Thumb
	
	-- Dragging logic
	local dragging = false
	
	local function updateValue(input)
		local relativeX = (input.Position.X - slider.Track.AbsolutePosition.X) / slider.Track.AbsoluteSize.X
		local value = math.floor(slider.Min + (relativeX * (slider.Max - slider.Min)))
		value = math.clamp(value, slider.Min, slider.Max)
		
		slider:SetValue(value)
		
		if callback then
			callback(value)
		end
	end
	
	slider.Thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	slider.Thumb.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	slider.Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateValue(input)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input)
		end
	end)
	
	table.insert(section.Elements, slider)
	section.updateSize()
	
	return slider
end

-- Slider set value method
function UIHub.Slider:SetValue(value)
	self.Value = value
	self.ValueLabel.Text = tostring(value)
	
	local fillWidth = (value - self.Min) / (self.Max - self.Min)
	TweenService:Create(self.Fill, TweenInfo.new(0.1), {
		Size = UDim2.new(fillWidth, 0, 1, 0)
	}):Play()
	
	TweenService:Create(self.Thumb, TweenInfo.new(0.1), {
		Position = UDim2.new(fillWidth, -7.5, 0.5, -7.5)
	}):Play()
end

-- Add dropdown to section
function UIHub:AddDropdown(section, text, options, default, callback)
	local dropdown = {}
	dropdown.Text = text
	dropdown.Options = options or {}
	dropdown.Value = default or (options and options[1]) or nil
	dropdown.Callback = callback
	dropdown.Height = 30
	dropdown.Open = false
	
	-- Dropdown Frame
	dropdown.Frame = Instance.new("Frame")
	dropdown.Frame.Name = text .. "Dropdown"
	dropdown.Frame.Size = UDim2.new(1, 0, 0, dropdown.Height)
	dropdown.Frame.BackgroundTransparency = 1
	dropdown.Frame.BorderSizePixel = 0
	dropdown.Frame.ClipsDescendants = true
	dropdown.Frame.Parent = section.Container
	
	-- Dropdown Button
	dropdown.Button = Instance.new("TextButton")
	dropdown.Button.Name = "DropdownButton"
	dropdown.Button.Size = UDim2.new(1, 0, 0, dropdown.Height)
	dropdown.Button.Position = UDim2.new(0, 0, 0, 0)
	dropdown.Button.BackgroundColor3 = self.Themes[self.Config.Theme].Border
	dropdown.Button.BorderSizePixel = 0
	dropdown.Button.Text = ""
	dropdown.Button.AutoButtonColor = false
	dropdown.Button.Parent = dropdown.Frame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, self.Config.Rounding - 4)
	buttonCorner.Parent = dropdown.Button
	
	-- Dropdown Label
	dropdown.Label = Instance.new("TextLabel")
	dropdown.Label.Name = "Label"
	dropdown.Label.Size = UDim2.new(0.7, 0, 1, 0)
	dropdown.Label.Position = UDim2.new(0, 10, 0, 0)
	dropdown.Label.BackgroundTransparency = 1
	dropdown.Label.Text = text
	dropdown.Label.TextColor3 = self.Themes[self.Config.Theme].Text
	dropdown.Label.TextSize = 14
	dropdown.Label.Font = self.Config.Font
	dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
	dropdown.Label.Parent = dropdown.Button
	
	-- Value Label
	dropdown.ValueLabel = Instance.new("TextLabel")
	dropdown.ValueLabel.Name = "ValueLabel"
	dropdown.ValueLabel.Size = UDim2.new(0.3, -30, 1, 0)
	dropdown.ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
	dropdown.ValueLabel.BackgroundTransparency = 1
	dropdown.ValueLabel.Text = dropdown.Value or ""
	dropdown.ValueLabel.TextColor3 = self.Themes[self.Config.Theme].SubText
	dropdown.ValueLabel.TextSize = 14
	dropdown.ValueLabel.Font = self.Config.Font
	dropdown.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	dropdown.ValueLabel.Parent = dropdown.Button
	
	-- Arrow
	dropdown.Arrow = Instance.new("ImageLabel")
	dropdown.Arrow.Name = "Arrow"
	dropdown.Arrow.Size = UDim2.new(0, 20, 0, 20)
	dropdown.Arrow.Position = UDim2.new(1, -25, 0.5, -10)
	dropdown.Arrow.BackgroundTransparency = 1
	dropdown.Arrow.Image = "rbxassetid://6031091003"
	dropdown.Arrow.ImageColor3 = self.Themes[self.Config.Theme].SubText
	dropdown.Arrow.Parent = dropdown.Button
	
	-- Options Frame
	dropdown.OptionsFrame = Instance.new("Frame")
	dropdown.OptionsFrame.Name = "OptionsFrame"
	dropdown.OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
	dropdown.OptionsFrame.Position = UDim2.new(0, 0, 0, dropdown.Height + 5)
	dropdown.OptionsFrame.BackgroundColor3 = self.Themes[self.Config.Theme].Section
	dropdown.OptionsFrame.BorderSizePixel = 0
	dropdown.OptionsFrame.ClipsDescendants = true
	dropdown.OptionsFrame.Parent = dropdown.Frame
	
	local optionsCorner = Instance.new("UICorner")
	optionsCorner.CornerRadius = UDim.new(0, self.Config.Rounding - 4)
	optionsCorner.Parent = dropdown.OptionsFrame
	
	local optionsLayout = Instance.new("UIListLayout")
	optionsLayout.Padding = UDim.new(0, 1)
	optionsLayout.Parent = dropdown.OptionsFrame
	
	-- Create option buttons
	for i, option in ipairs(dropdown.Options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = option .. "Option"
		optionButton.Size = UDim2.new(1, 0, 0, 30)
		optionButton.BackgroundColor3 = self.Themes[self.Config.Theme].Border
		optionButton.BorderSizePixel = 0
		optionButton.Text = option
		optionButton.TextColor3 = self.Themes[self.Config.Theme].Text
		optionButton.TextSize = 14
		optionButton.Font = self.Config.Font
		optionButton.AutoButtonColor = false
		optionButton.Parent = dropdown.OptionsFrame
		
		optionButton.MouseButton1Click:Connect(function()
			dropdown:SetValue(option)
			if callback then
				callback(option)
			end
			dropdown:Toggle()
		end)
		
		-- Hover effect
		optionButton.MouseEnter:Connect(function()
			TweenService:Create(optionButton, TweenInfo.new(0.2), {
				BackgroundColor3 = self.Config.AccentColor
			}):Play()
		end)
		
		optionButton.MouseLeave:Connect(function()
			TweenService:Create(optionButton, TweenInfo.new(0.2), {
				BackgroundColor3 = self.Themes[self.Config.Theme].Border
			}):Play()
		end)
	end
	
	-- Toggle dropdown
	function dropdown:Toggle()
		self.Open = not self.Open
		
		if self.Open then
			local optionsHeight = #self.Options * 31
			TweenService:Create(self.Frame, TweenInfo.new(0.2), {
				Size = UDim2.new(1, 0, 0, self.Height + optionsHeight + 5)
			}):Play()
			TweenService:Create(self.OptionsFrame, TweenInfo.new(0.2), {
				Size = UDim2.new(1, 0, 0, optionsHeight)
			}):Play()
			TweenService:Create(self.Arrow, TweenInfo.new(0.2), {
				Rotation = 180
			}):Play()
		else
			TweenService:Create(self.Frame, TweenInfo.new(0.2), {
				Size = UDim2.new(1, 0, 0, self.Height)
			}):Play()
			TweenService:Create(self.OptionsFrame, TweenInfo.new(0.2), {
				Size = UDim2.new(1, 0, 0, 0)
			}):Play()
			TweenService:Create(self.Arrow, TweenInfo.new(0.2), {
				Rotation = 0
			}):Play()
		end
	end
	
	-- Set value method
	function dropdown:SetValue(value)
		self.Value = value
		self.ValueLabel.Text = value
	end
	
	-- Button click event
	dropdown.Button.MouseButton1Click:Connect(function()
		dropdown:Toggle()
	end)
	
	table.insert(section.Elements, dropdown)
	section.updateSize()
	
	return dropdown
end

-- Add label to section
function UIHub:AddLabel(section, text)
	local label = {}
	label.Text = text
	label.Height = 20
	
	-- Label Frame
	label.Frame = Instance.new("Frame")
	label.Frame.Name = text .. "Label"
	label.Frame.Size = UDim2.new(1, 0, 0, label.Height)
	label.Frame.BackgroundTransparency = 1
	label.Frame.BorderSizePixel = 0
	label.Frame.Parent = section.Container
	
	-- Label Text
	label.TextLabel = Instance.new("TextLabel")
	label.TextLabel.Name = "TextLabel"
	label.TextLabel.Size = UDim2.new(1, 0, 1, 0)
	label.TextLabel.Position = UDim2.new(0, 0, 0, 0)
	label.TextLabel.BackgroundTransparency = 1
	label.TextLabel.Text = text
	label.TextLabel.TextColor3 = self.Themes[self.Config.Theme].Text
	label.TextLabel.TextSize = 14
	label.TextLabel.Font = self.Config.Font
	label.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	label.TextLabel.Parent = label.Frame
	
	table.insert(section.Elements, label)
	section.updateSize()
	
	return label
end

-- Add keybind to section
function UIHub:AddKeybind(section, text, default, callback)
	local keybind = {}
	keybind.Text = text
	keybind.Value = default or Enum.KeyCode.Unknown
	keybind.Callback = callback
	keybind.Listening = false
	keybind.Height = 30
	
	-- Keybind Frame
	keybind.Frame = Instance.new("Frame")
	keybind.Frame.Name = text .. "Keybind"
	keybind.Frame.Size = UDim2.new(1, 0, 0, keybind.Height)
	keybind.Frame.BackgroundTransparency = 1
	keybind.Frame.BorderSizePixel = 0
	keybind.Frame.Parent = section.Container
	
	-- Keybind Label
	keybind.Label = Instance.new("TextLabel")
	keybind.Label.Name = "Label"
	keybind.Label.Size = UDim2.new(0.7, 0, 1, 0)
	keybind.Label.Position = UDim2.new(0, 0, 0, 0)
	keybind.Label.BackgroundTransparency = 1
	keybind.Label.Text = text
	keybind.Label.TextColor3 = self.Themes[self.Config.Theme].Text
	keybind.Label.TextSize = 14
	keybind.Label.Font = self.Config.Font
	keybind.Label.TextXAlignment = Enum.TextXAlignment.Left
	keybind.Label.Parent = keybind.Frame
	
	-- Keybind Button
	keybind.Button = Instance.new("TextButton")
	keybind.Button.Name = "KeybindButton"
	keybind.Button.Size = UDim2.new(0, 80, 0, 25)
	keybind.Button.Position = UDim2.new(1, -80, 0.5, -12.5)
	keybind.Button.BackgroundColor3 = self.Themes[self.Config.Theme].Border
	keybind.Button.BorderSizePixel = 0
	keybind.Button.Text = keybind.Value.Name
	keybind.Button.TextColor3 = self.Themes[self.Config.Theme].Text
	keybind.Button.TextSize = 12
	keybind.Button.Font = self.Config.Font
	keybind.Button.AutoButtonColor = false
	keybind.Button.Parent = keybind.Frame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, self.Config.Rounding - 4)
	buttonCorner.Parent = keybind.Button
	
	-- Listen for key input
	keybind.Button.MouseButton1Click:Connect(function()
		keybind.Listening = true
		keybind.Button.Text = "..."
		keybind.Button.BackgroundColor3 = self.Config.AccentColor
	end)
	
	local connection
	connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if keybind.Listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				keybind.Value = input.KeyCode
				keybind.Button.Text = input.KeyCode.Name
				keybind.Listening = false
				keybind.Button.BackgroundColor3 = self.Themes[self.Config.Theme].Border
				
				if callback then
					callback(input.KeyCode)
				end
			end
		else
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.Value then
				if callback then
					callback(keybind.Value)
				end
			end
		end
	end)
	
	keybind.Connection = connection
	
	table.insert(section.Elements, keybind)
	section.updateSize()
	
	return keybind
end

-- Destroy UI
function UIHub:Destroy()
	if self.Blur then
		self.Blur:Destroy()
	end
	self.ScreenGui:Destroy()
end

return UIHub
