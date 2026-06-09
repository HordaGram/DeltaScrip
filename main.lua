-- 1. Системное уведомление
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Загрузка...",
        Text = "Подключаю библиотеку Rayfield",
        Duration = 3
    })
end)

-- 2. Загружаем легкую библиотеку Rayfield
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirblood.github.io/Rayfield'))()
end)

if not success or not Rayfield then
    warn("Ошибка загрузки Rayfield: " .. tostring(err))
    return
end

local HttpService = game:GetService("HttpService")

-- === НАСТРОЙКИ СВЯЗИ ===
local SERVER_IP = "http://191.44.113.226:5000" -- Твой сервер
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

local botLink = "https://t.me/" .. BOT_USERNAME .. "?start=" .. hwid

-- === ОКНО ВХОДА ===
local Window = Rayfield:CreateWindow({
    Name = "Система Ключей | Delta",
    LoadingTitle = "Проверка лицензии...",
    LoadingSubtitle = "by HordaGram",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false -- Выключаем встроенную, т.к. делаем свою, более надежную
})

local LoginTab = Window:CreateTab("Получить ключ", 4483345998)

LoginTab:CreateParagraph({Title = "Твой HWID", Content = hwid})

LoginTab:CreateButton({
    Name = "1. Копировать ссылку на бота",
    Callback = function()
        pcall(function()
            setclipboard(botLink)
        end)
        Rayfield:Notify({Title = "Успех!", Content = "Ссылка скопирована. Переходи в ТГ.", Duration = 4})
    end
})

local enteredKey = ""
LoginTab:CreateInput({
    Name = "2. Вставь ключ сюда",
    PlaceholderText = "KEY-...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        enteredKey = Text
    end
})

-- === ОСНОВНОЕ МЕНЮ (ПОСЛЕ УСПЕШНОГО ВХОДА) ===
local function LoadMainScript()
    local MainWindow = Rayfield:CreateWindow({
        Name = "Мой Супер Чит",
        LoadingTitle = "Успешный вход!",
        ConfigurationSaving = {Enabled = false}
    })
    
    local MainTab = MainWindow:CreateTab("Главная", 4483345998)
    
    MainTab:CreateParagraph({Title = "Успешно!", Content = "Ключ принят. Твой скрипт загружен."})
    
    MainTab:CreateSlider({
        Name = "Скорость бега",
        Range = {16, 100},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(Value)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Value
            end
        end
    })
end

-- Кнопка проверки ключа
LoginTab:CreateButton({
    Name = "3. Проверить ключ и войти",
    Callback = function()
        if enteredKey == "" then 
            Rayfield:Notify({Title = "Ошибка", Content = "Поле ключа пустое!", Duration = 3})
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
                Rayfield:Notify({Title = "Успех!", Content = "Ключ верный. Загрузка...", Duration = 3})
                Rayfield:Destroy() -- Закрываем окно ключа
                LoadMainScript()   -- Открываем основной чит
            else
                Rayfield:Notify({Title = "Ошибка", Content = "Неверный ключ!", Duration = 3})
            end
        else
            Rayfield:Notify({Title = "Ошибка", Content = "Сервер недоступен!", Duration = 3})
        end
    end
})
