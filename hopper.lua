-- Auto Server Hopper - automatic hop every 3 seconds
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Safety check
if not LocalPlayer then
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

-- Global variables for state preservation
if not _G.AutoHopper then
    _G.AutoHopper = {
        Enabled = true,
        HopCount = 0,
        LastHopTime = 0,
        HopInterval = 3  -- Changed from 2 to 3 seconds
    }
end

local Hopper = _G.AutoHopper

-- Safe wait function
local function SafeWait(seconds)
    local start = tick()
    repeat task.wait() until tick() - start >= seconds
end

-- Function for forced server hop
local function ForceHop()
    Hopper.HopCount = Hopper.HopCount + 1
    Hopper.LastHopTime = tick()
    
    print("🔄 TUFF FINDER " .. Hopper.HopCount)
    
    local success, errorMsg = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    
    if success then
        print("🎯 Moving to next server...")
        return true
    else
        print("❌ Teleport error: " .. tostring(errorMsg))
        -- Try alternative method
        local success2 = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end)
        return success2
    end
end

-- Main auto-hop function
local function StartAutoHop()
    if not Hopper.Enabled then return end
    
    print("FINDER ACTIVATED")
    print("Finder status: " .. Hopper.HopCount)
    print("Interval: 3 sec")  -- Updated message
    
    -- Start in separate coroutine
    coroutine.wrap(function()
        while Hopper.Enabled and task.wait() do
            if not Hopper.Enabled then break end
            
            -- Wait 3 seconds with indication (changed from 2 to 3)
            local waitTime = Hopper.HopInterval
            while waitTime > 0 and Hopper.Enabled do
                waitTime = waitTime - 1
                SafeWait(1)
            end
            
            if Hopper.Enabled then
                local success = ForceHop()
                if not success then
                    print("Retrying in 5 seconds...")
                    SafeWait(5)
                end
            end
        end
    end)()
end

-- Create GUI with control buttons
local function CreateStatusGUI()
    -- Remove old GUI if exists
    if LocalPlayer:FindFirstChild("PlayerGui") then
        local oldGui = LocalPlayer.PlayerGui:FindFirstChild("AutoHopperGUI")
        if oldGui then
            oldGui:Destroy()
        end
    end

    -- Wait for PlayerGui creation
    if not LocalPlayer:FindFirstChild("PlayerGui") then
        LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local StatusLabel = Instance.new("TextLabel")
    local ToggleButton = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")
    local CountdownLabel = Instance.new("TextLabel")
    
    ScreenGui.Name = "AutoHopperGUI"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    Frame.Name = "MainFrame"
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
    Frame.Size = UDim2.new(0, 280, 0, 180)
    Frame.Active = true
    Frame.Draggable = true
    
    -- Style for elements
    local function CreateLabel(name, position, size, text)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Parent = Frame
        label.BackgroundTransparency = 1
        label.Position = position
        label.Size = size
        label.Font = Enum.Font.GothamSemibold
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.TextWrapped = true
        return label
    end
    
    Title.Name = "Title"
    Title.Parent = Frame
    Title.BackgroundColor3 = Hopper.Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Font = Enum.Font.GothamBold
    Title.Text = Hopper.Enabled and "🔥 FINDER ACTIVE" or "⏸️ FINDER STOPPED"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    StatusLabel = CreateLabel("StatusLabel", UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.9, 0, 0.3, 0), "")
    
    CountdownLabel = CreateLabel("CountdownLabel", UDim2.new(0.05, 0, 0.55, 0), UDim2.new(0.9, 0, 0.2, 0), "")
    CountdownLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    CountdownLabel.TextSize = 18
    
    local function CreateButton(name, position, size, text, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = Frame
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Position = position
        button.Size = size
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        return button
    end
    
    ToggleButton = CreateButton("ToggleButton", UDim2.new(0.05, 0, 0.75, 0), UDim2.new(0.6, 0, 0.2, 0), 
        Hopper.Enabled and "⏸️ STOP" or "▶️ START",
        Hopper.Enabled and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 180, 60))
    
    CloseButton = CreateButton("CloseButton", UDim2.new(0.7, 0, 0.75, 0), UDim2.new(0.25, 0, 0.2, 0), "❌", Color3.fromRGB(80, 80, 80))
    
    -- GUI update function
    local function UpdateGUI()
        Title.Text = Hopper.Enabled and "🔥 FINDER ACTIVE" or "⏸️ FINDER STOPPED"
        Title.BackgroundColor3 = Hopper.Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        
        StatusLabel.Text = string.format("Hops: %d\nInterval: 3 seconds", Hopper.HopCount)  -- Updated message
        StatusLabel.TextColor3 = Hopper.Enabled and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 200, 200)
        
        ToggleButton.Text = Hopper.Enabled and "⏸️ STOP" or "▶️ START"
        ToggleButton.BackgroundColor3 = Hopper.Enabled and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 180, 60)
    end
    
    -- Toggle button handler
    ToggleButton.MouseButton1Click:Connect(function()
        Hopper.Enabled = not Hopper.Enabled
        
        if Hopper.Enabled then
            print("▶️ FINDER STARTED!")
            StartAutoHop()
        else
            print("⏸️ FINDER STOPPED")
        end
        
        UpdateGUI()
    end)
    
    -- Close GUI handler
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        print("📱 GUI closed")
    end)
    
    -- Update countdown
    spawn(function()
        while ScreenGui.Parent and Hopper.Enabled do
            CountdownLabel.Text = "Next hop in: 3s"  -- Updated
            SafeWait(1)
            CountdownLabel.Text = "Next hop in: 2s"  -- Updated
            SafeWait(1)
            CountdownLabel.Text = "Next hop in: 1s"
            SafeWait(1)
        end
        CountdownLabel.Text = "STOPPED"
    end)
    
    UpdateGUI()
    return ScreenGui
