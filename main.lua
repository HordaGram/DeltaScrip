local Players = game:GetService("Players")

-- === ЖДЕМ ПОЛНОЙ ЗАГРУЗКИ ИГРОКА ===
while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

-- === НАСТРОЙКИ СВЯЗИ ===
local SERVER_IP = "http://191.44.113.226:5000"
local BOT_USERNAME = "HordaPosterbot"

-- === ПОЛУЧЕНИЕ HWID и ROBLOX ID ===
local hwid = "UNKNOWN"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
if hwid == "UNKNOWN" or hwid == "" or hwid == nil then
    hwid = tostring(player.UserId) .. "_USER"
end

local robloxId = tostring(player.UserId)
local botLink = "https://t.me/" .. BOT_USERNAME .. "?start=" .. hwid .. "_" .. robloxId

-- === СИСТЕМА СОХРАНЕНИЯ КЛЮЧЕЙ ===
local keyFileName = "HordaKey_" .. hwid .. ".txt"
local function saveKey(key) pcall(function() writefile(keyFileName, key) end) end
local function loadKey()
    local success, content = pcall(function() return readfile(keyFileName) end)
    return success and content or ""
end

-- === БЕЗОПАСНОЕ СОЗДАНИЕ GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "HordaPremiumUI"
gui.ResetOnSpawn = false
local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then gui.Parent = player:WaitForChild("PlayerGui") end

-- === СТИЛЬ "ЖИДКОЕ СТЕКЛО" ===
local function applyGlassStyle(obj, radius, transparency)
    obj.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    obj.BackgroundTransparency = transparency or 0.35
    obj.BorderSizePixel = 0
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius or 10)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1
end

-- === ИДЕАЛЬНОРОВНЫЕ КНОПКИ С ИКОНКАМИ ===
local function createFeatureButton(parent, text, color, iconId)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Text = "" -- Текст убираем из самой кнопки
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.2
    applyGlassStyle(btn, 8, 0.4)
    
    -- Иконка (строго слева)
    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0, 15, 0.5, -11)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    -- Текст (строго по центру с отступом)
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    return btn, label, icon
end

-- === УВЕДОМЛЕНИЕ В ТГ И ОТПРАВКА СТАТИСТИКИ ===
local function notifyLoginToTelegram()
    task.spawn(function()
        pcall(function() game:HttpGet(SERVER_IP .. "/notify_login?hwid=" .. hwid) end)
        task.wait(1)
        local executor = identify and identify() or "Неизвестный"
        local place = tostring(game.PlaceId)
        local ping = "0"
        pcall(function() ping = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem("Data Ping"):GetValue())) end)
        local fps = "0"
        pcall(function() fps = tostring(math.floor(workspace:GetRealPhysicsFPS())) end)
        local statsUrl = SERVER_IP .. "/update_stats?hwid=" .. hwid .. "&executor=" .. executor .. "&place=" .. place .. "&ping=" .. ping .. "&fps=" .. fps
        pcall(function() game:HttpGet(statsUrl) end)
    end)
end

-- === ИСТЕЧЕНИЕ ВРЕМЕНИ ===
local function showExpiredMessage()
    gui:ClearAllChildren()
    local expFrame = Instance.new("Frame", gui)
    expFrame.Size = UDim2.new(0, 320, 0, 150)
    expFrame.Position = UDim2.new(0.5, -160, 0.5, -75)
    applyGlassStyle(expFrame, 12, 0.2)
    
    local msg = Instance.new("TextLabel", expFrame)
    msg.Size = UDim2.new(1, 0, 1, 0)
    msg.Text = "⏳ Время ключа вышло!\nСкрипт закрыт.\nЗайди в бота за новым ключом."
    msg.TextColor3 = Color3.fromRGB(255, 80, 80)
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 15
    msg.BackgroundTransparency = 1
end

