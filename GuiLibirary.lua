--[[
    Rise 6.0-like GUI Library
    Mobile-friendly with keybinds, theme changing, and save system
]]

local GuiLibrary = {}
GuiLibrary.Connections = {}
GuiLibrary.Objects = {}
GuiLibrary.Profiles = {}
GuiLibrary.CurrentProfile = "Default"
GuiLibrary.Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 25),
        DarkBackground = Color3.fromRGB(15, 15, 15),
        LightBackground = Color3.fromRGB(35, 35, 35),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(0, 170, 255),
        NotEnabled = Color3.fromRGB(100, 100, 100),
        Enabled = Color3.fromRGB(0, 170, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        DarkBackground = Color3.fromRGB(220, 220, 220),
        LightBackground = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 120, 215),
        NotEnabled = Color3.fromRGB(150, 150, 150),
        Enabled = Color3.fromRGB(0, 120, 215)
    },
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        DarkBackground = Color3.fromRGB(5, 5, 5),
        LightBackground = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(170, 0, 255),
        NotEnabled = Color3.fromRGB(70, 70, 70),
        Enabled = Color3.fromRGB(170, 0, 255)
    }
}
GuiLibrary.CurrentTheme = GuiLibrary.Themes.Default

-- Core UI Variables
GuiLibrary.ScreenGui = nil
GuiLibrary.MainFrame = nil
GuiLibrary.TabsHolder = nil
GuiLibrary.ContentHolder = nil
GuiLibrary.IsMobile = false
GuiLibrary.SaveFolder = "Rise6.0"
GuiLibrary.SaveExtension = ".rise"
GuiLibrary.Keybinds = {}

-- Create necessary folders if they don't exist
local function createNecessaryFolders()
    if not isfolder(GuiLibrary.SaveFolder) then
        makefolder(GuiLibrary.SaveFolder)
    end
    if not isfolder(GuiLibrary.SaveFolder.."/Profiles") then
        makefolder(GuiLibrary.SaveFolder.."/Profiles")
    end
    if not isfolder(GuiLibrary.SaveFolder.."/Themes") then
        makefolder(GuiLibrary.SaveFolder.."/Themes")
    end
end

-- Check if player is on mobile device
local function checkMobile()
    local UserInputService = game:GetService("UserInputService")
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

-- Initialize the GUI
function GuiLibrary:Init()
    -- Check if player is on mobile
    GuiLibrary.IsMobile = checkMobile()
    
    -- Create save folders
    createNecessaryFolders()
    
    -- Create screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Rise6.0"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    GuiLibrary.ScreenGui = screenGui
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 650, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    mainFrame.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    GuiLibrary.MainFrame = mainFrame
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = mainFrame
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = GuiLibrary.CurrentTheme.DarkBackground
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- Add corner radius to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(0, 200, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Rise 6.0"
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    closeButton.Parent = titleBar
    
    -- Create minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "−"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 20
    minimizeButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    minimizeButton.Parent = titleBar
    
    -- Create tabs holder
    local tabsHolder = Instance.new("Frame")
    tabsHolder.Name = "TabsHolder"
    tabsHolder.Size = UDim2.new(0, 150, 1, -30)
    tabsHolder.Position = UDim2.new(0, 0, 0, 30)
    tabsHolder.BackgroundColor3 = GuiLibrary.CurrentTheme.DarkBackground
    tabsHolder.BorderSizePixel = 0
    tabsHolder.Parent = mainFrame
    GuiLibrary.TabsHolder = tabsHolder
    
    -- Create tab scroll frame
    local tabsScrollFrame = Instance.new("ScrollingFrame")
    tabsScrollFrame.Name = "TabsScrollFrame"
    tabsScrollFrame.Size = UDim2.new(1, 0, 1, -40)
    tabsScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    tabsScrollFrame.BackgroundTransparency = 1
    tabsScrollFrame.ScrollBarThickness = 4
    tabsScrollFrame.ScrollBarImageColor3 = GuiLibrary.CurrentTheme.AccentColor
    tabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsScrollFrame.Parent = tabsHolder
    
    -- Create UI list layout for tabs
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 2)
    tabsLayout.Parent = tabsScrollFrame
    
    -- Create settings button
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(1, 0, 0, 30)
    settingsButton.Position = UDim2.new(0, 0, 1, -30)
    settingsButton.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
    settingsButton.BorderSizePixel = 0
    settingsButton.Text = "Settings"
    settingsButton.Font = Enum.Font.GothamSemibold
    settingsButton.TextSize = 14
    settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsButton.Parent = tabsHolder
    
    -- Add corner radius to settings button
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 4)
    settingsCorner.Parent = settingsButton
    
    -- Create content holder
    local contentHolder = Instance.new("Frame")
    contentHolder.Name = "ContentHolder"
    contentHolder.Size = UDim2.new(1, -160, 1, -40)
    contentHolder.Position = UDim2.new(0, 160, 0, 40)
    contentHolder.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
    contentHolder.BorderSizePixel = 0
    contentHolder.Parent = mainFrame
    GuiLibrary.ContentHolder = contentHolder
    
    -- Add corner radius to content holder
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentHolder
    
    -- Register events
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        if mainFrame.Size == UDim2.new(0, 650, 0, 400) then
            mainFrame.Size = UDim2.new(0, 650, 0, 30)
            contentHolder.Visible = false
            tabsHolder.Visible = false
        else
            mainFrame.Size = UDim2.new(0, 650, 0, 400)
            contentHolder.Visible = true
            tabsHolder.Visible = true
        end
    end)
    
    settingsButton.MouseButton1Click:Connect(function()
        GuiLibrary:OpenSettings()
    end)
    
    -- Load saved profiles
    self:LoadProfiles()
    
    -- Load default or last used profile
    self:LoadProfile(GuiLibrary.CurrentProfile)
    
    return self
end

