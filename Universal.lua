--[[
    Rise 6.0-like GUI
    Universal Module - Provides cross-game functionality
]]

local Universal = {}
Universal.Hooks = {}
Universal.Connections = {}
Universal.Enabled = {}
Universal.HookedFunctions = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Initialize the module with GuiLibrary
function Universal:Init(GuiLibrary)
    self.GuiLibrary = GuiLibrary
    
    -- Connect character added event
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
        
        -- Re-enable any active modules that need character references
        for moduleName, enabled in pairs(self.Enabled) do
            if enabled and self[moduleName] and self[moduleName].CharacterHandler then
                self[moduleName].CharacterHandler(Character, Humanoid, HumanoidRootPart)
            end
        end
    end)
    
    -- Register universal modules
    self:RegisterMovementModules()
    self:RegisterCombatModules()
    self:RegisterRenderModules()
    self:RegisterUtilityModules()
    
    return self
end

-- Cleanup connections when needed
function Universal:Cleanup()
    for _, connection in pairs(self.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    -- Restore original functions
    for funcName, originalFunc in pairs(self.HookedFunctions) do
        if funcName:find(".") then
            local parts = funcName:split(".")
            local obj = _G
            
            for i = 1, #parts - 1 do
                obj = obj[parts[i]]
            end
            
            if obj then
                obj[parts[#parts]] = originalFunc
            end
        else
            _G[funcName] = originalFunc
        end
    end
    
    self.HookedFunctions = {}
    self.Connections = {}
end

-- Hook a function
function Universal:HookFunction(funcPath, hookFunc)
    local parts = funcPath:split(".")
    local obj = _G
    
    for i = 1, #parts - 1 do
        obj = obj[parts[i]]
        if not obj then return false end
    end
    
    local lastPart = parts[#parts]
    local originalFunc = obj[lastPart]
    
    if not originalFunc or type(originalFunc) ~= "function" then
        return false
    end
    
    -- Store original function
    self.HookedFunctions[funcPath] = originalFunc
    
    -- Replace with hook
    obj[lastPart] = hookFunc(originalFunc)
    
    return true
end

-- Register Movement Modules
function Universal:RegisterMovementModules()
    -- Speed module
    self.Speed = {
        Enabled = false,
        Multiplier = 2,
        Mode = "Normal",
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["Speed"] = true
            
            local speedConnection
            speedConnection = RunService.Heartbeat:Connect(function()
                if not Humanoid then return end
                
                if self.Mode == "Normal" then
                    Humanoid.WalkSpeed = 16 * self.Multiplier
                elseif self.Mode == "Strafe" then
                    -- Strafe mode - boosts speed when moving sideways
                    local moveDirection = Humanoid.MoveDirection
                    local lookVector = HumanoidRootPart.CFrame.LookVector
                    local dot = math.abs(moveDirection:Dot(lookVector))
                    
                    -- Less dot product means more sideways movement
                    local sidewaysMultiplier = 1 + (1 - dot) * self.Multiplier
                    Humanoid.WalkSpeed = 16 * sidewaysMultiplier
                elseif self.Mode == "YPort" then
                    -- YPort mode - teleports up and down to bypass speed checks
                    Humanoid.WalkSpeed = 16 * self.Multiplier
                    
                    -- Apply Y-axis teleportation
                    if Humanoid.MoveDirection.Magnitude > 0 then
                        local originalY = HumanoidRootPart.Position.Y
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 0.5, 0)
                        task.wait(0.05)
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, originalY - HumanoidRootPart.Position.Y, 0)
                    end
                elseif self.Mode == "Bhop" then
                    -- Bhop mode - jumps automatically for increased speed
                    Humanoid.WalkSpeed = 16 * self.Multiplier
                    
                    -- Apply jumping if grounded
                    if Humanoid:GetState() == Enum.HumanoidStateType.Running and 
                       Humanoid.MoveDirection.Magnitude > 0 then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            
            -- Store connection for cleanup
            table.insert(Universal.Connections, speedConnection)
            
            -- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Humanoid = hum
                HumanoidRootPart = hrp
            end
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["Speed"] = false
            
            -- Reset walk speed
            if Humanoid then
                Humanoid.WalkSpeed = 16
            end
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetMultiplier = function(self, value)
            self.Multiplier = value
        end,
        
        SetMode = function(self, mode)
            self.Mode = mode
        end
    }
    
    -- Flight module
    self.Flight = {
        Enabled = false,
        Speed = 2,
        Mode = "Vanilla",
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["Flight"] = true
            
            local originalGravity = workspace.Gravity
            local flyConnection
            
            if self.Mode == "Vanilla" then
                -- Vanilla mode - just disables gravity and allows WASD movement in air
                workspace.Gravity = 0
                
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.P = 1000
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = HumanoidRootPart
                
                -- Movement control
                flyConnection = RunService.RenderStepped:Connect(function()
                    local moveDirection = Humanoid.MoveDirection
                    local camera = workspace.CurrentCamera
                    local speed = self.Speed * 20
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        bodyVelocity.Velocity = Vector3.new(moveDirection.X * speed, speed, moveDirection.Z * speed)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        bodyVelocity.Velocity = Vector3.new(moveDirection.X * speed, -speed, moveDirection.Z * speed)
                    else
                        bodyVelocity.Velocity = Vector3.new(moveDirection.X * speed, 0, moveDirection.Z * speed)
                    end
                end)
                
                -- Store for cleanup
                self._bodyVelocity = bodyVelocity
            elseif self.Mode == "CFrame" then
                -- CFrame mode - modifies character CFrame directly
                workspace.Gravity = 0
                
                flyConnection = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    local moveDirection = Humanoid.MoveDirection
                    local speed = self.Speed * 2
                    
                    -- Calculate movement vector based on camera direction
                    local cameraLook = camera.CFrame.LookVector
                    local cameraRight = camera.CFrame.RightVector
                    
                    local movementVector = Vector3.new(0, 0, 0)
                    
                    if moveDirection.Magnitude > 0 then
                        movementVector = movementVector + moveDirection * speed
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        movementVector = movementVector + Vector3.new(0, speed, 0)
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        movementVector = movementVector + Vector3.new(0, -speed, 0)
                    end
                    
                    -- Apply movement
                    if movementVector.Magnitude > 0 then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + movementVector * 0.1
                    end
                end)
            elseif self.Mode == "TP" then
                -- TP mode - teleports small distances for smoother flight
                workspace.Gravity = 0
                
                flyConnection = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    local moveDirection = Humanoid.MoveDirection
                    local speed = self.Speed * 2
                    
                    local movementVector = Vector3.new(0, 0, 0)
                    
                    if moveDirection.Magnitude > 0 then
                        movementVector = movementVector + moveDirection * speed
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        movementVector = movementVector + Vector3.new(0, speed, 0)
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        movementVector = movementVector + Vector3.new(0, -speed, 0)
                    end
                    
                    -- Apply movement via teleport
                    if movementVector.Magnitude > 0 then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + movementVector * 0.1
                    end
                end)
            elseif self.Mode == "Velocity" then
                -- Velocity mode - manipulates the HumanoidRootPart velocity
                workspace.Gravity = 0
                
                flyConnection = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    local moveDirection = Humanoid.MoveDirection
                    local speed = self.Speed * 20
                    
                    local movementVector = Vector3.new(0, 0, 0)
                    
                    if moveDirection.Magnitude > 0 then
                        movementVector = movementVector + moveDirection * speed
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        movementVector = movementVector + Vector3.new(0, speed, 0)
                    end
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        movementVector = movementVector + Vector3.new(0, -speed, 0)
                    end
                    
                    -- Apply velocity
                    HumanoidRootPart.Velocity = movementVector
                end)
            end
            
            -- Store connection for cleanup
            table.insert(Universal.Connections, flyConnection)
            
            -- Character handler for when character changes
            self.Character-- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Humanoid = hum
                HumanoidRootPart = hrp
                
                if self.Mode == "Vanilla" and self._bodyVelocity then
                    self._bodyVelocity:Destroy()
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVelocity.P = 1000
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = HumanoidRootPart
                    self._bodyVelocity = bodyVelocity
                end
                
                workspace.Gravity = 0
            end
            
            -- Store original gravity for cleanup
            self._originalGravity = originalGravity
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["Flight"] = false
            
            -- Restore gravity
            workspace.Gravity = self._originalGravity or 196.2
            
            -- Remove BodyVelocity
            if self._bodyVelocity then
                self._bodyVelocity:Destroy()
                self._bodyVelocity = nil
            end
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetSpeed = function(self, value)
            self.Speed = value
        end,
        
        SetMode = function(self, mode)
            if self.Enabled then
                self:Disable()
                self.Mode = mode
                self:Enable()
            else
                self.Mode = mode
            end
        end
    }
    
    -- NoFall module
    self.NoFall = {
        Enabled = false,
        Mode = "Packet",
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["NoFall"] = true
            
            local noFallConnection
            
            if self.Mode == "Packet" then
                -- Hook the network functions to spoof fall damage packets
                Universal:HookFunction("game.NetworkClient.Send", function(originalFunc)
                    return function(self, packet, ...)
                        -- Check if packet is related to fall damage
                        if packet and typeof(packet) == "Instance" and packet.ClassName == "RemoteEvent" and 
                           (packet.Name:lower():find("fall") or packet.Name:lower():find("damage")) then
                            return nil -- Block the packet
                        end
                        
                        return originalFunc(self, packet, ...)
                    end
                end)
            elseif self.Mode == "Velocity" then
                -- Prevent velocity-based fall damage by canceling Y velocity when falling
                noFallConnection = RunService.Heartbeat:Connect(function()
                    if not HumanoidRootPart then return end
                    
                    -- If falling with significant velocity, cancel it
                    if HumanoidRootPart.Velocity.Y < -50 then
                        HumanoidRootPart.Velocity = Vector3.new(
                            HumanoidRootPart.Velocity.X,
                            -50, -- Cap negative Y velocity
                            HumanoidRootPart.Velocity.Z
                        )
                    end
                end)
                
                table.insert(Universal.Connections, noFallConnection)
            elseif self.Mode == "Ground" then
                -- Constantly tell the server we're on the ground
                noFallConnection = RunService.Heartbeat:Connect(function()
                    if not Humanoid then return end
                    
                    -- Force the humanoid state to be grounded
                    if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
                
                table.insert(Universal.Connections, noFallConnection)
            end
            
            -- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Humanoid = hum
                HumanoidRootPart = hrp
            end
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["NoFall"] = false
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetMode = function(self, mode)
            if self.Enabled then
                self:Disable()
                self.Mode = mode
                self:Enable()
            else
                self.Mode = mode
            end
        end
    }
    
    -- HighJump module
    self.HighJump = {
        Enabled = false,
        Power = 5,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["HighJump"] = true
            
            if Humanoid then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = 50 * self.Power
                
                -- Make the player jump immediately
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                
                -- Disable after jump
                task.delay(0.5, function()
                    self:Disable()
                end)
            end
            
            -- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Humanoid = hum
                HumanoidRootPart = hrp
            end
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["HighJump"] = false
            
            if Humanoid then
                Humanoid.JumpPower = 50
            end
        end,
        
        SetPower = function(self, value)
            self.Power = value
        end
    }
end

-- Register Combat Modules
function Universal:RegisterCombatModules()
    -- Killaura module
    self.Killaura = {
        Enabled = false,
        Range = 5,
        TargetPlayers = true,
        TargetNPCs = true,
        Delay = 0.2,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["Killaura"] = true
            
            local lastAttack = 0
            
            local killauraConnection = RunService.Heartbeat:Connect(function()
                if not HumanoidRootPart then return end
                
                -- Respect attack delay
                if tick() - lastAttack < self.Delay then return end
                
                -- Find targets in range
                local targets = {}
                
                -- Check for player targets
                if self.TargetPlayers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and 
                           player.Character:FindFirstChild("HumanoidRootPart") and
                           player.Character:FindFirstChild("Humanoid") and
                           player.Character.Humanoid.Health > 0 then
                            
                            local distance = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                            if distance <= self.Range then
                                table.insert(targets, player.Character)
                            end
                        end
                    end
                end
                
                -- Check for NPC targets
                if self.TargetNPCs then
                    for _, model in pairs(workspace:GetChildren()) do
                        if model:IsA("Model") and model ~= Character and 
                           model:FindFirstChild("HumanoidRootPart") and
                           model:FindFirstChild("Humanoid") and
                           model.Humanoid.Health > 0 then
                            
                            local distance = (model.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                            if distance <= self.Range then
                                table.insert(targets, model)
                            end
                        end
                    end
                end
                
                -- Attack closest target
                if #targets > 0 then
                    -- Sort by distance
                    table.sort(targets, function(a, b)
                        local distA = (a.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        local distB = (b.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        return distA < distB
                    end)
                    
                    -- Attack the closest target
                    local target = targets[1]
                    
                    -- Face the target
                    local targetPos = target.HumanoidRootPart.Position
                    local lookVector = (targetPos - HumanoidRootPart.Position).Unit
                    HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, targetPos)
                    
                    -- Find attack methods - typically games have a remote event for attacks
                    local attackRemote = nil
                    for _, remote in pairs(game:GetDescendants()) do
                        if remote:IsA("RemoteEvent") and 
                          (remote.Name:lower():find("attack") or 
                           remote.Name:lower():find("hit") or 
                           remote.Name:lower():find("damage")) then
                            attackRemote = remote
                            break
                        end
                    end
                    
                    -- Use the appropriate attack method
                    if attackRemote then
                        attackRemote:FireServer(target)
                    else
                        -- Fallback to virtual input method
                        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    end
                    
                    lastAttack = tick()
                end
            end)
            
            table.insert(Universal.Connections, killauraConnection)
            
            -- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Character = char
                Humanoid = hum
                HumanoidRootPart = hrp
            end
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["Killaura"] = false
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetRange = function(self, value)
            self.Range = value
        end,
        
        SetDelay = function(self, value)
            self.Delay = value
        end,
        
        SetTargetPlayers = function(self, value)
            self.TargetPlayers = value
        end,
        
        SetTargetNPCs = function(self, value)
            self.TargetNPCs = value
        end
    }
    
    -- AutoClicker module
    self.AutoClicker = {
        Enabled = false,
        CPS = 10,
        RightClick = false,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["AutoClicker"] = true
            
            -- Setup click loop
            local clickConnection = RunService.Heartbeat:Connect(function()
                if not self.Enabled then return end
                
                if self.RightClick then
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                else
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end
                
                -- Wait based on CPS
                task.wait(1 / self.CPS - 0.05)
            end)
            
            table.insert(Universal.Connections, clickConnection)
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["AutoClicker"] = false
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetCPS = function(self, value)
            self.CPS = value
        end,
        
        SetRightClick = function(self, value)
            self.RightClick = value
        end
    }
end

-- Register Render Modules
function Universal:RegisterRenderModules()
    -- ESP module
    self.ESP = {
        Enabled = false,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBoxes = true,
        ShowTracers = false,
        TeamCheck = true,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["ESP"] = true
            
            -- Create UI container for ESP
            local gui = Instance.new("ScreenGui")
            gui.Name = "ESPGui"
            gui.ResetOnSpawn = false
            gui.Parent = game:GetService("CoreGui")
            
            -- Store for cleanup
            self._gui = gui
            
            -- ESP rendering
            local espConnection = RunService.RenderStepped:Connect(function()
                -- Clear previous drawings
                for _, child in pairs(gui:GetChildren()) do
                    child:Destroy()
                end
                
                local camera = workspace.CurrentCamera
                
                -- Draw ESP for all players
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and 
                       player.Character:FindFirstChild("HumanoidRootPart") and
                       player.Character:FindFirstChild("Humanoid") then
                        
                        -- Check teams if enabled
                        if self.TeamCheck and player.Team == LocalPlayer.Team then
                            continue
                        end
                        
                        local hrp = player.Character.HumanoidRootPart
                        local humanoid = player.Character.Humanoid
                        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                        
                        if onScreen then
                            -- Calculate distance
                            local distance = (hrp.Position - camera.CFrame.Position).Magnitude
                            distance = math.floor(distance)
                            
                            -- Draw name/info
                            if self.ShowNames or self.ShowDistance or self.ShowHealth then
                                local infoText = ""
                                
                                if self.ShowNames then
                                    infoText = player.Name
                                end
                                
                                if self.ShowDistance then
                                    infoText = infoText .. " [" .. distance .. "m]"
                                end
                                
                                if self.ShowHealth then
                                    infoText = infoText .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "]"
                                end
                                
                                local textLabel = Instance.new("TextLabel")
                                textLabel.Size = UDim2.new(0, 200, 0, 25)
                                textLabel.Position = UDim2.new(0, pos.X - 100, 0, pos.Y - 40)
                                textLabel.BackgroundTransparency = 1
                                textLabel.Text = infoText
                                textLabel.TextColor3 = Color3.new(1, 1, 1)
                                textLabel.TextStrokeTransparency = 0.5
                                textLabel.TextSize = 14
                                textLabel.Font = Enum.Font.SourceSansBold
                                textLabel.Parent = gui
                            end
                            
                            -- Draw box
                            if self.ShowBoxes then
                                local boxSize = Vector2.new(1000 / distance, 2000 / distance)
                                boxSize = Vector2.new(math.clamp(boxSize.X, 10, 100), math.clamp(boxSize.Y, 20, 200))
                                
                                local box = Instance.new("Frame")
                                box.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
                                box.Position = UDim2.new(0, pos.X - boxSize.X/2, 0, pos.Y - boxSize.Y/2)
                                box.BackgroundTransparency = 1
                                box.BorderSizePixel = 2
                                box.BorderColor3 = Color3.new(1, 0, 0)
                                box.Parent = gui
                            end
                            
                            -- Draw tracer
                            if self.ShowTracers then
                                local line = Instance.new("Frame")
                                line.BackgroundColor3 = Color3.new(1, 0, 0)
                                line.BorderSizePixel = 0
                                line.Parent = gui
                                
                                -- Calculate line position
                                local screenSize = camera.ViewportSize
                                local fromPosition = Vector2.new(screenSize.X / 2, screenSize.Y)
                                local toPosition = Vector2.new(pos.X, pos.Y)
                                
                                -- Calculate line properties
                                local distance = (fromPosition - toPosition).Magnitude
                                local direction = (toPosition - fromPosition).Unit
                                local angle = math.atan2(direction.Y, direction.X)
                                
                                -- Set line properties
                                line.Size = UDim2.new(0, distance, 0, 2)
                                line.Position = UDim2.new(0, fromPosition.X, 0, fromPosition.Y)
                                line.Rotation = math.deg(angle)
                                line.AnchorPoint = Vector2.new(0, 0.5)
                            end
                        end
                    end
                end
            end)
            
            table.insert(Universal.Connections, espConnection)
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["ESP"] = false
            
            -- Remove ESP GUI
            if self._gui then
                self._gui:Destroy()
                self._gui = nil
            end
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end,
        
        SetShowNames = function(self, value)
            self.ShowNames = value
        end,
        
        SetShowDistance = function(self, value)
            self.ShowDistance = value
        end,
        
        SetShowHealth = function(self, value)
            self.ShowHealth = value
        end,
        
        SetShowBoxes = function(self, value)
            self.ShowBoxes = value
        end,
        
        SetShowTracers = function(self, value)
            self.ShowTracers = value
        end,
        
        SetTeamCheck = function(self, value)
            self.TeamCheck = value
        end
    }
end

-- Register Utility Modules
function Universal:RegisterUtilityModules()
    -- InfiniteJump module
    self.InfiniteJump = {
        Enabled = false,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["InfiniteJump"] = true
            
            local jumpConnection = UserInputService.JumpRequest:Connect(function()
                if Humanoid and Humanoid.Health > 0 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            
            table.insert(Universal.Connections, jumpConnection)
            
            -- Character handler for when character changes
            self.CharacterHandler = function(char, hum, hrp)
                Humanoid = hum
                HumanoidRootPart = hrp
            end
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["InfiniteJump"] = false
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end
    }
    
    -- AntiAFK module
    self.AntiAFK = {
        Enabled = false,
        
        Enable = function(self)
            if self.Enabled then return end
            self.Enabled = true
            Universal.Enabled["AntiAFK"] = true
            
            -- Hook idle disconnect functions
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Disable()
            end
            
            -- Simulate input occasionally to prevent AFK
            local antiAFKConnection = RunService.Heartbeat:Connect(function()
                local randomWait = math.random(60, 180)
                task.wait(randomWait)
                
                -- Simulate random input
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            
            table.insert(Universal.Connections, antiAFKConnection)
        end,
        
        Disable = function(self)
            if not self.Enabled then return end
            self.Enabled = false
            Universal.Enabled["AntiAFK"] = false
            
            -- Disconnect events
            for i, connection in pairs(Universal.Connections) do
                if connection.Connected then
                    connection:Disconnect()
                    table.remove(Universal.Connections, i)
                end
            end
        end
    }
end

return Universal
