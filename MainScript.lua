--[[
    Rise 6.0-like GUI
    Main Entry Point Script
]]

-- Load executor-specific libraries
local httpService = game:GetService("HttpService")

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

-- Main initialization
local function initializeRise()
    -- Setup folder structure
    ensureFolderStructure()
    ensureVersionFiles()
    
    -- Load core libraries
    local GuiLibrary = loadGuiLibrary()
    local Universal = loadUniversal()
    
    -- Print version info to console
    print("Rise 6.0 Initialized")
    print("Commit: " .. commitHash)
    print("Assets Version: " .. assetsVersion)
    
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
    
    -- Combat Tab Sections
    local aimingSection = combatTab:CreateSection("Aiming")
    aimingSection:CreateToggle("Aimbot", false, function(state) end)
    aimingSection:CreateToggle("Triggerbot", false, function(state) end)
    aimingSection:CreateSlider("Smoothness", 0, 100, 50, function(value) end)
    
    local clickingSection = combatTab:CreateSection("Clicking")
    clickingSection:CreateToggle("AutoClicker", false, function(state) end)
    clickingSection:CreateToggle("DelayBreak", false, function(state) end)
    clickingSection:CreateSlider("CPS", 1, 20, 10, function(value) end)
    
    -- Movement Tab Sections
    local speedSection = movementTab:CreateSection("Speed")
    speedSection:CreateToggle("Speed", false, function(state) end)
    speedSection:CreateSlider("Multiplier", 1, 10, 2, function(value) end)
    speedSection:CreateDropdown("Mode", {"Normal", "Strafe", "YPort", "Bhop"}, "Normal", function(selected) end)
    
    local flightSection = movementTab:CreateSection("Flight")
    flightSection:CreateToggle("Flight", false, function(state) end)
    flightSection:CreateSlider("Speed", 1, 10, 2, function(value) end)
    flightSection:CreateDropdown("Mode", {"Vanilla", "CFrame", "TP", "Velocity"}, "Vanilla", function(selected) end)
    
    -- Player Tab Sections
    local healthSection = playerTab:CreateSection("Health")
    healthSection:CreateToggle("Regen", false, function(state) end)
    healthSection:CreateSlider("Health", 0, 100, 100, function(value) end)
    
    local visualsSection = playerTab:CreateSection("Visuals")
    visualsSection:CreateToggle("Freecam", false, function(state) end)
    visualsSection:CreateToggle("Fullbright", false, function(state) end)
    visualsSection:CreateSlider("FOV", 70, 120, 90, function(value) end)
    
    -- Apply Universal module hooks
    Universal:Init(GuiLibrary)
    
    -- Return the libraries for external use
    return {
        GuiLibrary = GuiLibrary,
        Universal = Universal
    }
end

-- Start Rise
return initializeRise()
