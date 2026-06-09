local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === НАСТРОЙКИ СВЯЗИ ===
local SERVER_IP = "http://191.44.113.226:5000"
local BOT_USERNAME = "HordaPosterbot"

-- === ПОЛУЧЕНИЕ HWID ===
local hwid = "UNKNOWN"
pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
if hwid == "UNKNOWN" or hwid == "" or hwid == nil then
    hwid = player and tostring(player.UserId) .. "_USER" or "GUEST_" .. tostring(math.random(1000, 9999))
end
local botLink = "https://t.me/" .. BOT_USERNAME .. "?start=" .. hwid

-- === БЕЗОПАСНОЕ СОЗДАНИЕ GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "GlassKeySystem"
gui.ResetOnSpawn = false
local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then gui.Parent = player:WaitForChild("PlayerGui") end

-- === ФУНКЦИИ СТИЛЯ "ЖИДКОЕ СТЕКЛО" ===
local function applyGlassStyle(obj, radius)
    obj.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    obj.BackgroundTransparency = 0.35 -- Полупрозрачность для эффекта стекла
    obj.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", obj)
    corner.CornerRadius = UDim.new(0, radius or 10)
    
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8 -- Тонкая белая рамка
    stroke.Thickness = 1.2
end

local function createButton(parent, text, yPos, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -40, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    applyGlassStyle(btn, 8)
    return btn
end

-- === 1. ОКНО АВТОРИЗАЦИИ ===
local loginFrame = Instance.new("Frame", gui)
loginFrame.Size = UDim2.new(0, 320, 0, 280)
loginFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
applyGlassStyle(loginFrame)

local titleLabel = Instance.new("TextLabel", loginFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "🔮 Premium Key System"
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

local btnCopy = createButton(loginFrame, "1. Скопировать ссылку бота", 80, Color3.fromRGB(0, 100, 200))

local inputKey = Instance.new("TextBox", loginFrame)
inputKey.Size = UDim2.new(1, -40, 0, 40)
inputKey.Position = UDim2.new(0, 20, 0, 130)
inputKey.PlaceholderText = "2. Вставь ключ сюда..."
inputKey.Text = ""
inputKey.TextColor3 = Color3.fromRGB(255, 255, 255)
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 14
applyGlassStyle(inputKey, 8)

local btnLogin = createButton(loginFrame, "3. Проверить и Войти", 180, Color3.fromRGB(30, 160, 80))

local statusLabel = Instance.new("TextLabel", loginFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 235)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.BackgroundTransparency = 1

-- === ЛОГИКА АВТОРИЗАЦИИ ===
btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.Text = "✅ Ссылка скопирована!"
end)

-- === 2. ГЛАВНОЕ ЧИТ-МЕНЮ (ЖИДКОЕ СТЕКЛО + MM2) ===
local function StartMainCheat()
    loginFrame:Destroy() -- Удаляем окно входа

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 350, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -190)
    mainFrame.ClipsDescendants = true
    applyGlassStyle(mainFrame, 12)

    -- Верхняя панель (для перетаскивания и крестика)
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1

    local cheatTitle = Instance.new("TextLabel", topBar)
    cheatTitle.Size = UDim2.new(1, -50, 1, 0)
    cheatTitle.Position = UDim2.new(0, 15, 0, 0)
    cheatTitle.Text = "🔪 MM2 Premium Script"
    cheatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cheatTitle.Font = Enum.Font.GothamBold
    cheatTitle.TextSize = 16
    cheatTitle.TextXAlignment = Enum.TextXAlignment.Left
    cheatTitle.BackgroundTransparency = 1

    -- Кнопка закрытия/сворачивания
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1

    -- Контейнер для функций
    local contentFrame = Instance.new("ScrollingFrame", mainFrame)
    contentFrame.Size = UDim2.new(1, 0, 1, -50)
    contentFrame.Position = UDim2.new(0, 0, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout", contentFrame)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- === АНИМАЦИЯ СВОРАЧИВАНИЯ (В ПОЛОСКУ) ===
    local isMinimized = false
    local normalSize = UDim2.new(0, 350, 0, 380)
    local normalPos = UDim2.new(0.5, -175, 0.5, -190)
    local miniSize = UDim2.new(0.6, 0, 0, 40) -- 60% ширины экрана, высота 40
    local miniPos = UDim2.new(0.2, 0, 0, 15)  -- Улетает на самый верх

    closeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if isMinimized then
            -- Сворачиваем
            contentFrame.Visible = false
            closeBtn.Text = "+"
            closeBtn.TextColor3 = Color3.fromRGB(80, 255, 80)
            TweenService:Create(mainFrame, tweenInfo, {Size = miniSize, Position = miniPos}):Play()
            TweenService:Create(cheatTitle, tweenInfo, {TextXAlignment = Enum.TextXAlignment.Center}):Play()
        else
            -- Разворачиваем
            closeBtn.Text = "X"
            closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            TweenService:Create(mainFrame, tweenInfo, {Size = normalSize, Position = normalPos}):Play()
            TweenService:Create(cheatTitle, tweenInfo, {TextXAlignment = Enum.TextXAlignment.Left}):Play()
            task.wait(0.3)
            contentFrame.Visible = true
        end
    end)

    -- === ФУНКЦИИ MM2 ===
    
    -- 1. ESP Ролей (Мардер/Шериф)
    local espEnabled = false
    local btnESP = createButton(contentFrame, "Включить ESP Ролей", 0, Color3.fromRGB(40, 40, 50))
    
    local function UpdateESP()
        while espEnabled do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local role = "Невиновный"
                    local color = Color3.fromRGB(0, 255, 0)
                    
                    -- Проверяем инвентарь (Backpack) и руки (Character)
                    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                        role = "МАРДЕР"
                        color = Color3.fromRGB(255, 0, 0)
                    elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                        role = "ШЕРИФ"
                        color = Color3.fromRGB(0, 100, 255)
                    end

                    -- Создаем или обновляем надпись над головой
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
            task.wait(1) -- Обновляем каждую секунду
        end
        
        -- Очистка ESP при выключении
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local bgui = p.Character.HumanoidRootPart:FindFirstChild("MM2_ESP")
                if bgui then bgui:Destroy() end
            end
        end
    end

    btnESP.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        if espEnabled then
            btnESP.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
            btnESP.Text = "ESP: ВКЛ"
            task.spawn(UpdateESP)
        else
            btnESP.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btnESP.Text = "ESP: ВЫКЛ"
        end
    end)

    -- 2. ТП к упавшему пистолету
    local btnGunTP = createButton(contentFrame, "Телепорт к Пистолету (Gun Drop)", 0, Color3.fromRGB(40, 40, 50))
    btnGunTP.MouseButton1Click:Connect(function()
        local drop = workspace:FindFirstChild("GunDrop")
        if drop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = drop.CFrame
        else
            cheatTitle.Text = "Пистолет еще не упал!"
            task.wait(2)
            cheatTitle.Text = "🔪 MM2 Premium Script"
        end
    end)

    -- 3. Скорость (WalkSpeed)
    local btnSpeed = createButton(contentFrame, "Включить Скорость бега (60)", 0, Color3.fromRGB(40, 40, 50))
    local speedEnabled = false
    btnSpeed.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        local char = player.Character
        if speedEnabled then
            btnSpeed.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 60 end
        else
            btnSpeed.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
        end
    end)

    -- 4. Супер Прыжок (JumpPower)
    local btnJump = createButton(contentFrame, "Включить Супер Прыжок (100)", 0, Color3.fromRGB(40, 40, 50))
    local jumpEnabled = false
    btnJump.MouseButton1Click:Connect(function()
        jumpEnabled = not jumpEnabled
        local char = player.Character
        if jumpEnabled then
            btnJump.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
            if char and char:FindFirstChild("Humanoid") then 
                char.Humanoid.UseJumpPower = true
                char.Humanoid.JumpPower = 100 
            end
        else
            btnJump.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = 50 end
        end
    end)
    
    -- Пустышка для скролла
    local spacer = Instance.new("Frame", contentFrame)
    spacer.Size = UDim2.new(1, 0, 0, 10)
    spacer.BackgroundTransparency = 1
end

-- === ОБРАБОТЧИК КНОПКИ ЛОГИНА ===
btnLogin.MouseButton1Click:Connect(function()
    local key = inputKey.Text
    if key == "" then
        statusLabel.Text = "❌ Введите ключ!"
        return
    end

    statusLabel.Text = "⏳ Проверка на сервере..."
    local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. key
    local success, response = pcall(function() return game:HttpGet(url) end)

    if success and response then
        local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
        if validJSON and data and data.valid then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            statusLabel.Text = "✅ Доступ разрешен!"
            task.wait(0.5)
            StartMainCheat()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "❌ Неверный ключ!"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "⚠️ Сервер недоступен!"
    end
end)
