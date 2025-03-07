--[[
    Rise 6.0-like GUI
    New/Alternative Main Script
    This is a variation with some extra features and optimizations
]]

-- Load executor-specific libraries
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- Get commit hash and assets version from files
local function loadFileContent(filePath, default)
    if isfile(filePath) then
        return readfile(filePath)
    end
    return default
end

local commitHash = loadFileContent("Rise6.0/commithash.txt", "dev-build")
local assetsVersion = loadFileContent("Rise6.0/assetsversion.txt", "1.0.0")

-- Initialize paths
local BASE_PATH = "Rise6.0"
local LIBRARIES_PATH = BASE_PATH .. "/Libraries"
local MODULES_PATH = BASE_PATH .. "/CustomModules"
local PROFILES_PATH = BASE_PATH .. "/Profiles"
local ASSETS_PATH = BASE_PATH .. "/assets"

-- Ensure necessary folders exist
local function ensureFolderStructure()
    local folders = {
        BASE_PATH,
        LIBRARIES_PATH,
        MODULES_PATH,
        PROFILES_PATH,
        ASSETS_PATH
    }
    
    for _, folder in ipairs(folders) do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
end

-- Create version files if they don't exist
local function ensureVersionFiles()
    if not isfile(BASE_PATH .. "/commithash.txt") then
        writefile(BASE_PATH .. "/commithash.txt", "dev-build")
    end
    
    if not isfile(BASE_PATH .. "/assetsversion.txt") then
        writefile(BASE_PATH .. "/assetsversion.txt", "1.0.0")
    end
end

-- Load the GUI library
local function loadGuiLibrary()
    if isfile(BASE_PATH .. "/GuiLibrary.lua") then
        return loadstring(readfile(BASE_PATH .. "/GuiLibrary.lua"))()
    else
        error("GuiLibrary.lua is missing!")
    end
end

-- Load the Universal module
local function loadUniversal()
    if isfile(BASE_PATH .. "/Universal.lua") then
        return loadstring(readfile(BASE_PATH .. "/Universal.lua"))()
    else
        error("Universal.lua is missing!")
    end
end

-- Load custom modules
local function loadCustomModules()
    local modules = {}
    
    if isfolder(MODULES_PATH) then
        local files = listfiles(MODULES_PATH)
        
        for _, file in ipairs(files) do
            if file:sub(-4) == ".lua" then
                local moduleName = file:match("([^/\\]+)%.lua$")
                
                local success, module = pcall(function()
                    return loadstring(readfile(file))()
                end)
                
                if success and module then
                    modules[moduleName] = module
                    print("Loaded custom module: " .. moduleName)
                else
                    warn("Failed to load module: " .. moduleName)
                end
            end
        end
    end
    
    return modules
end

-- Performance optimization helpers
local function optimizeRendering()
    -- Reduce render quality when GUI is open for better performance
    local UserSettings = UserSettings()
    local GameSettings = UserSettings.GameSettings
    
    local originalRenderQuality = GameSettings.SavedQualityLevel
    
    local function setRenderQuality(level)
        GameSettings.SavedQualityLevel = level
    end
    
    return {
        lowerQuality = function()
            setRenderQuality(math.max(1, originalRenderQuality - 2))
        end,
        restoreQuality = function()
            setRenderQuality(originalRenderQuality)
        end,
        getOriginalQuality = function()
            return originalRenderQuality
        end
    }
end

-- Game detection
local function detectGame()
    local gameId = game.PlaceId
    local gameName = "Unknown"
    
    -- List of known games to customize the UI for
    local knownGames = {
        [286090429] = "Arsenal",
        [292439477] = "Phantom Forces",
        [2377868063] = "Strucid",
        [3233893879] = "Bad Business",
        [2555870920] = "AceOfSpadez",
        [4292776423] = "Unit: Classified",
        [606849621] = "Jailbreak",
        [3956818381] = "Ninja Legends",
        [1962086868] = "Tower of Hell"
    }
    
    if knownGames[gameId] then
        gameName = knownGames[gameId]
    end
    
    return {
        id = gameId,
        name = gameName
    }
end