-- === ОСНОВНОЕ МЕНЮ ЧИТОВ (С ВКЛАДКАМИ) ===
local function StartMainCheat(validKey)
    saveKey(validKey)
    notifyLoginToTelegram()
    
    if gui:FindFirstChild("LoginFrame") then gui.LoginFrame:Destroy() end

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 380, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
    mainFrame.ClipsDescendants = true
    applyGlassStyle(mainFrame, 12, 0.2)

    -- Верхняя панель (Шапка)
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1

    local cheatTitle = Instance.new("TextLabel", topBar)
    cheatTitle.Size = UDim2.new(1, -50, 1, 0)
    cheatTitle.Position = UDim2.new(0, 15, 0, 0)
    cheatTitle.Text = "Horda Premium Hub"
    cheatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cheatTitle.Font = Enum.Font.GothamBold
    cheatTitle.TextSize = 16
    cheatTitle.TextXAlignment = Enum.TextXAlignment.Left
    cheatTitle.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1

    -- Панель Вкладок (Tabs)
    local tabBar = Instance.new("Frame", mainFrame)
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundTransparency = 1
    
    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0, 10)

    -- Контейнер для списков функций
    local contentContainer = Instance.new("Frame", mainFrame)
    contentContainer.Size = UDim2.new(1, 0, 1, -85)
    contentContainer.Position = UDim2.new(0, 0, 0, 85)
    contentContainer.BackgroundTransparency = 1

    -- Анимация сворачивания
    local isMinimized = false
    closeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if isMinimized then
            closeBtn.Text = "+"
            closeBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
            tabBar.Visible = false
            contentContainer.Visible = false
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0.5, 0, 0, 40), Position = UDim2.new(0.25, 0, 0, 10)}):Play()
        else
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 380, 0, 420), Position = UDim2.new(0.5, -190, 0.5, -210)}):Play()
            task.wait(0.3)
            tabBar.Visible = true
            contentContainer.Visible = true
        end
    end)

    -- === ЛОГИКА ВКЛАДОК ===
    local tabs = {}
    local tabFrames = {}

    local function SwitchTab(tabName)
        for name, frame in pairs(tabFrames) do frame.Visible = (name == tabName) end
        for name, btn in pairs(tabs) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(50, 120, 200) or Color3.fromRGB(40, 40, 50)
        end
    end

    local function CreateTab(name, iconId)
        -- Кнопка вкладки
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 120, 1, -5)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        applyGlassStyle(btn, 6, 0.1)
        tabs[name] = btn

        -- Страница (ScrollingFrame)
        local scroll = Instance.new("ScrollingFrame", contentContainer)
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 3
        scroll.Visible = false
        tabFrames[name] = scroll

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        -- Отступ сверху для красоты
        local spacer = Instance.new("Frame", scroll)
        spacer.Size = UDim2.new(1, 0, 0, 2)
        spacer.BackgroundTransparency = 1

        btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
        return scroll
    end

    -- === СОЗДАНИЕ ВКЛАДОК ===
    local tabHome = CreateTab("🏠 Главная", "6031280882")
    local tabMM2 = CreateTab("🔪 MM2", "3926305904")
    
    -- === ФУНКЦИИ: ГЛАВНАЯ ВКЛАДКА ===
    
    local btnSpeed, lblSpeed = createFeatureButton(tabHome, "Скорость бега: Выкл", nil, "6031215978")
    local speedEnabled = false
    btnSpeed.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        btnSpeed.BackgroundColor3 = speedEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(30, 30, 40)
        lblSpeed.Text = speedEnabled and "Скорость бега: 60 (ВКЛ)" or "Скорость бега: Выкл"
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = speedEnabled and 60 or 16
        end
    end)

    local btnJump, lblJump = createFeatureButton(tabHome, "Супер Прыжок: Выкл", nil, "6031222886")
    local jumpEnabled = false
    btnJump.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        btnJump.BackgroundColor3 = jumpEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(30, 30, 40)
        lblJump.Text = jumpEnabled and "Супер Прыжок: 100 (ВКЛ)" or "Супер Прыжок: Выкл"
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = jumpEnabled and 100 or 50
        end
    end)

    local btnBright, lblBright = createFeatureButton(tabHome, "FullBright (Бесконечный свет)", nil, "6031265976")
    local brightEnabled = false
    btnBright.MouseButton1Click:Connect(function()
        brightEnabled = not brightEnabled
        btnBright.BackgroundColor3 = brightEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(30, 30, 40)
        lblBright.Text = brightEnabled and "FullBright: ВКЛ" or "FullBright (Бесконечный свет)"
        game.Lighting.Ambient = brightEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
    end)

    -- === ФУНКЦИИ: ВКЛАДКА MM2 ===

    local btnESP, lblESP = createFeatureButton(tabMM2, "ESP Ролей (Взор сквозь стены)", nil, "3926305904")
    local espEnabled = false
    btnESP.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        btnESP.BackgroundColor3 = espEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(30, 30, 40)
        lblESP.Text = espEnabled and "ESP Ролей: ВКЛ" or "ESP Ролей (Взор сквозь стены)"
        
        task.spawn(function()
            while espEnabled do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local role, color = "Невиновный", Color3.fromRGB(0, 255, 0)
                        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                            role, color = "МАРДЕР", Color3.fromRGB(255, 0, 0)
                        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                            role, color = "ШЕРИФ", Color3.fromRGB(0, 100, 255)
                        end
                        local bgui = p.Character.HumanoidRootPart:FindFirstChild("MM2_ESP")
                        if not bgui then
                            bgui = Instance.new("BillboardGui", p.Character.HumanoidRootPart)
                            bgui.Name = "MM2_ESP"
                            bgui.Size = UDim2.new(0, 100, 0, 40)
                            bgui.StudsOffset = Vector3.new(0, 3, 0)
                            bgui.AlwaysOnTop = true
                            local text = Instance.new("TextLabel", bgui)
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextScaled = true
                            text.Font = Enum.Font.GothamBold
                        end
                        bgui.TextLabel.Text = p.Name .. "\n[" .. role .. "]"
                        bgui.TextLabel.TextColor3 = color
                    end
                end
                task.wait(1)
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local bgui = p.Character.HumanoidRootPart:FindFirstChild("MM2_ESP")
                    if bgui then bgui:Destroy() end
                end
            end
        end)
    end)

    local btnGunTP = createFeatureButton(tabMM2, "Телепорт к Пистолету (Если выпал)", nil, "6031094678")
    btnGunTP.MouseButton1Click:Connect(function()
        local drop = workspace:FindFirstChild("GunDrop")
        if drop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = drop.CFrame
        end
    end)

    local btnLobbyTP = createFeatureButton(tabMM2, "Телепорт в Лобби", nil, "6031225815")
    btnLobbyTP.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-109.56, 138.87, 43.15) -- Координаты Лобби MM2
        end
    end)

    local btnMapTP = createFeatureButton(tabMM2, "Телепорт на Карту (Если живой)", nil, "6031262843")
    btnMapTP.MouseButton1Click:Connect(function()
        local map = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChildWhichIsA("Model")
        if map and map:FindFirstChild("Spawns") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                player.Character.HumanoidRootPart.CFrame = spawns[1].CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)

    local btnNoclip, lblNoclip = createFeatureButton(tabMM2, "NoClip (Ходить сквозь стены)", nil, "6031302836")
    local noclipEnabled = false
    btnNoclip.MouseButton1Click:Connect(function()
        noclipEnabled = not noclipEnabled
        btnNoclip.BackgroundColor3 = noclipEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(30, 30, 40)
        lblNoclip.Text = noclipEnabled and "NoClip: ВКЛ (Можно проходить стены)" or "NoClip (Ходить сквозь стены)"
    end)

    RunService.Stepped:Connect(function()
        if noclipEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- Пустые отступы внизу списков для красоты
    Instance.new("Frame", tabHome).Size, Instance.new("Frame", tabHome).BackgroundTransparency = UDim2.new(1,0,0,10), 1
    Instance.new("Frame", tabMM2).Size, Instance.new("Frame", tabMM2).BackgroundTransparency = UDim2.new(1,0,0,10), 1

    -- По умолчанию открываем Главную вкладку
    SwitchTab("🏠 Главная")

    -- === ПРОВЕРКА ВРЕМЕНИ (АВТО-ЗАКРЫТИЕ) ===
    task.spawn(function()
        while true do
            task.wait(20)
            local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. validKey
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response then
                local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
                if validJSON and data and not data.valid then
                    showExpiredMessage()
                    break 
                end
            end
        end
    end)
end

-- === АВТО-ЛОГИН ===
local savedKey = loadKey()
if savedKey ~= "" then
    local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. savedKey
    local success, response = pcall(function() return game:HttpGet(url) end)
    if success and response then
        local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
        if validJSON and data and data.valid then
            StartMainCheat(savedKey)
            return 
        end
    end
end

-- === ОКНО ВХОДА (Если ключа нет) ===
local loginFrame = Instance.new("Frame", gui)
loginFrame.Name = "LoginFrame"
loginFrame.Size = UDim2.new(0, 320, 0, 280)
loginFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
applyGlassStyle(loginFrame, 12, 0.2)

local titleLabel = Instance.new("TextLabel", loginFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "Premium Key System"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.BackgroundTransparency = 1

local hwidLabel = Instance.new("TextLabel", loginFrame)
hwidLabel.Size = UDim2.new(1, 0, 0, 30)
hwidLabel.Position = UDim2.new(0, 0, 0, 40)
hwidLabel.Text = "HWID: " .. hwid
hwidLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextSize = 12
hwidLabel.BackgroundTransparency = 1

local btnCopy = createFeatureButton(loginFrame, "Скопировать и открыть Telegram", Color3.fromRGB(0, 100, 200), "6031094678")
btnCopy.Position = UDim2.new(0, 10, 0, 80)

local inputKey = Instance.new("TextBox", loginFrame)
inputKey.Size = UDim2.new(1, -20, 0, 45)
inputKey.Position = UDim2.new(0, 10, 0, 135)
inputKey.PlaceholderText = "Вставь ключ сюда..."
inputKey.Text = ""
inputKey.TextColor3 = Color3.fromRGB(255, 255, 255)
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 14
applyGlassStyle(inputKey, 8, 0.4)

local btnLogin = createFeatureButton(loginFrame, "Проверить и Войти", Color3.fromRGB(30, 160, 80), "3926305904")
btnLogin.Position = UDim2.new(0, 10, 0, 190)

local statusLabel = Instance.new("TextLabel", loginFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 240)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.BackgroundTransparency = 1

btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.Text = "Ссылка скопирована!"
    pcall(function() GuiService:OpenBrowserWindow(botLink) end)
end)

btnLogin.MouseButton1Click:Connect(function()
    local key = inputKey.Text
    if key == "" then statusLabel.Text = "Введите ключ!"; return end

    statusLabel.Text = "Проверка на сервере..."
    local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. key
    local success, response = pcall(function() return game:HttpGet(url) end)

    if success and response then
        local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
        if validJSON and data and data.valid then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            statusLabel.Text = "Доступ разрешен!"
            task.wait(0.5)
            StartMainCheat(key)
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "Неверный или истекший ключ!"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "Сервер недоступен!"
    end
end)
