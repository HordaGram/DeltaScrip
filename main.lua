-- 1. Системное уведомление для старта
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Успех",
        Text = "Запуск собственного меню...",
        Duration = 3
    })
end)

local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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

-- === СОЗДАЕМ СОБСТВЕННЫЙ GUI С НУЛЯ (Никаких библиотек!) ===
local gui = Instance.new("ScreenGui")
gui.Name = "MyCustomKeySystem"
gui.ResetOnSpawn = false
-- Защита: ищем куда безопасно поместить меню
local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then 
    gui.Parent = player:WaitForChild("PlayerGui") 
end

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔑 Система Ключей"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Текст HWID
local hwidLabel = Instance.new("TextLabel")
hwidLabel.Size = UDim2.new(1, 0, 0, 30)
hwidLabel.Position = UDim2.new(0, 0, 0, 40)
hwidLabel.Text = "Твой HWID: " .. hwid
hwidLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextSize = 12
hwidLabel.BackgroundTransparency = 1
hwidLabel.Parent = mainFrame

-- Кнопка "Копировать ссылку"
local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(1, -40, 0, 40)
btnCopy.Position = UDim2.new(0, 20, 0, 80)
btnCopy.Text = "1. Скопировать ссылку на бота"
btnCopy.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCopy.Font = Enum.Font.GothamBold
btnCopy.TextSize = 14
Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 6)
btnCopy.Parent = mainFrame

-- Поле ввода
local inputKey = Instance.new("TextBox")
inputKey.Size = UDim2.new(1, -40, 0, 40)
inputKey.Position = UDim2.new(0, 20, 0, 130)
inputKey.PlaceholderText = "2. Вставь ключ сюда..."
inputKey.Text = ""
inputKey.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
inputKey.TextColor3 = Color3.fromRGB(255, 255, 255)
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 14
Instance.new("UICorner", inputKey).CornerRadius = UDim.new(0, 6)
inputKey.Parent = mainFrame

-- Кнопка "Войти"
local btnLogin = Instance.new("TextButton")
btnLogin.Size = UDim2.new(1, -40, 0, 40)
btnLogin.Position = UDim2.new(0, 20, 0, 180)
btnLogin.Text = "3. Проверить и войти"
btnLogin.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
btnLogin.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLogin.Font = Enum.Font.GothamBold
btnLogin.TextSize = 14
Instance.new("UICorner", btnLogin).CornerRadius = UDim.new(0, 6)
btnLogin.Parent = mainFrame

-- Текст статуса (Ошибки/Успех)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 225)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

-- === ЛОГИКА КНОПОК ===
btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    statusLabel.Text = "Ссылка скопирована!"
end)

-- Функция запуска самого чита после проверки ключа
local function StartMainCheat()
    gui:Destroy() -- Удаляем окно входа

    -- Создаем простое чит-меню
    local cheatGui = Instance.new("ScreenGui")
    cheatGui.ResetOnSpawn = false
    pcall(function() cheatGui.Parent = game:GetService("CoreGui") end)
    if not cheatGui.Parent then cheatGui.Parent = player:WaitForChild("PlayerGui") end

    local cFrame = Instance.new("Frame")
    cFrame.Size = UDim2.new(0, 200, 0, 150)
    cFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
    cFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    cFrame.Parent = cheatGui
    Instance.new("UICorner", cFrame).CornerRadius = UDim.new(0, 10)

    local cTitle = Instance.new("TextLabel")
    cTitle.Size = UDim2.new(1, 0, 0, 40)
    cTitle.Text = "Успешный вход!"
    cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cTitle.BackgroundTransparency = 1
    cTitle.Font = Enum.Font.GothamBold
    cTitle.Parent = cFrame

    local btnSpeed = Instance.new("TextButton")
    btnSpeed.Size = UDim2.new(1, -20, 0, 40)
    btnSpeed.Position = UDim2.new(0, 10, 0, 50)
    btnSpeed.Text = "Включить скорость"
    btnSpeed.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSpeed.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btnSpeed).CornerRadius = UDim.new(0, 6)
    btnSpeed.Parent = cFrame

    -- Логика чита
    btnSpeed.MouseButton1Click:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 60
        end
    end)
    
    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(1, -20, 0, 40)
    btnClose.Position = UDim2.new(0, 10, 0, 100)
    btnClose.Text = "Закрыть чит"
    btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnClose.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)
    btnClose.Parent = cFrame

    btnClose.MouseButton1Click:Connect(function()
        cheatGui:Destroy()
    end)
end

btnLogin.MouseButton1Click:Connect(function()
    local key = inputKey.Text
    if key == "" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "Введите ключ!"
        return
    end

    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    statusLabel.Text = "Проверка на сервере..."

    local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. key
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response then
        local validJSON, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)

        if validJSON and data and data.valid then
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            statusLabel.Text = "Ключ верный!"
            task.wait(1)
            StartMainCheat()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "Неверный ключ!"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "Сервер недоступен!"
    end
end)
