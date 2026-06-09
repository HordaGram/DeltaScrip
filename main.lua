-- 1. Системное уведомление для проверки запуска (стандартное от Roblox)
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Скрипт запущен",
        Text = "Пытаюсь загрузить меню...",
        Duration = 5
    })
end)

-- 2. Безопасная загрузка библиотеки Orion
local OrionLib
local success, err = pcall(function()
    OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
end)

if not success or not OrionLib then
    warn("Не удалось загрузить Orion Library! Ошибка: " .. tostring(err))
    return -- Останавливаем скрипт, если библиотека заблокирована
end

local HttpService = game:GetService("HttpService")

-- === НАСТРОЙКИ СВЯЗИ ===
local SERVER_IP = "http://191.44.113.226:5000" -- Твой IP сервера (используем порт 5000)
local BOT_USERNAME = "HordaPosterbot" -- Твой бот

-- 3. БЕЗОПАСНОЕ получение HWID
local hwid = "UNKNOWN"
pcall(function()
    hwid = game:GetService("RbxAnalyticsService"):GetClientId()
end)

if hwid == "UNKNOWN" or hwid == "" or hwid == nil then
    local player = game:GetService("Players").LocalPlayer
    if player then
        hwid = tostring(player.UserId) .. "_USER"
    else
        hwid = "GUEST_" .. tostring(math.random(1000, 9999))
    end
end

-- Формируем ссылку на твоего бота
local botLink = "https://t.me/" .. BOT_USERNAME .. "?start=" .. hwid

-- === СОЗДАНИЕ ОКНА ВХОДА ===
local LoginWindow = OrionLib:MakeWindow({
    Name = "Система Ключей | Delta", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Проверка..."
})

local LoginTab = LoginWindow:MakeTab({
    Name = "Получить ключ", 
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

LoginTab:AddParagraph("Твой HWID", hwid)

LoginTab:AddButton({
    Name = "1. Копировать ссылку на бота",
    Callback = function()
        pcall(function()
            setclipboard(botLink)
        end)
        OrionLib:MakeNotification({Name = "Успех", Content = "Ссылка скопирована! Открой браузер.", Time = 4})
    end    
})

local enteredKey = ""
LoginTab:AddTextbox({
    Name = "2. Вставь ключ сюда",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        enteredKey = Value
    end      
})

-- === ОСНОВНОЕ МЕНЮ (ПОСЛЕ УСПЕШНОГО ВХОДА) ===
local function LoadMainScript()
    local MainWindow = OrionLib:MakeWindow({Name = "Мой Супер Чит", HidePremium = false, SaveConfig = false, IntroText = "Успешный вход!"})
    local MainTab = MainWindow:MakeTab({Name = "Главная", Icon = "rbxassetid://4483345998", PremiumOnly = false})
    
    MainTab:AddParagraph("Успешно!", "Ключ принят. Твой скрипт загружен.")
    
    MainTab:AddSlider({
        Name = "Скорость бега", Min = 16, Max = 100, Default = 16, Color = Color3.fromRGB(0, 150, 255), Increment = 1, ValueName = "spd",
        Callback = function(Value)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end    
    })
end

-- Кнопка проверки ключа
LoginTab:AddButton({
    Name = "3. Проверить ключ и войти",
    Callback = function()
        if enteredKey == "" then 
            OrionLib:MakeNotification({Name = "Ошибка", Content = "Поле ключа пустое!", Time = 3})
            return 
        end
        
        -- Делаем запрос к твоему Python-серверу
        local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. enteredKey
        local successReq, response = pcall(function()
            return game:HttpGet(url)
        end)

        if successReq and response then
            local successJSON, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)

            if successJSON and data and data.valid then
                OrionLib:MakeNotification({Name = "Успех!", Content = "Ключ верный. Загрузка...", Time = 3})
                OrionLib:Destroy() 
                LoadMainScript()   
            else
                OrionLib:MakeNotification({Name = "Ошибка", Content = "Неверный ключ!", Time = 3})
            end
        else
            OrionLib:MakeNotification({Name = "Ошибка", Content = "Сервер недоступен!", Time = 3})
        end
    end    
})

OrionLib:Init()