-- Create a tab
function GuiLibrary:CreateTab(name, icon)
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name.."Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.Position = UDim2.new(0, 5, 0, 0)
    tabButton.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 14
    tabButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    tabButton.AutoButtonColor = false
    tabButton.Parent = GuiLibrary.TabsHolder.TabsScrollFrame
    
    -- Add corner radius to tab button
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    -- Create icon if provided
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Name = "Icon"
        iconImage.Size = UDim2.new(0, 20, 0, 20)
        iconImage.Position = UDim2.new(0, 8, 0.5, -10)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = icon
        iconImage.Parent = tabButton
        
        tabButton.Text = "   "..name
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Create tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name.."Content"
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = GuiLibrary.CurrentTheme.AccentColor
    tabContent.Visible = false
    tabContent.Parent = GuiLibrary.ContentHolder
    
    -- Create UI list layout for tab content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = tabContent
    
    -- Auto-adjust canvas size
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Register tab click event
    tabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(GuiLibrary.ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        
        for _, v in pairs(GuiLibrary.TabsHolder.TabsScrollFrame:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                v.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            end
        end
        
        tabContent.Visible = true
        tabButton.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    -- Tab object to return
    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        
        -- Create section function
        CreateSection = function(self, sectionName)
            -- Create section frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = sectionName.."Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 36)
            sectionFrame.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = tabContent
            
            -- Add corner radius to section frame
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame
            
            -- Create section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, 0, 0, 26)
            sectionTitle.Position = UDim2.new(0, 0, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = sectionName
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextSize = 14
            sectionTitle.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            sectionTitle.Parent = sectionFrame
            
            -- Create section content
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, -20, 0, 0)
            sectionContent.Position = UDim2.new(0, 10, 0, 26)
            sectionContent.BackgroundTransparency = 1
            sectionContent.BorderSizePixel = 0
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.Parent = sectionFrame
            
            -- Create UI list layout for section content
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 6)
            sectionLayout.Parent = sectionContent
            
            -- Auto-adjust section height
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, -20, 0, sectionLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionContent.Size.Y.Offset + 36)
            end)
            
            -- Section object to return
            local section = {
                Name = sectionName,
                Frame = sectionFrame,
                Content = sectionContent,
                
                -- Create toggle function
                CreateToggle = function(self, toggleName, default, callback)
                    default = default or false
                    callback = callback or function() end
                    
                    -- Create toggle frame
                    local toggleFrame = Instance.new("Frame")
                    toggleFrame.Name = toggleName.."Toggle"
                    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
                    toggleFrame.BackgroundTransparency = 1
                    toggleFrame.Parent = sectionContent
                    
                    -- Create toggle text
                    local toggleText = Instance.new("TextLabel")
                    toggleText.Name = "Text"
                    toggleText.Size = UDim2.new(1, -50, 1, 0)
                    toggleText.Position = UDim2.new(0, 0, 0, 0)
                    toggleText.BackgroundTransparency = 1
                    toggleText.Text = toggleName
                    toggleText.Font = Enum.Font.Gotham
                    toggleText.TextSize = 14
                    toggleText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    toggleText.TextXAlignment = Enum.TextXAlignment.Left
                    toggleText.Parent = toggleFrame
                    
                    -- Create toggle button
                    local toggleButton = Instance.new("Frame")
                    toggleButton.Name = "Button"
                    toggleButton.Size = UDim2.new(0, 40, 0, 20)
                    toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
                    toggleButton.BackgroundColor3 = default and GuiLibrary.CurrentTheme.Enabled or GuiLibrary.CurrentTheme.NotEnabled
                    toggleButton.BorderSizePixel = 0
                    toggleButton.Parent = toggleFrame
                    
                    -- Add corner radius to toggle button
                    local toggleCorner = Instance.new("UICorner")
                    toggleCorner.CornerRadius = UDim.new(1, 0)
                    toggleCorner.Parent = toggleButton
                    
                    -- Create toggle indicator
                    local toggleIndicator = Instance.new("Frame")
                    toggleIndicator.Name = "Indicator"
                    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                    toggleIndicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    toggleIndicator.BorderSizePixel = 0
                    toggleIndicator.Parent = toggleButton
                    
                    -- Add corner radius to toggle indicator
                    local indicatorCorner = Instance.new("UICorner")
                    indicatorCorner.CornerRadius = UDim.new(1, 0)
                    indicatorCorner.Parent = toggleIndicator
                    
                    -- Create hitbox for button
                    local toggleHitbox = Instance.new("TextButton")
                    toggleHitbox.Name = "Hitbox"
                    toggleHitbox.Size = UDim2.new(1, 0, 1, 0)
                    toggleHitbox.BackgroundTransparency = 1
                    toggleHitbox.Text = ""
                    toggleHitbox.Parent = toggleFrame
                    
                    -- State and functionality
                    local toggled = default
                    
                    local function updateToggle()
                        toggled = not toggled
                        
                        -- Tween indicator
                        local targetPosition = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                        local targetColor = toggled and GuiLibrary.CurrentTheme.Enabled or GuiLibrary.CurrentTheme.NotEnabled
                        
                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        local positionTween = game:GetService("TweenService"):Create(toggleIndicator, tweenInfo, {Position = targetPosition})
                        local colorTween = game:GetService("TweenService"):Create(toggleButton, tweenInfo, {BackgroundColor3 = targetColor})
                        
                        positionTween:Play()
                        colorTween:Play()
                        
                        -- Save state in objects list
                        GuiLibrary.Objects[toggleName] = {Value = toggled, Type = "Toggle", Object = toggleFrame}
                        
                        -- Call callback
                        callback(toggled)
                    end
                    
                    -- Register click event
                    toggleHitbox.MouseButton1Click:Connect(updateToggle)
                    
                    -- Handle mobile long press for keybind
                    if GuiLibrary.IsMobile then
                        local pressStartTime = 0
                        local longPressThreshold = 0.5
                        
                        toggleHitbox.TouchLongPress:Connect(function()
                            GuiLibrary:CreateKeybindPrompt(toggleName, function(key)
                                GuiLibrary.Keybinds[toggleName] = key
                                GuiLibrary:SaveProfile(GuiLibrary.CurrentProfile)
                            end)
                        end)
                    end
                    
                    -- Create toggle object
                    local toggle = {
                        Name = toggleName,
                        Frame = toggleFrame,
                        Button = toggleButton,
                        Value = toggled,
                        Toggle = updateToggle,
                        SetValue = function(self, value)
                            if toggled ~= value then
                                updateToggle()
                            end
                        end
                    }
                    
                    -- Add to objects list
                    GuiLibrary.Objects[toggleName] = {Value = toggled, Type = "Toggle", Object = toggle}
                    
                    return toggle
                end,
                
                -- Create slider function
                CreateSlider = function(self, sliderName, min, max, default, callback)
                    min = min or 0
                    max = max or 100
                    default = default or min
                    callback = callback or function() end
                    
                    -- Clamp default value
                    default = math.clamp(default, min, max)
                    
                    -- Create slider frame
                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.Name = sliderName.."Slider"
                    sliderFrame.Size = UDim2.new(1, 0, 0, 45)
                    sliderFrame.BackgroundTransparency = 1
                    sliderFrame.Parent = sectionContent
                    
                    -- Create slider text and value display
                    local sliderText = Instance.new("TextLabel")
                    sliderText.Name = "Text"
                    sliderText.Size = UDim2.new(1, -50, 0, 20)
                    sliderText.Position = UDim2.new(0, 0, 0, 0)
                    sliderText.BackgroundTransparency = 1
                    sliderText.Text = sliderName
                    sliderText.Font = Enum.Font.Gotham
                    sliderText.TextSize = 14
                    sliderText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    sliderText.TextXAlignment = Enum.TextXAlignment.Left
                    sliderText.Parent = sliderFrame
                    
                    -- Create value display
                    local valueDisplay = Instance.new("TextLabel")
                    valueDisplay.Name = "Value"
                    valueDisplay.Size = UDim2.new(0, 50, 0, 20)
                    valueDisplay.Position = UDim2.new(1, -50, 0, 0)
                    valueDisplay.BackgroundTransparency = 1
                    valueDisplay.Text = tostring(default)
                    valueDisplay.Font = Enum.Font.Gotham
                    valueDisplay.TextSize = 14
                    valueDisplay.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
                    valueDisplay.Parent = sliderFrame
                    
                    -- Create slider bar background
                    local sliderBackground = Instance.new("Frame")
                    sliderBackground.Name = "Background"
                    sliderBackground.Size = UDim2.new(1, 0, 0, 10)
                    sliderBackground.Position = UDim2.new(0, 0, 0, 25)
                    sliderBackground.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                    sliderBackground.BorderSizePixel = 0
                    sliderBackground.Parent = sliderFrame
                    
                    -- Add corner radius to slider background
                    local backgroundCorner = Instance.new("UICorner")
                    backgroundCorner.CornerRadius = UDim.new(0, 5)
                    backgroundCorner.Parent = sliderBackground
                    
                    -- Create slider fill
                    local sliderFill = Instance.new("Frame")
                    sliderFill.Name = "Fill"
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderFill.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
                    sliderFill.BorderSizePixel = 0
                    sliderFill.Parent = sliderBackground
                    
                    -- Add corner radius to slider fill
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(0, 5)
                    fillCorner.Parent = sliderFill
                    
                    -- Create slider knob
                    local sliderKnob = Instance.new("Frame")
                    sliderKnob.Name = "Knob"
                    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
                    sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
                    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sliderKnob.BorderSizePixel = 0
                    sliderKnob.ZIndex = 2
                    sliderKnob.Parent = sliderBackground
                    
                    -- Add corner radius to slider knob
                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(1, 0)
                    knobCorner.Parent = sliderKnob
                    
                    -- Create hitbox for slider
                    local sliderHitbox = Instance.new("TextButton")
                    sliderHitbox.Name = "Hitbox"
                    sliderHitbox.Size = UDim2.new(1, 0, 1, 0)
                    sliderHitbox.BackgroundTransparency = 1
                    sliderHitbox.Text = ""
                    sliderHitbox.Parent = sliderBackground
                    
                    -- State and functionality
                    local value = default
                    
                    local function updateSlider(input)
                        -- Calculate position and value
                        local xPos = input.Position.X - sliderBackground.AbsolutePosition.X
                        local xSize = sliderBackground.AbsoluteSize.X
                        local relativePos = math.clamp(xPos / xSize, 0, 1)
                        local newValue = min + (max - min) * relativePos
                        
                        -- For integer values
                        if math.floor(min) == min and math.floor(max) == max then
                            newValue = math.floor(newValue + 0.5)
                        else
                            newValue = tonumber(string.format("%.2f", newValue))
                        end
                        
                        value = newValue
                        
                        -- Update UI
                        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                        sliderKnob.Position = UDim2.new(relativePos, -8, 0.5, -8)
                        valueDisplay.Text = tostring(value)
                        
                        -- Save state in objects list
                        GuiLibrary.Objects[sliderName] = {Value = value, Type = "Slider", Object = sliderFrame}
                        
                        -- Call callback
                        callback(value)
                    end
                    
                    -- Register drag events
                    local dragging = false
                    
                    sliderHitbox.MouseButton1Down:Connect(function(input)
                        dragging = true
                        updateSlider({Position = input})
                    end)
                    
                    game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    game:GetService("UserInputService").InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input)
                        end
                    end)
                    
                    -- For mobile
                    if GuiLibrary.IsMobile then
                        sliderHitbox.TouchMoved:Connect(function(touchPositions)
                            updateSlider({Position = touchPositions[1]})
                        end)
                    end
                    
                    -- Create slider object
                    local slider = {
                        Name = sliderName,
                        Frame = sliderFrame,
                        Value = value,
                        SetValue = function(self, newValue)
                            newValue = math.clamp(newValue, min, max)
                            local relativePos = (newValue - min) / (max - min)
                            
                            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                            sliderKnob.Position = UDim2.new(relativePos, -8, 0.5, -8)
                            valueDisplay.Text = tostring(newValue)
                            
                            value = newValue
                            GuiLibrary.Objects[sliderName] = {Value = value, Type = "Slider", Object = self}
                            callback(value)
                        end
                    }
                    
                    -- Add to objects list
                    GuiLibrary.Objects[sliderName] = {Value = value, Type = "Slider", Object = slider}
                    
                    return slider
                end,
                
                -- Create textbox function
                CreateTextbox = function(self, textboxName, defaultText, placeholder, callback)
                    defaultText = defaultText or ""
                    placeholder = placeholder or "Enter text..."
                    callback = callback or function() end
                    
                    -- Create textbox frame
                    local textboxFrame = Instance.new("Frame")
                    textboxFrame.Name = textboxName.."Textbox"
                    textboxFrame.Size = UDim2.new(1, 0, 0, 45)
                    textboxFrame.BackgroundTransparency = 1
                    textboxFrame.Parent = sectionContent
                    
                    -- Create textbox label
                    local textboxLabel = Instance.new("TextLabel")
                    textboxLabel.Name = "Label"
                    textboxLabel.Size = UDim2.new(1, 0, 0, 20)
                    textboxLabel.Position = UDim2.new(0, 0, 0, 0)
                    textboxLabel.BackgroundTransparency = 1
                    textboxLabel.Text = textboxName
                    textboxLabel.Font = Enum.Font.Gotham
                    textboxLabel.TextSize = 14
                    textboxLabel.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                    textboxLabel.Parent = textboxFrame
                    
                    -- Create textbox background
                    local textboxBackground = Instance.new("Frame")
                    textboxBackground.Name = "Background"
                    textboxBackground.Size = UDim2.new(1, 0, 0, 25)
                    textboxBackground.Position = UDim2.new(0, 0, 0, 20)
                    textboxBackground.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                    textboxBackground.BorderSizePixel = 0
                    textboxBackground.Parent = textboxFrame
                    
                    -- Add corner radius to textbox background
                    local backgroundCorner = Instance.new("UICorner")
                    backgroundCorner.CornerRadius = UDim.new(0, 4)
                    backgroundCorner.Parent = textboxBackground
                    
                    -- Create textbox
                    local textbox = Instance.new("TextBox")
                    textbox.Name = "Input"
                    textbox.Size = UDim2.new(1, -10, 1, 0)
                    textbox.Position = UDim2.new(0, 5, 0, 0)
                    textbox.BackgroundTransparency = 1
                    textbox.Text = defaultText
                    textbox.PlaceholderText = placeholder
                    textbox.Font = Enum.Font.Gotham
                    textbox.TextSize = 14
                    textbox.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                    textbox.TextXAlignment = Enum.TextXAlignment.Left
                    textbox.ClearTextOnFocus = false
                    textbox.Parent = textboxBackground
                    
                    -- State and functionality
                    local text = defaultText
                    
                    textbox.FocusLost:Connect(function(enterPressed)
                        text = textbox.Text
                        
                        -- Save state in objects list
                        GuiLibrary.Objects[textboxName] = {Value = text, Type = "Textbox", Object = textboxFrame}
                        
                        -- Call callback
                        callback(text, enterPressed)
                    end)
                    
                    -- Create textbox object
                    local textboxObj = {
                        Name = textboxName,
                        Frame = textboxFrame,
                        Value = text,
                        SetValue = function(self, newText)
                            textbox.Text = tostring(newText)
                            text = newText
                            GuiLibrary.Objects[textboxName] = {Value = text, Type = "Textbox", Object = self}
                        end
                    }
                    
                    -- Add to objects list
                    GuiLibrary.Objects[textboxName] = {Value = text, Type = "Textbox", Object = textboxObj}
                    
                    return textboxObj
                end,
                
                -- Create button function
                CreateButton = function(self, buttonText, callback)
                    callback = callback or function() end
                    
                    -- Create button frame
                    local buttonFrame = Instance.new("Frame")
                    buttonFrame.Name = buttonText.."Button"
                    buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                    buttonFrame.BackgroundTransparency = 1
                    buttonFrame.Parent = sectionContent
                    
                    -- Create button
                    local button = Instance.new("TextButton")
                    button.Name = "Button"
                    button.Size = UDim2.new(1, 0, 1, 0)
                    button.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
                    button.BorderSizePixel = 0
                    button.Text = buttonText
                    button.Font = Enum.Font.GothamSemibold
                    button.TextSize = 14
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.Parent = buttonFrame
                    
                    -- Add corner radius to button
                    local buttonCorner = Instance.new("UICorner")
                    buttonCorner.CornerRadius = UDim.new(0, 4)
                    buttonCorner.Parent = button
                    
                    -- Register click event
                    button.MouseButton1Click:Connect(function()
                        callback()
                    end)
                    
                    -- Create button object
                    local buttonObj = {
                        Name = buttonText,
                        Frame = buttonFrame,
                        Button = button
                    }
                    
                    return buttonObj
                end,
                
                -- Create dropdown function
                CreateDropdown = function(self, dropdownName, options, default, callback)
                    options = options or {}
                    default = default or options[1] or ""
                    callback = callback or function() end
                    
                    -- Create dropdown frame
                    local dropdownFrame = Instance.new("Frame")
                    dropdownFrame.Name = dropdownName.."Dropdown"
                    dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
                    dropdownFrame.BackgroundTransparency = 1
                    dropdownFrame.Parent = sectionContent
                    
                    -- Create dropdown label
                    local dropdownLabel = Instance.new("TextLabel")
                    dropdownLabel.Name = "Label"
                    dropdownLabel.Size = UDim2.new(1, 0, 0, 20)
                    dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                    dropdownLabel.BackgroundTransparency = 1
                    dropdownLabel.Text = dropdownName
                    dropdownLabel.Font = Enum.Font.Gotham
                    dropdownLabel.TextSize = 14
                    dropdownLabel.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownLabel.Parent = dropdownFrame
                    
                    -- Create dropdown button
                    local dropdownButton = Instance.new("TextButton")
                    dropdownButton.Name = "Button"
                    dropdownButton.Size = UDim2.new(1, 0, 0, 25)
                    dropdownButton.Position = UDim2.new(0, 0, 0, 20)
                    dropdownButton.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                    dropdownButton.BorderSizePixel = 0
                    dropdownButton.Text = default
                    dropdownButton.Font = Enum.Font.Gotham
                    dropdownButton.TextSize = 14
                    dropdownButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
                    dropdownButton.Parent = dropdownFrame
                    
                    -- Add padding to text
                    local textPadding = Instance.new("UIPadding")
                    textPadding.PaddingLeft = UDim.new(0, 8)
                    textPadding.Parent = dropdownButton
                    
                    -- Add corner radius to dropdown button
                    local buttonCorner = Instance.new("UICorner")
                    buttonCorner.CornerRadius = UDim.new(0, 4)
                    buttonCorner.Parent = dropdownButton
                    
                    -- Create dropdown arrow
                    local dropdownArrow = Instance.new("ImageLabel")
                    dropdownArrow.Name = "Arrow"
                    dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                    dropdownArrow.Position = UDim2.new(1, -25, 0.5, -10)
                    dropdownArrow.BackgroundTransparency = 1
                    dropdownArrow.Image = "rbxassetid://7072706663"
                    dropdownArrow.ImageColor3 = GuiLibrary.CurrentTheme.TextColor
                    dropdownArrow.Parent = dropdownButton
                    
                    -- Create dropdown menu
                    local dropdownMenu = Instance.new("Frame")
                    dropdownMenu.Name = "Menu"
                    dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
                    dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
                    dropdownMenu.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                    dropdownMenu.BorderSizePixel = 0
                    dropdownMenu.Visible = false
                    dropdownMenu.ZIndex = 5
                    dropdownMenu.ClipsDescendants = true
                    dropdownMenu.Parent = dropdownButton
                    
                    -- Add corner radius to dropdown menu
                    local menuCorner = Instance.new("UICorner")
                    menuCorner.CornerRadius = UDim.new(0, 4)
                    menuCorner.Parent = dropdownMenu
                    
                    -- Create dropdown options list
                    local optionsList = Instance.new("ScrollingFrame")
                    optionsList.Name = "OptionsList"
                    optionsList.Size = UDim2.new(1, 0, 1, 0)
                    optionsList.BackgroundTransparency = 1
                    optionsList.BorderSizePixel = 0
                    optionsList.ScrollBarThickness = 4
                    optionsList.ScrollBarImageColor3 = GuiLibrary.CurrentTheme.AccentColor
                    optionsList.ZIndex = 5
                    optionsList.Parent = dropdownMenu
                    
                    -- Create UI list layout for options
                    local optionsLayout = Instance.new("UIListLayout")
                    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    optionsLayout.Padding = UDim.new(0, 2)
                    optionsLayout.Parent = optionsList
                    
                    -- Create UI padding for options
                    local optionsPadding = Instance.new("UIPadding")
                    optionsPadding.PaddingTop = UDim.new(0, 2)
                    optionsPadding.PaddingBottom = UDim.new(0, 2)
                    optionsPadding.Parent = optionsList
                    
                    -- State and functionality
                    local selected = default
                    local dropdownOpen = false
                    
                    -- Function to add options to the dropdown
                    local function populateOptions()
                        -- Clear existing options
                        for _, child in pairs(optionsList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        -- Add new options
                        for i, option in ipairs(options) do
                            local optionButton = Instance.new("TextButton")
                            optionButton.Name = option
                            optionButton.Size = UDim2.new(1, 0, 0, 25)
                            optionButton.BackgroundTransparency = 1
                            optionButton.Text = option
                            optionButton.Font = Enum.Font.Gotham
                            optionButton.TextSize = 14
                            optionButton.TextColor3 = option == selected and GuiLibrary.CurrentTheme.AccentColor or GuiLibrary.CurrentTheme.TextColor
                            optionButton.TextXAlignment = Enum.TextXAlignment.Left
                            optionButton.ZIndex = 5
                            optionButton.Parent = optionsList
                            
                            -- Add padding to text
                            local optionPadding = Instance.new("UIPadding")
                            optionPadding.PaddingLeft = UDim.new(0, 8)
                            optionPadding.Parent = optionButton
                            
                            -- Register option click
                            optionButton.MouseButton1Click:Connect(function()
                                selected = option
                                dropdownButton.Text = option
                                
                                -- Update option colors
                                for _, child in pairs(optionsList:GetChildren()) do
                                    if child:IsA("TextButton") then
                                        child.TextColor3 = child.Name == selected and GuiLibrary.CurrentTheme.AccentColor or GuiLibrary.CurrentTheme.TextColor
                                    end
                                end
                                
                                -- Save state in objects list
                                GuiLibrary.Objects[dropdownName] = {Value = selected, Type = "Dropdown", Object = dropdownFrame}
                                
                                -- Close dropdown
                                dropdownMenu.Visible = false
                                dropdownOpen = false
                                
                                -- Call callback
                                callback(selected)
                            end)
                        end
                        
                        -- Update canvas size
                        optionsList.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 4)
                    end
                    
                    -- Toggle dropdown visibility
                    dropdownButton.MouseButton1Click:Connect(function()
                        dropdownOpen = not dropdownOpen
                        
                        if dropdownOpen then
                            -- Update options
                            populateOptions()
                            
                            -- Show dropdown with limited height
                            local maxHeight = math.min(optionsLayout.AbsoluteContentSize.Y + 4, 150)
                            dropdownMenu.Size = UDim2.new(1, 0, 0, maxHeight)
                            optionsList.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 4)
                            dropdownMenu.Visible = true
                        else
                            dropdownMenu.Visible = false
                        end
                    end)
                    
                    -- Close dropdown when clicking elsewhere
                    game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if dropdownOpen then
                                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                                local framePos = dropdownButton.AbsolutePosition
                                local frameSize = dropdownButton.AbsoluteSize
                                local menuSize = dropdownMenu.AbsoluteSize
                                
                                -- Check if click is outside the dropdown
                                if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                                   mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y + menuSize.Y + 5 then
                                    dropdownMenu.Visible = false
                                    dropdownOpen = false
                                end
                            end
                        end
                    end)
                    
                    -- Initial population
                    populateOptions()
                    
                    -- Create dropdown object
                    local dropdown = {
                        Name = dropdownName,
                        Frame = dropdownFrame,
                        Value = selected,
                        Options = options,
                        SetValue = function(self, newValue)
                            if table.find(options, newValue) then
                                selected = newValue
                                dropdownButton.Text = newValue
                                
                                -- Update option colors
                                for _, child in pairs(optionsList:GetChildren()) do
                                    if child:IsA("TextButton") then
                                        child.TextColor3 = child.Name == selected and GuiLibrary.CurrentTheme.AccentColor or GuiLibrary.CurrentTheme.TextColor
                                    end
                                end
                                
                                GuiLibrary.Objects[dropdownName] = {Value = selected, Type = "Dropdown", Object = self}
                                callback(selected)
                            end
                        end,
                        AddOption = function(self, option)
                            if not table.find(options, option) then
                                table.insert(options, option)
                                populateOptions()
                            end
                        end,
                        RemoveOption = function(self, option)
                            local index = table.find(options, option)
                            if index then
                                table.remove(options, index)
                                populateOptions()
                                
                                -- If selected option was removed, select the first available
                                if selected == option and #options > 0 then
                                    self:SetValue(options[1])
                                end
                            end
                        end
                    }
                    
                    -- Add to objects list
                    GuiLibrary.Objects[dropdownName] = {Value = selected, Type = "Dropdown", Object = dropdown}
                    
                    return dropdown
                end,
                
                -- Create color picker function
                CreateColorPicker = function(self, colorPickerName, default, callback)
                    default = default or Color3.fromRGB(255, 255, 255)
                    callback = callback or function() end
                    
                    -- Create color picker frame
                    local colorPickerFrame = Instance.new("Frame")
                    colorPickerFrame.Name = colorPickerName.."ColorPicker"
                    colorPickerFrame.Size = UDim2.new(1, 0, 0, 30)
                    colorPickerFrame.BackgroundTransparency = 1
                    colorPickerFrame.Parent = sectionContent
                    
                    -- Create color picker text
                    local colorPickerText = Instance.new("TextLabel")
                    colorPickerText.Name = "Text"
                    colorPickerText.Size = UDim2.new(1, -60, 1, 0)
                    colorPickerText.Position = UDim2.new(0, 0, 0, 0)
                    colorPickerText.BackgroundTransparency = 1
                    colorPickerText.Text = colorPickerName
                    colorPickerText.Font = Enum.Font.Gotham
                    colorPickerText.TextSize = 14
                    colorPickerText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    colorPickerText.TextXAlignment = Enum.TextXAlignment.Left
                    colorPickerText.Parent = colorPickerFrame
                    
                    -- Create color display
                    local colorDisplay = Instance.new("Frame")
                    colorDisplay.Name = "ColorDisplay"
                    colorDisplay.Size = UDim2.new(0, 50, 0, 20)
                    colorDisplay.Position = UDim2.new(1, -50, 0.5, -10)
                    colorDisplay.BackgroundColor3 = default
                    colorDisplay.BorderSizePixel = 0
                    colorDisplay.Parent = colorPickerFrame
                    
                    -- Add corner radius to color display
                    local displayCorner = Instance.new("UICorner")
                    displayCorner.CornerRadius = UDim.new(0, 4)
                    displayCorner.Parent = colorDisplay
                    
                    -- Create hitbox for color picker
                    local colorHitbox = Instance.new("TextButton")
                    colorHitbox.Name = "Hitbox"
                    colorHitbox.Size = UDim2.new(1, 0, 1, 0)
                    colorHitbox.BackgroundTransparency = 1
                    colorHitbox.Text = ""
                    colorHitbox.Parent = colorPickerFrame
                    
                    -- Create color picker popup
                    local colorPopup = Instance.new("Frame")
                    colorPopup.Name = "ColorPopup"
                    colorPopup.Size = UDim2.new(0, 200, 0, 220)
                    colorPopup.Position = UDim2.new(1, -210, 0, 30)
                    colorPopup.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                    colorPopup.BorderSizePixel = 0
                    colorPopup.Visible = false
                    colorPopup.ZIndex = 10
                    colorPopup.Parent = colorPickerFrame
                    
                    -- Add corner radius to color popup
                    local popupCorner = Instance.new("UICorner")
                    popupCorner.CornerRadius = UDim.new(0, 6)
                    popupCorner.Parent = colorPopup
                    
                    -- Create color picker title
                    local popupTitle = Instance.new("TextLabel")
                    popupTitle.Name = "Title"
                    popupTitle.Size = UDim2.new(1, 0, 0, 30)
                    popupTitle.BackgroundTransparency = 1
                    popupTitle.Text = "Color Picker"
                    popupTitle.Font = Enum.Font.GothamBold
                    popupTitle.TextSize = 14
                    popupTitle.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    popupTitle.ZIndex = 10
                    popupTitle.Parent = colorPopup
                    
                    -- Create color saturation picker
                    local saturationPicker = Instance.new("ImageLabel")
                    saturationPicker.Name = "SaturationPicker"
                    saturationPicker.Size = UDim2.new(0, 180, 0, 100)
                    saturationPicker.Position = UDim2.new(0.5, -90, 0, 40)
                    saturationPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    saturationPicker.BorderSizePixel = 0
                    saturationPicker.Image = "rbxassetid://4155801252"
                    saturationPicker.ZIndex = 10
                    saturationPicker.Parent = colorPopup
                    
                    -- Add corner radius to saturation picker
                    local saturationCorner = Instance.new("UICorner")
                    saturationCorner.CornerRadius = UDim.new(0, 4)
                    saturationCorner.Parent = saturationPicker
                    
                    -- Create saturation picker cursor
                    local saturationCursor = Instance.new("Frame")
                    saturationCursor.Name = "Cursor"
                    saturationCursor.Size = UDim2.new(0, 10, 0, 10)
                    saturationCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                    saturationCursor.Position = UDim2.new(1, 0, 0, 0)
                    saturationCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    saturationCursor.BorderSizePixel = 0
                    saturationCursor.ZIndex = 11
                    saturationCursor.Parent = saturationPicker
                    
                    -- Add corner radius to saturation cursor
                    local cursorCorner = Instance.new("UICorner")
                    cursorCorner.CornerRadius = UDim.new(1, 0)
                    cursorCorner.Parent = saturationCursor
                    
                    -- Create hue slider
                    local hueSlider = Instance.new("ImageLabel")
                    hueSlider.Name = "HueSlider"
                    hueSlider.Size = UDim2.new(0, 180, 0, 20)
                    hueSlider.Position = UDim2.new(0.5, -90, 0, 150)
                    hueSlider.BackgroundTransparency = 1
                    hueSlider.Image = "rbxassetid://3283443125"
                    hueSlider.ZIndex = 10
                    hueSlider.Parent = colorPopup
                    
                    -- Add corner radius to hue slider
                    local hueCorner = Instance.new("UICorner")
                    hueCorner.CornerRadius = UDim.new(0, 4)
                    hueCorner.Parent = hueSlider
                    
                    -- Create hue slider cursor
                    local hueCursor = Instance.new("Frame")
                    hueCursor.Name = "Cursor"
                    hueCursor.Size = UDim2.new(0, 5, 1, 0)
                    hueCursor.Position = UDim2.new(0, 0, 0, 0)
                    hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    hueCursor.BorderSizePixel = 0
                    hueCursor.ZIndex = 11
                    hueCursor.Parent = hueSlider
                    
                    -- Create apply button
                    local applyButton = Instance.new("TextButton")
                    applyButton.Name = "ApplyButton"
                    applyButton.Size = UDim2.new(0, 180, 0, 30)
                    applyButton.Position = UDim2.new(0.5, -90, 0, 180)
                    applyButton.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
                    applyButton.BorderSizePixel = 0
                    applyButton.Text = "Apply"
                    applyButton.Font = Enum.Font.GothamSemibold
                    applyButton.TextSize = 14
                    applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    applyButton.ZIndex = 10
                    applyButton.Parent = colorPopup
                    
                    -- Add corner radius to apply button
                    local applyCorner = Instance.new("UICorner")
                    applyCorner.CornerRadius = UDim.new(0, 4)
                    applyCorner.Parent = applyButton
                    
                    -- State and functionality
                    local color = default
                    local hue, saturation, value = 0, 0, 1
                    local colorPickerOpen = false
                    
                    -- Convert RGB to HSV
                    local function rgbToHsv(rgb)
                        local r, g, b = rgb.R, rgb.G, rgb.B
                        local max, min = math.max(r, g, b), math.min(r, g, b)
                        local h, s, v
                        v = max
                        
                        local d = max - min
                        if max == 0 then
                            s = 0
                        else
                            s = d / max
                        end
                        
                        if max == min then
                            h = 0
                        else
                            if max == r then
                                h = (g - b) / d
                                if g < b then h = h + 6 end
                            elseif max == g then
                                h = (b - r) / d + 2
                            elseif max == b then
                                h = (r - g) / d + 4
                            end
                            h = h / 6
                        end
                        
                        return h, s, v
                    end
                    
                    -- Convert HSV to RGB
                    local function hsvToRgb(h, s, v)
                        local r, g, b
                        
                        local i = math.floor(h * 6)
                        local f = h * 6 - i
                        local p = v * (1 - s)
                        local q = v * (1 - f * s)
                        local t = v * (1 - (1 - f) * s)
                        
                        i = i % 6
                        
                        if i == 0 then r, g, b = v, t, p
                        elseif i == 1 then r, g, b = q, v, p
                        elseif i == 2 then r, g, b = p, v, t
                        elseif i == 3 then r, g, b = p, q, v
                        elseif i == 4 then r, g, b = t, p, v
                        elseif i == 5 then r, g, b = v, p, q
                        end
                        
                        return Color3.new(r, g, b)
                    end
                    
                    -- Update color from HSV values
                    local function updateColor()
                        color = hsvToRgb(hue, saturation, value)
                        colorDisplay.BackgroundColor3 = color
                        saturationPicker.BackgroundColor3 = hsvToRgb(hue, 1, 1)
                        
                        -- Update cursors
                        saturationCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
                        hueCursor.Position = UDim2.new(hue, 0, 0, 0)
                    end
                    
                    -- Initialize HSV values from default color
                    hue, saturation, value = rgbToHsv(default)
                    updateColor()
                    
                    -- Toggle color picker visibility
                    colorHitbox.MouseButton1Click:Connect(function()
                        colorPickerOpen = not colorPickerOpen
                        colorPopup.Visible = colorPickerOpen
                    end)
                    
                    -- Handle saturation picker
                    local saturationDragging = false
                    
                    saturationPicker.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            saturationDragging = true
                            
                            -- Calculate saturation and value from input position
                            local x = math.clamp((input.Position.X - saturationPicker.AbsolutePosition.X) / saturationPicker.AbsoluteSize.X, 0, 1)
                            local y = math.clamp((input.Position.Y - saturationPicker.AbsolutePosition.Y) / saturationPicker.AbsoluteSize.Y, 0, 1)
                            
                            saturation = x
                            value = 1 - y
                            
                            updateColor()
                        end
                    end)
                    
                    saturationPicker.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            saturationDragging = false
                        end
                    end)
                    
                    -- Handle hue slider
                    local hueDragging = false
                    
                    hueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = true
                            
                            -- Calculate hue from input position
                            local x = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                            
                            hue = x
                            
                            updateColor()
                        end
                    end)
                    
                    hueSlider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = false
                        end
                    end)
                    
                    -- Handle dragging
                    game:GetService("UserInputService").InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if saturationDragging then
                                -- Calculate saturation and value from input position
                                local x = math.clamp((input.Position.X - saturationPicker.AbsolutePosition.X) / saturationPicker.AbsoluteSize.X, 0, 1)
                                local y = math.clamp((input.Position.Y - saturationPicker.AbsolutePosition.Y) / saturationPicker.AbsoluteSize.Y, 0, 1)
                                
                                saturation = x
                                value = 1 - y
                                
                                updateColor()
                            elseif hueDragging then
                                -- Calculate hue from input position
                                local x = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                                
                                hue = x
                                
                                updateColor()
                            end
                        end
                    end)
                    
                    -- Apply color button
                    applyButton.MouseButton1Click:Connect(function()
                        -- Save state in objects list
                        GuiLibrary.Objects[colorPickerName] = {Value = color, Type = "ColorPicker", Object = colorPickerFrame}
                        
                        -- Close color picker
                        colorPopup.Visible = false
                        colorPickerOpen = false
                        
                        -- Call callback
                        callback(color)
                    end)
                    
                    -- Close color picker when clicking elsewhere
                    game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if colorPickerOpen then
                                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                                local framePos = colorPopup.AbsolutePosition
                                local frameSize = colorPopup.AbsoluteSize
                                
                                -- Check if click is outside the color picker
                                if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                                   mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                                    -- Only close if click isn't on the display
                                    local displayPos = colorDisplay.AbsolutePosition
                                    local displaySize = colorDisplay.AbsoluteSize
                                    
                                    if mousePos.X < displayPos.X or mousePos.X > displayPos.X + displaySize.X or
                                       mousePos.Y < displayPos.Y or mousePos.Y > displayPos.Y + displaySize.Y then
                                        colorPopup.Visible = false
                                        colorPickerOpen = false
                                    end
                                end
                            end
                        end
                    end)
                    
                    -- Create color picker object
                    local colorPicker = {
                        Name = colorPickerName,
                        Frame = colorPickerFrame,
                        Value = color,
                        SetValue = function(self, newColor)
                            color = newColor
                            colorDisplay.BackgroundColor3 = color
                            hue, saturation, value = rgbToHsv(color)
                            updateColor()
                            
                            GuiLibrary.Objects[colorPickerName] = {Value = color, Type = "ColorPicker", Object = self}
                            callback(color)
                        end
                    }
                    
                    -- Add to objects list
                    GuiLibrary.Objects[colorPickerName] = {Value = color, Type = "ColorPicker", Object = colorPicker}
                    
                    return colorPicker
                end
            }
            
            return section
        end
    }
    
    -- If this is the first tab, select it by default
    if #GuiLibrary.ContentHolder:GetChildren() == 1 then
        tabButton.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabContent.Visible = true
    end
    
    return tab