end

-- Chat commands for control
local function SetupChatCommands()
    LocalPlayer.Chatted:Connect(function(message)
        local msg = string.lower(message)
        
        if msg == ":stop" then
            Hopper.Enabled = false
            print("⏸️ AUTO-HOP STOPPED")
        elseif msg == ":start" then
            Hopper.Enabled = true
            print("▶️ AUTO-HOP RESUMED!")
            StartAutoHop()
        elseif msg == ":toggle" then
            Hopper.Enabled = not Hopper.Enabled
            if Hopper.Enabled then
                print("▶️ AUTO-HOP RESUMED!")
                StartAutoHop()
            else
                print("⏸️ AUTO-HOP STOPPED")
            end
        elseif msg == ":status" then
            print("📊 AUTO-HOP: " .. (Hopper.Enabled and "🔴 ACTIVE" or "⏸️ STOPPED"))
            print("🔢 Hops: " .. Hopper.HopCount)
            print("⏱️ Interval: 3 seconds")  -- Updated message
        elseif msg == ":gui" then
            CreateStatusGUI()
        elseif msg == ":hop" then
            print("⚡ Forced hop...")
            ForceHop()
        elseif msg == ":help" then
            print("💬 AUTO-HOP COMMANDS:")
            print(":start - start hopper")
            print(":stop - stop hopper") 
            print(":toggle - toggle state")
            print(":status - show status")
            print(":gui - show GUI")
            print(":hop - force hop")
        end
    end)
end

-- Main initialization
local function Initialize()
    print("🎯 INITIALIZING AUTO-HOPPER...")
    
    -- Wait for player to fully load
    while not LocalPlayer do
        task.wait(0.1)
        LocalPlayer = Players.LocalPlayer
    end
    
    -- Setup chat commands
    SetupChatCommands()
    
    -- Create GUI
    local success, err = pcall(CreateStatusGUI)
    if not success then
        print("⚠️ GUI creation error: " .. tostring(err))
    end
    
    print("🔥 AUTO-HOPPER SUCCESSFULLY LOADED!")
    print("⏱️ Interval: 3 seconds")  -- Updated message
    print("💬 Type :help for command list")
    
    -- Start auto-hop
    if Hopper.Enabled then
        task.delay(3, StartAutoHop)  -- Updated from 2 to 3
    end
end

-- Run initialization with protection
local success, errorMsg = pcall(Initialize)
if not success then
    warn("❌ Initialization error: " .. tostring(errorMsg))
    -- Alternative startup
    task.spawn(Initialize)
end

-- Error protection
game:GetService("ScriptContext").Error:Connect(function(message)
    -- Ignore non-critical errors
end)