-- FPS Counter Setup
local function setupFpsCounter(GuiLibrary)
    local fpsText = nil
    local lastUpdate = tick()
    local frames = 0
    
    -- Create FPS counter
    local function createFpsCounter()
        if fpsText then return end
        
        local fpsFrame = Instance.new("Frame")
        fpsFrame.Name = "FPSCounter"
        fpsFrame.Size = UDim2.new(0, 60, 0, 20)
        fpsFrame.Position = UDim2.new(0, 10, 0, 10)
        fpsFrame.BackgroundColor3 = GuiLibrary.CurrentTheme.Background
        fpsFrame.BackgroundTransparency = 0.3
        fpsFrame.BorderSizePixel = 0
        fpsFrame.Parent = GuiLibrary.ScreenGui
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = fpsFrame
        
        -- Create FPS text
        fpsText = Instance.new("TextLabel")
        fpsText.Name = "FPSText"
        fpsText.Size = UDim2.new(1, 0, 1, 0)
        fpsText.BackgroundTransparency = 1
        fpsText.Text = "FPS: 60"
        fpsText.Font = Enum.Font.GothamSemibold
        fpsText.TextSize = 12
        fpsText.TextColor3 = GuiLibrary.CurrentTheme.TextColor
        fpsText.Parent = fpsFrame
    end
    
    -- Update FPS counter
    local function updateFpsCounter()
        frames = frames + 1
        
        local currentTime = tick()
        local delta = currentTime - lastUpdate
        
        if delta >= 1 then
            if fpsText then
                local fps = math.floor(frames / delta)
                fpsText.Text = "FPS: " .. fps
                
                -- Color the text based on FPS
                if fps >= 45 then
                    fpsText.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif fps >= 30 then
                    fpsText.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    fpsText.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            lastUpdate = currentTime
            frames = 0
        end
    end
    
    -- Connect Update
    game:GetService("RunService").RenderStepped:Connect(updateFpsCounter)
    
    -- Return controller
    return {
        show = createFpsCounter,
        hide = function()
            if fpsText and fpsText.Parent then
                fpsText.Parent:Destroy()
                fpsText = nil
            end
        end,
        isVisible = function()
            return fpsText ~= nil
        },
        toggle = function()
            if fpsText then
                fpsText.Parent:Destroy()
                fpsText = nil
            else
                createFpsCounter()
            end
        end
    }
end