end

-- Settings tab
function GuiLibrary:OpenSettings()
    -- Check if settings tab already exists
    local existingSettings = nil
    for _, child in pairs(GuiLibrary.ContentHolder:GetChildren()) do
        if child.Name == "SettingsContent" then
            existingSettings = child
            break
        end
    end
    
    if existingSettings then
        -- Show existing settings tab
        for _, v in pairs(GuiLibrary.ContentHolder:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        
        for _, v in pairs(GuiLibrary.TabsHolder.TabsScrollFrame:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                v.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            end
        end
        
        existingSettings.Visible = true
        
        -- Find and update settings tab button
        for _, v in pairs(GuiLibrary.TabsHolder.TabsScrollFrame:GetChildren()) do
            if v:IsA("TextButton") and v.Name == "SettingsTab" then
                v.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
                v.TextColor3 = Color3.fromRGB(255, 255, 255)
                break
            end
        end
        
        return
    end
    
    -- Create settings tab
    local settingsTab = self:CreateTab("Settings")
    settingsTab.Button.Name = "SettingsTab"
    
    -- Create theme section
    local themeSection = settingsTab:CreateSection("Theme")
    
    -- Create theme dropdown
    local themes = {}
    for themeName, _ in pairs(GuiLibrary.Themes) do
        table.insert(themes, themeName)
    end
    
    -- Determine current theme name
    local currentThemeName = "Default"
    for name, theme in pairs(GuiLibrary.Themes) do
        if theme == GuiLibrary.CurrentTheme then
            currentThemeName = name
            break
        end
    end
    
    local themeDropdown = themeSection:CreateDropdown("Theme", themes, currentThemeName, function(selected)
        GuiLibrary:SetTheme(selected)
    end)
    
    -- Create profiles section
    local profilesSection = settingsTab:CreateSection("Profiles")
    
    -- Create profile name textbox
    local profileNameTextbox = profilesSection:CreateTextbox("Profile Name", GuiLibrary.CurrentProfile, "Enter profile name...", function(text)
        -- Don't allow empty profile names
        if text:gsub("%s", "") ~= "" then
            -- Just update the textbox for now, saving happens with the Save button
        end
    end)
    
    -- Create save profile button
    local saveProfileButton = profilesSection:CreateButton("Save Profile", function()
        local profileName = profileNameTextbox.Value
        if profileName:gsub("%s", "") ~= "" then
            GuiLibrary:SaveProfile(profileName)
            GuiLibrary.CurrentProfile = profileName
            
            -- Refresh profiles dropdown
            GuiLibrary:LoadProfiles()
            profilesDropdown:SetValue(profileName)
        end
    end)
    
    -- Create delete profile button
    local deleteProfileButton = profilesSection:CreateButton("Delete Profile", function()
        local profileName = profilesDropdown.Value
        if profileName ~= "Default" then
            GuiLibrary:DeleteProfile(profileName)
            
            -- Refresh profiles dropdown
            GuiLibrary:LoadProfiles()
            profilesDropdown:SetValue("Default")
            GuiLibrary:LoadProfile("Default")
            GuiLibrary.CurrentProfile = "Default"
            profileNameTextbox:SetValue("Default")
        end
    end)
    
    -- Create profiles dropdown
    local profilesDropdown = profilesSection:CreateDropdown("Load Profile", {"Default"}, GuiLibrary.CurrentProfile, function(selected)
        GuiLibrary:LoadProfile(selected)
        GuiLibrary.CurrentProfile = selected
        profileNameTextbox:SetValue(selected)
    end)
    
    -- Populate profiles dropdown
    local profiles = {}
    for _, profile in ipairs(GuiLibrary.Profiles) do
        table.insert(profiles, profile)
    end
    
    if #profiles > 0 then
        for i, profile in ipairs(profiles) do
            profilesDropdown:AddOption(profile)
        end
    end
    
    -- Create mobile section
    if GuiLibrary.IsMobile then
        local mobileSection = settingsTab:CreateSection("Mobile Controls")
        
        -- Create button scale slider
        local buttonScaleSlider = mobileSection:CreateSlider("Button Scale", 0.5, 2, 1, function(value)
            -- Implement button scaling logic
        end)
    end
    
    -- Show settings tab
    settingsTab.Button.MouseButton1Click:Connect(function()
        -- This will be handled by the tab click event already implemented
    end)
    
    -- Force select settings tab
    settingsTab.Button.MouseButton1Click:Fire()
end

-- Function to set theme
function GuiLibrary:SetTheme(themeName)
    if GuiLibrary.Themes[themeName] then
        GuiLibrary.CurrentTheme = GuiLibrary.Themes[themeName]
        
        -- Update UI elements with new theme colors
        if GuiLibrary.MainFrame then
            GuiLibrary.MainFrame.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
            GuiLibrary.MainFrame.TitleBar.BackgroundColor3 = GuiLibrary.CurrentTheme.DarkBackground
            GuiLibrary.MainFrame.TitleBar.Title.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            GuiLibrary.MainFrame.TitleBar.CloseButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            GuiLibrary.MainFrame.TitleBar.MinimizeButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
            GuiLibrary.TabsHolder.BackgroundColor3 = GuiLibrary.CurrentTheme.DarkBackground
            GuiLibrary.TabsHolder.SettingsButton.BackgroundColor3 = GuiLibrary.CurrentTheme.AccentColor
            GuiLibrary.ContentHolder.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
            
            -- Update tab buttons
            for _, child in pairs(GuiLibrary.TabsHolder.TabsScrollFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    if child.BackgroundColor3 ~= GuiLibrary.CurrentTheme.AccentColor then
                        child.BackgroundColor3 = GuiLibrary.CurrentTheme.LightBackground
                        child.TextColor3 = GuiLibrary.CurrentTheme.TextColor
                    end
                end
            end
            
            -- Update scrollbar colors
            for _, v in pairs(GuiLibrary.ScreenGui:GetDescendants()) do
                if v:IsA("ScrollingFrame") then
                    v.ScrollBarImageColor3 = GuiLibrary.CurrentTheme.AccentColor
                end
            end
            
            -- Update all UI elements recursively
            for _, obj in pairs(GuiLibrary.Objects) do
                if obj.Type == "Toggle" and obj.Object.Value ~= nil then
                    local toggle = obj.Object
                    local button = toggle.Button
                    if button then
                        button.BackgroundColor3 = toggle.Value and GuiLibrary.CurrentTheme.Enabled or GuiLibrary.CurrentTheme.NotEnabled
                    end
                elseif obj.Type == "Dropdown" or obj.Type == "Slider" or obj.Type == "Textbox" then
                    -- Update these UI elements if needed
                end
            end
        end
        
        -- Save theme in profile
        GuiLibrary:SaveProfile(GuiLibrary.CurrentProfile)
    end
end

-- Function to create keybind prompt
function GuiLibrary:CreateKeybindPrompt(name, callback)
    callback = callback or function() end
    
    -- Create the prompt frame
    local promptFrame = Instance.new("Frame")
    promptFrame.Name = "KeybindPrompt"
    promptFrame.Size = UDim2.new(0, 250, 0, 120)
    promptFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
    promptFrame.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
    promptFrame.BorderSizePixel = 0
    promptFrame.ZIndex = 20
    promptFrame.Parent = GuiLibrary.ScreenGui
    
    -- Add corner radius
    local promptCorner = Instance.new("UICorner")
    promptCorner.CornerRadius = UDim.new(0, 6)
    promptCorner.Parent = promptFrame
    
    -- Create prompt title
    local promptTitle = Instance.new("TextLabel")
    promptTitle.Name = "Title"
    promptTitle.Size = UDim2.new(1, 0, 0, 30)
    promptTitle.BackgroundTransparency = 1
    promptTitle.Text = "Set Keybind for " .. name
    promptTitle.Font = Enum.Font.GothamBold
    promptTitle.TextSize = 14
    promptTitle.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    promptTitle.ZIndex = 20
    promptTitle.Parent = promptFrame
    
    -- Create instruction text
    local instructionText = Instance.new("TextLabel")
    instructionText.Name = "Instruction"
    instructionText.Size = UDim2.new(1, 0, 0, 30)
    instructionText.Position = UDim2.new(0, 0, 0.4, -15)
    instructionText.BackgroundTransparency = 1
    instructionText.Text = "Press any key/button..."
    instructionText.Font = Enum.Font.Gotham
    instructionText.TextSize = 14
    instructionText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    instructionText.ZIndex = 20
    instructionText.Parent = promptFrame
    
    -- Create current keybind text
    local currentKeybind = GuiLibrary.Keybinds[name]
    local keybindText = Instance.new("TextLabel")
    keybindText.Name = "KeybindDisplay"
    keybindText.Size = UDim2.new(1, 0, 0, 30)
    keybindText.Position = UDim2.new(0, 0, 0.6, -15)
    keybindText.BackgroundTransparency = 1
    keybindText.Text = currentKeybind and "Current: " .. currentKeybind or "Current: None"
    keybindText.Font = Enum.Font.Gotham
    keybindText.TextSize = 14
    keybindText.TextColor3 = GuiLibrary.CurrentTheme.AccentColor
    keybindText.ZIndex = 20
    keybindText.Parent = promptFrame
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = GuiLibrary.CurrentTheme.TextColor
    closeButton.ZIndex = 20
    closeButton.Parent = promptFrame
    
    -- Handler function
    local function handleInput(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            -- Keyboard key
            local keyName = input.KeyCode.Name
            GuiLibrary.Keybinds[name] = keyName
            keybindText.Text = "Current: " .. keyName
            callback(keyName)
            promptFrame:Destroy()
            return true
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Left mouse button
            GuiLibrary.Keybinds[name] = "MouseButton1"
            keybindText.Text = "Current: MouseButton1"
            callback("MouseButton1")
            promptFrame:Destroy()
            return true
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            -- Right mouse button
            GuiLibrary.Keybinds[name] = "MouseButton2"
            keybindText.Text = "Current: MouseButton2"
            callback("MouseButton2")
            promptFrame:Destroy()
            return true
        elseif input.UserInputType == Enum.UserInputType.Touch then
            -- Touch input (for mobile)
            GuiLibrary.Keybinds[name] = "Touch"
            keybindText.Text = "Current: Touch"
            callback("Touch")
            promptFrame:Destroy()
            return true
        elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
            -- Controller button
            local buttonName = input.KeyCode.Name
            GuiLibrary.Keybinds[name] = "Gamepad:" .. buttonName
            keybindText.Text = "Current: Gamepad:" .. buttonName
            callback("Gamepad:" .. buttonName)
            promptFrame:Destroy()
            return true
        end
        return false
    end
    
    -- Connect input event
    local connection
    connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if handleInput(input) then
                connection:Disconnect()
            end
        end
    end)
    
    -- Connect close button
    closeButton.MouseButton1Click:Connect(function()
        connection:Disconnect()
        promptFrame:Destroy()
    end)
    
    -- Allow clicking outside to close
    local outsideClickDisconnect
    outsideClickDisconnect = game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local framePos = promptFrame.AbsolutePosition
            local frameSize = promptFrame.AbsoluteSize
            
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
               mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                connection:Disconnect()
                outsideClickDisconnect:Disconnect()
                promptFrame:Destroy()
            end
        end
    end)
end

-- Function to save profile
function GuiLibrary:SaveProfile(profileName)
    local profileData = {
        Theme = nil,
        Objects = {},
        Keybinds = GuiLibrary.Keybinds
    }
    
    -- Get current theme name
    for name, theme in pairs(GuiLibrary.Themes) do
        if theme == GuiLibrary.CurrentTheme then
            profileData.Theme = name
            break
        end
    end
    
    -- Save objects state
    for name, obj in pairs(GuiLibrary.Objects) do
        if obj.Type == "Toggle" or obj.Type == "Slider" or obj.Type == "Textbox" or obj.Type == "Dropdown" or obj.Type == "ColorPicker" then
            profileData.Objects[name] = {
                Type = obj.Type,
                Value = obj.Value
            }
        end
    end
    
    -- Create JSON string
    local jsonData = game:GetService("HttpService"):JSONEncode(profileData)
    
    -- Save to file
    writefile(GuiLibrary.SaveFolder.."/Profiles/"..profileName..GuiLibrary.SaveExtension, jsonData)
    
    -- Refresh profiles list
    self:LoadProfiles()
end

-- Function to load profile
function GuiLibrary:LoadProfile(profileName)
    local filePath = GuiLibrary.SaveFolder.."/Profiles/"..profileName..GuiLibrary.SaveExtension
    
    -- Check if file exists
    if isfile(filePath) then
        local success, profileData = pcall(function()
            local fileContent = readfile(filePath)
            return game:GetService("HttpService"):JSONDecode(fileContent)
        end)
        
        if success and profileData then
            -- Set theme if available
            if profileData.Theme and GuiLibrary.Themes[profileData.Theme] then
                GuiLibrary:SetTheme(profileData.Theme)
            end
            
            -- Load keybinds
            if profileData.Keybinds then
                GuiLibrary.Keybinds = profileData.Keybinds
            end
            
            -- Load objects state
            if profileData.Objects then
                for name, objData in pairs(profileData.Objects) do
                    if GuiLibrary.Objects[name] and GuiLibrary.Objects[name].Object then
                        local obj = GuiLibrary.Objects[name].Object
                        if obj.SetValue then
                            obj:SetValue(objData.Value)
                        end
                    end
                end
            end
            
            -- Update current profile
            GuiLibrary.CurrentProfile = profileName
        end
    else
        -- If profile doesn't exist, create it with current settings
        self:SaveProfile(profileName)
    end
end

-- Function to delete profile
function GuiLibrary:DeleteProfile(profileName)
    if profileName ~= "Default" then
        local filePath = GuiLibrary.SaveFolder.."/Profiles/"..profileName..GuiLibrary.SaveExtension
        
        -- Check if file exists
        if isfile(filePath) then
            delfile(filePath)
        end
        
        -- Refresh profiles list
        self:LoadProfiles()
    end
end

-- Function to load profiles
function GuiLibrary:LoadProfiles()
    -- Clear profiles list
    GuiLibrary.Profiles = {"Default"}
    
    -- Check if profiles folder exists
    if isfolder(GuiLibrary.SaveFolder.."/Profiles") then
        -- Get all files in the folder
        local files = listfiles(GuiLibrary.SaveFolder.."/Profiles")
        
        -- Filter and add profiles
        for _, file in ipairs(files) do
            local fileName = string.match(file, "[^/\\]+$")
            local profileName = string.match(fileName, "(.+)"..GuiLibrary.SaveExtension.."$")
            
            if profileName and profileName ~= "Default" then
                table.insert(GuiLibrary.Profiles, profileName)
            end
        end
    end
    
    -- Sort profiles
    table.sort(GuiLibrary.Profiles)
    
    -- Make sure Default is first
    local defaultIndex = table.find(GuiLibrary.Profiles, "Default")
    if defaultIndex and defaultIndex > 1 then
        table.remove(GuiLibrary.Profiles, defaultIndex)
        table.insert(GuiLibrary.Profiles, 1, "Default")
    end
    
    return GuiLibrary.Profiles
end

-- Function to setup key hooks
function GuiLibrary:SetupKeyHooks()
    -- Connect to input events
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            local inputName = ""
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                inputName = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputName = "MouseButton1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                inputName = "MouseButton2"
            elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
                inputName = "Gamepad:" .. input.KeyCode.Name
            end
            
            -- Check if input matches any keybind
            for name, keybind in pairs(GuiLibrary.Keybinds) do
                if keybind == inputName then
                    -- Toggle associated object
                    if GuiLibrary.Objects[name] and GuiLibrary.Objects[name].Object then
                        local obj = GuiLibrary.Objects[name].Object
                        if obj.Toggle then
                            obj:Toggle()
                        elseif obj.SetValue and GuiLibrary.Objects[name].Type == "Toggle" then
                            obj:SetValue(not GuiLibrary.Objects[name].Value)
                        end
                    end
                end
            end
        end
    end)
end

return GuiLibrary
