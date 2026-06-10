local Players = game:GetService("Players")

-- === ЖДЕМ ПОЛНОЙ ЗАГРУЗКИ ИГРОКА ===
while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

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

-- Дальше идет твой обычный код (Система сохранения ключей и т.д.)...

-- === СИСТЕМА СОХРАНЕНИЯ КЛЮЧЕЙ ===
local keyFileName = "HordaKey_" .. hwid .. ".txt"
local function saveKey(key) pcall(function() writefile(keyFileName, key) end) end
local function loadKey()
    local success, content = pcall(function() return readfile(keyFileName) end)
    return success and content or ""
end



-- === БЕЗОПАСНОЕ СОЗДАНИЕ GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "GlassKeySystem"
gui.ResetOnSpawn = false
local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then gui.Parent = player:WaitForChild("PlayerGui") end

-- === ФУНКЦИИ ДИЗАЙНА С ИКОНКАМИ ===
local function applyGlassStyle(obj, radius)
    obj.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    obj.BackgroundTransparency = 0.35
    obj.BorderSizePixel = 0
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius or 10)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1.2
end

local function createButtonWithIcon(parent, text, yPos, color, iconId)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -40, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Text = "     " .. text 
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    applyGlassStyle(btn, 8)
    
    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 10, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    return btn
end

-- === ФУНКЦИЯ "ИСТЕЧЕНИЯ ВРЕМЕНИ" ===
local function showExpiredMessage()
    gui:ClearAllChildren()
    local expFrame = Instance.new("Frame", gui)
    expFrame.Size = UDim2.new(0, 300, 0, 150)
    expFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    applyGlassStyle(expFrame)
    
    local msg = Instance.new("TextLabel", expFrame)
    msg.Size = UDim2.new(1, 0, 1, 0)
    msg.Text = "⏳ Время ключа вышло!\nСкрипт закрыт.\nПожалуйста, получи новый ключ в боте."
    msg.TextColor3 = Color3.fromRGB(255, 80, 80)
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 15
    msg.BackgroundTransparency = 1
end

-- === УВЕДОМЛЕНИЕ О ВХОДЕ В ТГ ===
local function notifyLoginToTelegram()
    pcall(function()
        game:HttpGet(SERVER_IP .. "/notify_login?hwid=" .. hwid)
    end)
end

-- === ОСНОВНОЕ МЕНЮ ЧИТОВ ===
local function StartMainCheat(validKey)
    saveKey(validKey) -- Сохраняем ключ в память телефона
    notifyLoginToTelegram() -- Отправляем сигнал боту
    
    if gui:FindFirstChild("LoginFrame") then gui.LoginFrame:Destroy() end

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 350, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -190)
    mainFrame.ClipsDescendants = true
    applyGlassStyle(mainFrame, 12)

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1

    local cheatTitle = Instance.new("TextLabel", topBar)
    cheatTitle.Size = UDim2.new(1, -50, 1, 0)
    cheatTitle.Position = UDim2.new(0, 15, 0, 0)
    cheatTitle.Text = "MM2 Premium Script"
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

    local contentFrame = Instance.new("ScrollingFrame", mainFrame)
    contentFrame.Size = UDim2.new(1, 0, 1, -50)
    contentFrame.Position = UDim2.new(0, 0, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    local layout = Instance.new("UIListLayout", contentFrame)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Анимация меню
    local isMinimized = false
    closeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if isMinimized then
            closeBtn.Text = "+"
            closeBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0.5, 0, 0, 40), Position = UDim2.new(0.25, 0, 0, 10)}):Play()
        else
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 350, 0, 380), Position = UDim2.new(0.5, -175, 0.5, -190)}):Play()
        end
    end)

    -- === ФУНКЦИИ ===
    local btnESP = createButtonWithIcon(contentFrame, "ESP Ролей (Взор сквозь стены)", 0, Color3.fromRGB(40, 40, 50), "3926305904")
    local espEnabled = false
    btnESP.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        btnESP.BackgroundColor3 = espEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(40, 40, 50)
        
        task.spawn(function()
            while espEnabled do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local role = "Невиновный"
                        local color = Color3.fromRGB(0, 255, 0)
                        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                            role = "МАРДЕР"
                            color = Color3.fromRGB(255, 0, 0)
                        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                            role = "ШЕРИФ"
                            color = Color3.fromRGB(0, 100, 255)
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

    local btnGunTP = createButtonWithIcon(contentFrame, "Телепорт к Пистолету", 0, Color3.fromRGB(40, 40, 50), "6031094678")
    btnGunTP.MouseButton1Click:Connect(function()
        local drop = workspace:FindFirstChild("GunDrop")
        if drop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = drop.CFrame
        end
    end)

    local btnBright = createButtonWithIcon(contentFrame, "FullBright (Бесконечный свет)", 0, Color3.fromRGB(40, 40, 50), "6031265976")
    local brightEnabled = false
    btnBright.MouseButton1Click:Connect(function()
        brightEnabled = not brightEnabled
        btnBright.BackgroundColor3 = brightEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(40, 40, 50)
        game.Lighting.Ambient = brightEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
    end)

    local btnFov = createButtonWithIcon(contentFrame, "Изменить FOV (Угол обзора 120)", 0, Color3.fromRGB(40, 40, 50), "6031154871")
    local fovEnabled = false
    btnFov.MouseButton1Click:Connect(function()
        fovEnabled = not fovEnabled
        btnFov.BackgroundColor3 = fovEnabled and Color3.fromRGB(40, 160, 60) or Color3.fromRGB(40, 40, 50)
        workspace.CurrentCamera.FieldOfView = fovEnabled and 120 or 70
    end)

    local spacer = Instance.new("Frame", contentFrame)
    spacer.Size = UDim2.new(1, 0, 0, 10); spacer.BackgroundTransparency = 1

    -- === ПРОВЕРКА ВРЕМЕНИ НА ФОНЕ (АВТО-ЗАКРЫТИЕ) ===
    task.spawn(function()
        while true do
            task.wait(20) -- Каждые 20 сек проверяем жив ли ключ
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
            return -- Если ключ жив, сразу запускаем скрипт
        end
    end
end

-- === ОКНО ВХОДА (Если ключа нет или он истек) ===
local loginFrame = Instance.new("Frame", gui)
loginFrame.Name = "LoginFrame"
loginFrame.Size = UDim2.new(0, 320, 0, 280)
loginFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
applyGlassStyle(loginFrame)

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

local btnCopy = createButtonWithIcon(loginFrame, "Скопировать и открыть браузер", 80, Color3.fromRGB(0, 100, 200), "6031094678")
local inputKey = Instance.new("TextBox", loginFrame)
inputKey.Size = UDim2.new(1, -40, 0, 40)
inputKey.Position = UDim2.new(0, 20, 0, 130)
inputKey.PlaceholderText = "Вставь ключ сюда..."
inputKey.Text = ""
inputKey.TextColor3 = Color3.fromRGB(255, 255, 255)
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 14
applyGlassStyle(inputKey, 8)

local btnLogin = createButtonWithIcon(loginFrame, "Проверить и Войти", 180, Color3.fromRGB(30, 160, 80), "3926305904")
local statusLabel = Instance.new("TextLabel", loginFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 235)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.BackgroundTransparency = 1

-- Логика кнопок
btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.Text = "Ссылка скопирована!"
    -- Пытаемся автоматически перебросить в Телеграм (открыть браузер)
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