-- Anti-AFK System
local function setupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local antiAFKConnection = nil
    
    local function enable()
        if antiAFKConnection then return end
        
        -- Connect to PlayerIdled event
        antiAFKConnection = localPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("Anti-AFK: Prevented idle kick")
        end)
        
        print("Anti-AFK: Enabled")
    end
    
    local function disable()
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
            print("Anti-AFK: Disabled")
        end
    end
    
    return {
        enable = enable,
        disable = disable,
        isEnabled = function()
            return antiAFKConnection ~= nil
        end,
        toggle = function()
            if antiAFKConnection then
                disable()
            else
                enable()
            end
        end
    end
end

-- Enhanced Main Initialization
local function initializeRiseEnhanced()
    -- Setup folder structure
    ensureFolderStructure()
    ensureVersionFiles()
    
    -- Load core libraries
    local GuiLibrary = loadGuiLibrary()
    local Universal = loadUniversal()
    
    -- Initialize performance optimization
    local renderOptimizer = optimizeRendering()
    
    -- Initialize FPS counter
    local fpsCounter = setupFpsCounter(GuiLibrary)
    
    -- Initialize Anti-AFK
    local antiAFK = setupAntiAFK()
    
    -- Detect game
    local gameInfo = detectGame()
    
    -- Load custom modules
    local customModules = loadCustomModules()
    
    -- Print version info to console
    print("Rise 6.0 Enhanced Initialized")
    print("Commit: " .. commitHash)
    print("Assets Version: " .. assetsVersion)
    print("Detected Game: " .. gameInfo.name .. " (ID: " .. gameInfo.id .. ")")
    
    -- Initialize GuiLibrary
    GuiLibrary:Init()
    
    -- Setup keybind hooks
    GuiLibrary:SetupKeyHooks()
    
    -- Create main GUI tabs
    local combatTab = GuiLibrary:CreateTab("Combat")
    local movementTab = GuiLibrary:CreateTab("Movement")
    local playerTab = GuiLibrary:CreateTab("Player")
    local renderTab = GuiLibrary:CreateTab("Render")
    local utilityTab = GuiLibrary:CreateTab("Utility")
    local worldTab = GuiLibrary:CreateTab("World")
    
    -- Enhance window title with game info
    local main = GuiLibrary.MainFrame
    if main and main:FindFirstChild("TitleBar") and main.TitleBar:FindFirstChild("Title") then
        main.TitleBar.Title.Text = "Rise 6.0 - " .. gameInfo.name
    end
    
    -- Combat Tab Sections
    local aimingSection = combatTab:CreateSection("Aiming")
    aimingSection:CreateToggle("Aimbot", false, function(state) end)
    aimingSection:CreateToggle("Triggerbot", false, function(state) end)
    aimingSection:CreateSlider("Smoothness", 0, 100, 50, function(value) end)
    aimingSection:CreateDropdown("Target Part", {"Head", "Torso", "Random"}, "Head", function(part) end)
    
    local clickingSection = combatTab:CreateSection("Clicking")
    clickingSection:CreateToggle("AutoClicker", false, function(state) end)
    clickingSection:CreateToggle("DelayBreak", false, function(state) end)
    clickingSection:CreateSlider("CPS", 1, 20, 10, function(value) end)
    clickingSection:CreateSlider("Random Variation", 0, 3, 1, function(value) end)
    
    local reachSection = combatTab:CreateSection("Reach")
    reachSection:CreateToggle("Reach", false, function(state) end)
    reachSection:CreateSlider("Distance", 3, 6, 3.5, function(value) end)
    
    -- Movement Tab Sections
    local speedSection = movementTab:CreateSection("Speed")
    speedSection:CreateToggle("Speed", false, function(state) end)
    speedSection:CreateSlider("Multiplier", 1, 10, 2, function(value) end)
    speedSection:CreateDropdown("Mode", {"Normal", "Strafe", "YPort", "Bhop"}, "Normal", function(selected) end)
    
    local flightSection = movementTab:CreateSection("Flight")
    flightSection:CreateToggle("Flight", false, function(state) end)
    flightSection:CreateSlider("Speed", 1, 10, 2, function(value) end)
    flightSection:CreateDropdown("Mode", {"Vanilla", "CFrame", "TP", "Velocity"}, "Vanilla", function(selected) end)
    
    local noFallSection = movementTab:CreateSection("Safety")
    noFallSection:CreateToggle("NoFall", false, function(state) end)
    noFallSection:CreateToggle("SafeWalk", false, function(state) end)
    
    -- Player Tab Sections
    local healthSection = playerTab:CreateSection("Health")
    healthSection:CreateToggle("Regen", false, function(state) end)
    healthSection:CreateSlider("Health", 0, 100, 100, function(value) end)
    
    local characterSection = playerTab:CreateSection("Character")
    characterSection:CreateToggle("Noclip", false, function(state) end)
    characterSection:CreateToggle("Anti-Void", false, function(state) end)
    
    -- Render Tab Sections
    local visualsSection = renderTab:CreateSection("Visuals")
    visualsSection:CreateToggle("Freecam", false, function(state) end)
    visualsSection:CreateToggle("Fullbright", false, function(state) end)
    visualsSection:CreateToggle("Show FPS", false, function(state)
        if state then
            fpsCounter.show()
        else
            fpsCounter.hide()
        end
    end)
    visualsSection:CreateSlider("FOV", 70, 120, 90, function(value) end)
    
    local espSection = renderTab:CreateSection("ESP")
    espSection:CreateToggle("ESP", false, function(state) end)
    espSection:CreateToggle("Box ESP", false, function(state) end)
    espSection:CreateToggle("Tracer ESP", false, function(state) end)
    espSection:CreateToggle("Name ESP", false, function(state) end)
    espSection:CreateColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color) end)
    
    -- Utility Tab Sections
    local gameSection = utilityTab:CreateSection("Game")
    gameSection:CreateToggle("Anti-AFK", false, function(state)
        if state then
            antiAFK.enable()
        else
            antiAFK.disable()
        end
    end)
    
    local otherSection = utilityTab:CreateSection("Other")
    otherSection:CreateButton("Copy Discord", function()
        setclipboard("https://discord.gg/riseclient")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rise Client",
            Text = "Discord link copied to clipboard!",
            Duration = 3
        })
    end)
    
    -- World Tab Sections
    local worldSection = worldTab:CreateSection("World")
    worldSection:CreateToggle("No Fog", false, function(state) end)
    worldSection:CreateToggle("Always Day", false, function(state) end)
    worldSection:CreateSlider("Time", 0, 24, 12, function(value) end)
    
    -- Apply Universal module hooks
    Universal:Init(GuiLibrary)
    
    -- Apply custom modules if they provide an initialization function
    for name, module in pairs(customModules) do
        if type(module.Init) == "function" then
            module:Init(GuiLibrary, Universal)
            print("Initialized custom module: " .. name)
        end
    end
    
    -- Connect events for optimization
    GuiLibrary.MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if GuiLibrary.MainFrame.Visible then
            renderOptimizer.lowerQuality()
        else
            renderOptimizer.restoreQuality()
        end
    end)
    
    -- Return the libraries and utilities for external use
    return {
        GuiLibrary = GuiLibrary,
        Universal = Universal,
        CustomModules = customModules,
        FpsCounter = fpsCounter,
        AntiAFK = antiAFK,
        GameInfo = gameInfo
    }
end

-- Start enhanced Rise
return initializeRiseEnhanced()
