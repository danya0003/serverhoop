-- Auto Server Hopper - автоматический хоп каждые 2 секунды
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Проверка безопасности
if not LocalPlayer then
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

-- Глобальные переменные для сохранения состояния
if not _G.AutoHopper then
    _G.AutoHopper = {
        Enabled = true,
        HopCount = 0,
        LastHopTime = 0
    }
end

local Hopper = _G.AutoHopper

-- Функция безопасного ожидания
local function SafeWait(seconds)
    local start = tick()
    repeat task.wait() until tick() - start >= seconds
end

-- Функция для принудительного перехода на другой сервер
local function ForceHop()
    Hopper.HopCount = Hopper.HopCount + 1
    Hopper.LastHopTime = tick()
    
    print("🔄 АВТО-ХОП #" .. Hopper.HopCount)
    
    local success, errorMsg = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    
    if success then
        print("🎯 Переход на следующий сервер...")
        return true
    else
        print("❌ Ошибка телепортации: " .. tostring(errorMsg))
        -- Пробуем альтернативный метод
        local success2 = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end)
        return success2
    end
end

-- Основная функция авто-хоппинга
local function StartAutoHop()
    if not Hopper.Enabled then return end
    
    print("🚀 АВТО-ХОП АКТИВИРОВАН!")
    print("📊 Счетчик хопов: " .. Hopper.HopCount)
    print("⏱️ Интервал: 2 секунды")
    
    -- Запускаем в отдельной корутине
    coroutine.wrap(function()
        while Hopper.Enabled and task.wait() do
            if not Hopper.Enabled then break end
            
            -- Ожидание 2 секунды с индикацией
            local waitTime = 2
            while waitTime > 0 and Hopper.Enabled do
                waitTime = waitTime - 1
                SafeWait(1)
            end
            
            if Hopper.Enabled then
                local success = ForceHop()
                if not success then
                    print("⚠️ Повторная попытка через 5 секунд...")
                    SafeWait(5)
                end
            end
        end
    end)()
end

-- Создаем GUI с кнопкой продолжения
local function CreateStatusGUI()
    -- Удаляем старый GUI если есть
    if LocalPlayer:FindFirstChild("PlayerGui") then
        local oldGui = LocalPlayer.PlayerGui:FindFirstChild("AutoHopperGUI")
        if oldGui then
            oldGui:Destroy()
        end
    end

    -- Ждем создания PlayerGui
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
    
    -- Стиль для элементов
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
    Title.Text = Hopper.Enabled and "🔥 АВТО-ХОП АКТИВЕН" or "⏸️ АВТО-ХОП ОСТАНОВЛЕН"
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
        Hopper.Enabled and "⏸️ ОСТАНОВИТЬ" or "▶️ ПРОДОЛЖИТЬ",
        Hopper.Enabled and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 180, 60))
    
    CloseButton = CreateButton("CloseButton", UDim2.new(0.7, 0, 0.75, 0), UDim2.new(0.25, 0, 0.2, 0), "❌", Color3.fromRGB(80, 80, 80))
    
    -- Функция обновления GUI
    local function UpdateGUI()
        Title.Text = Hopper.Enabled and "🔥 АВТО-ХОП АКТИВЕН" or "⏸️ АВТО-ХОП ОСТАНОВЛЕН"
        Title.BackgroundColor3 = Hopper.Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        
        StatusLabel.Text = string.format("Хопов: %d\nИнтервал: 2 секунды", Hopper.HopCount)
        StatusLabel.TextColor3 = Hopper.Enabled and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 200, 200)
        
        ToggleButton.Text = Hopper.Enabled and "⏸️ ОСТАНОВИТЬ" or "▶️ ПРОДОЛЖИТЬ"
        ToggleButton.BackgroundColor3 = Hopper.Enabled and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 180, 60)
    end
    
    -- Обработчик кнопки переключения
    ToggleButton.MouseButton1Click:Connect(function()
        Hopper.Enabled = not Hopper.Enabled
        
        if Hopper.Enabled then
            print("▶️ АВТО-ХОП ПРОДОЛЖЕН!")
            StartAutoHop()
        else
            print("⏸️ АВТО-ХОП ОСТАНОВЛЕН")
        end
        
        UpdateGUI()
    end)
    
    -- Обработчик закрытия GUI
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        print("📱 GUI закрыт")
    end)
    
    -- Обновляем счетчик
    spawn(function()
        while ScreenGui.Parent and Hopper.Enabled do
            CountdownLabel.Text = "Следующий хоп через: 2с"
            SafeWait(1)
            CountdownLabel.Text = "Следующий хоп через: 1с"
            SafeWait(1)
        end
        CountdownLabel.Text = "ОСТАНОВЛЕНО"
    end)
    
    UpdateGUI()
    return ScreenGui
end

-- Команды в чат для управления
local function SetupChatCommands()
    LocalPlayer.Chatted:Connect(function(message)
        local msg = string.lower(message)
        
        if msg == ":stop" then
            Hopper.Enabled = false
            print("⏸️ АВТО-ХОП ОСТАНОВЛЕН")
        elseif msg == ":start" then
            Hopper.Enabled = true
            print("▶️ АВТО-ХОП ПРОДОЛЖЕН!")
            StartAutoHop()
        elseif msg == ":toggle" then
            Hopper.Enabled = not Hopper.Enabled
            if Hopper.Enabled then
                print("▶️ АВТО-ХОП ПРОДОЛЖЕН!")
                StartAutoHop()
            else
                print("⏸️ АВТО-ХОП ОСТАНОВЛЕН")
            end
        elseif msg == ":status" then
            print("📊 АВТО-ХОП: " .. (Hopper.Enabled and "🔴 АКТИВЕН" or "⏸️ ОСТАНОВЛЕН"))
            print("🔢 Хопов: " .. Hopper.HopCount)
            print("⏱️ Интервал: 2 секунды")
        elseif msg == ":gui" then
            CreateStatusGUI()
        elseif msg == ":hop" then
            print("⚡ Принудительный хоп...")
            ForceHop()
        elseif msg == ":help" then
            print("💬 КОМАНДЫ АВТО-ХОП:")
            print(":start - запустить")
            print(":stop - остановить") 
            print(":toggle - переключить")
            print(":status - статус")
            print(":gui - показать GUI")
            print(":hop - принудительный хоп")
        end
    end)
end

-- Основная инициализация
local function Initialize()
    print("🎯 ИНИЦИАЛИЗАЦИЯ АВТО-ХОППЕРА...")
    
    -- Ждем полной загрузки игрока
    while not LocalPlayer do
        task.wait(0.1)
        LocalPlayer = Players.LocalPlayer
    end
    
    -- Настраиваем команды чата
    SetupChatCommands()
    
    -- Создаем GUI
    local success, err = pcall(CreateStatusGUI)
    if not success then
        print("⚠️ Ошибка создания GUI: " .. tostring(err))
    end
    
    print("🔥 АВТО-ХОППЕР УСПЕШНО ЗАГРУЖЕН!")
    print("⏱️ Интервал: 2 секунды")
    print("💬 Напишите :help для списка команд")
    
    -- Запускаем авто-хоп
    if Hopper.Enabled then
        task.delay(2, StartAutoHop)
    end
end

-- Запускаем инициализацию с защитой
local success, errorMsg = pcall(Initialize)
if not success then
    warn("❌ Ошибка инициализации: " .. tostring(errorMsg))
    -- Альтернативный запуск
    task.spawn(Initialize)
end

-- Защита от ошибок
game:GetService("ScriptContext").Error:Connect(function(message)
    -- Игнорируем не критичные ошибки
end)
