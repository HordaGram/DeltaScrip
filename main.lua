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
gui.IgnoreGuiInset = true
local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then gui.Parent = player:WaitForChild("PlayerGui") end

-- === ЦВЕТОВЫЕ АКЦЕНТЫ (Электрический синий -> Неоновый фиолетовый) ===
local ACCENT_COLOR_1 = Color3.fromRGB(0, 230, 255)
local ACCENT_COLOR_2 = Color3.fromRGB(180, 0, 255)
local BG_COLOR = Color3.fromRGB(15, 15, 20)
local CARD_BG = Color3.fromRGB(25, 25, 32)

-- === DEEP GLASSMORPHISM СТИЛЬ ===
local function applyDeepGlass(obj, radius, transparency, addNeonStroke)
    obj.BackgroundColor3 = BG_COLOR
    obj.BackgroundTransparency = transparency or 0.2
    obj.BorderSizePixel = 0
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius or 10)
    
    if addNeonStroke then
        local stroke = Instance.new("UIStroke", obj)
        stroke.Thickness = 1.5
        stroke.Color = Color3.fromRGB(255, 255, 255)
        local grad = Instance.new("UIGradient", stroke)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ACCENT_COLOR_1),
            ColorSequenceKeypoint.new(1, ACCENT_COLOR_2)
        })
        grad.Rotation = 45
    end
end

-- === АНИМАЦИИ ПОЯВЛЕНИЯ (VFX) ===
local function playFadeIn(obj)
    obj.GroupTransparency = 1
    obj.Size = UDim2.new(0, obj.Size.X.Offset * 0.9, 0, obj.Size.Y.Offset * 0.9)
    TweenService:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Size = UDim2.new(0, obj.Size.X.Offset / 0.9, 0, obj.Size.Y.Offset / 0.9)
    }):Play()
end

-- === КАРТОЧНАЯ СИСТЕМА (TOGGLE) ===
local function createToggleCard(parent, titleText, descText, iconId, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -20, 0, 65)
    card.BackgroundColor3 = CARD_BG
    card.BackgroundTransparency = 0.4
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = ACCENT_COLOR_1

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -120, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 12)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local desc = Instance.new("TextLabel", card)
    desc.Size = UDim2.new(1, -120, 0, 20)
    desc.Position = UDim2.new(0, 50, 0, 32)
    desc.Text = descText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1

    -- Тумблер (Toggle)
    local toggleBtn = Instance.new("TextButton", card)
    toggleBtn.Size = UDim2.new(0, 44, 0, 24)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
    toggleBtn.Text = ""
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", toggleBtn)
    stroke.Color = Color3.fromRGB(80, 80, 90)

    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetPos = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = enabled and ACCENT_COLOR_1 or Color3.fromRGB(200, 200, 200)
        local targetBg = enabled and ACCENT_COLOR_2 or Color3.fromRGB(40, 40, 50)
        
        TweenService:Create(circle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = targetBg}):Play()
        
        callback(enabled)
    end)
    return card
end

-- === КАРТОЧНАЯ СИСТЕМА (ACTION) ===
local function createActionCard(parent, titleText, descText, iconId, callback)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(1, -20, 0, 65)
    card.Text = ""
    card.BackgroundColor3 = CARD_BG
    card.BackgroundTransparency = 0.4
    card.AutoButtonColor = false
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = ACCENT_COLOR_1

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 12)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local desc = Instance.new("TextLabel", card)
    desc.Size = UDim2.new(1, -70, 0, 20)
    desc.Position = UDim2.new(0, 50, 0, 32)
    desc.Text = descText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    
    local runIcon = Instance.new("TextLabel", card)
    runIcon.Size = UDim2.new(0, 30, 0, 30)
    runIcon.Position = UDim2.new(1, -45, 0.5, -15)
    runIcon.Text = "▶"
    runIcon.Font = Enum.Font.GothamBold
    runIcon.TextSize = 16
    runIcon.TextColor3 = ACCENT_COLOR_1
    runIcon.BackgroundTransparency = 1

    card.MouseButton1Click:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
        task.wait(0.1)
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundColor3 = CARD_BG}):Play()
        callback()
    end)
    return card
end

-- === УВЕДОМЛЕНИЕ В ТГ И СТАТИСТИКА ===
local function notifyLoginToTelegram()
    task.spawn(function()
        pcall(function() game:HttpGet(SERVER_IP .. "/notify_login?hwid=" .. hwid) end)
        task.wait(1)
        local executor = identify and identify() or "Неизвестный"
        local statsUrl = SERVER_IP .. "/update_stats?hwid=" .. hwid .. "&executor=" .. executor .. "&place=" .. tostring(game.PlaceId) .. "&ping=0&fps=0"
        pcall(function() game:HttpGet(statsUrl) end)
    end)
end

-- === ОСНОВНОЕ МЕНЮ ЧИТОВ ===
local function StartMainCheat(validKey)
    saveKey(validKey)
    notifyLoginToTelegram()
    
    if gui:FindFirstChild("LoginGroup") then gui.LoginGroup:Destroy() end

    -- Главный контейнер (CanvasGroup для прозрачности)
    local mainUI = Instance.new("CanvasGroup", gui)
    mainUI.Name = "MainHubGroup"
    mainUI.Size = UDim2.new(0, 520, 0, 360)
    mainUI.Position = UDim2.new(0.5, -260, 0.5, -180)
    applyDeepGlass(mainUI, 12, 0.15, true)
    
    -- SIDEBAR (Боковая панель)
    local sidebar = Instance.new("Frame", mainUI)
    sidebar.Size = UDim2.new(0, 60, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    
    local sidebarLine = Instance.new("Frame", sidebar)
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, 0, 0, 0)
    sidebarLine.BackgroundColor3 = ACCENT_COLOR_2
    sidebarLine.BorderSizePixel = 0
    sidebarLine.BackgroundTransparency = 0.5

    -- КОНТЕНТ (Правая часть)
    local contentArea = Instance.new("Frame", mainUI)
    contentArea.Size = UDim2.new(1, -60, 1, 0)
    contentArea.Position = UDim2.new(0, 60, 0, 0)
    contentArea.BackgroundTransparency = 1

    local pages = {}
    local tabButtons = {}

    local function SwitchPage(name)
        for pName, page in pairs(pages) do page.Visible = (pName == name) end
        for bName, btn in pairs(tabButtons) do
            local color = (bName == name) and ACCENT_COLOR_1 or Color3.fromRGB(100, 100, 100)
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        end
    end

    local function createSidebarTab(emoji, name, yOffset)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, 0, 0, 50)
        btn.Position = UDim2.new(0, 0, 0, yOffset)
        btn.Text = emoji
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 22
        btn.TextColor3 = Color3.fromRGB(100, 100, 100)
        btn.BackgroundTransparency = 1
        tabButtons[name] = btn

        local page = Instance.new("ScrollingFrame", contentArea)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        -- Отступ сверху
        local spacer = Instance.new("Frame", page)
        spacer.Size = UDim2.new(1, 0, 0, 10)
        spacer.BackgroundTransparency = 1

        btn.MouseButton1Click:Connect(function() SwitchPage(name) end)
        pages[name] = page
        return page
    end

    -- Создаем вкладки
    local pageProfile = createSidebarTab("🏠", "Profile", 20)
    local pageGeneral = createSidebarTab("⚙️", "General", 80)
    local pageMM2     = createSidebarTab("🔪", "MM2", 140)
    local pageFuture  = createSidebarTab("🌐", "Future", 200)

    -- === ВКЛАДКА ПРОФИЛЬ (Лицензия Агента) ===
    local idCard = Instance.new("Frame", pageProfile)
    idCard.Size = UDim2.new(1, -40, 0, 160)
    applyDeepGlass(idCard, 10, 0.3, false)
    
    local avatar = Instance.new("ImageLabel", idCard)
    avatar.Size = UDim2.new(0, 100, 0, 100)
    avatar.Position = UDim2.new(0, 20, 0, 30)
    avatar.BackgroundTransparency = 1
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    pcall(function()
        avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    local avaStroke = Instance.new("UIStroke", avatar)
    avaStroke.Color = ACCENT_COLOR_1
    avaStroke.Thickness = 2

    local idTitle = Instance.new("TextLabel", idCard)
    idTitle.Size = UDim2.new(0, 200, 0, 30)
    idTitle.Position = UDim2.new(0, 140, 0, 30)
    idTitle.Text = "Horda Agent License"
    idTitle.Font = Enum.Font.GothamBold
    idTitle.TextSize = 18
    idTitle.TextColor3 = ACCENT_COLOR_1
    idTitle.TextXAlignment = Enum.TextXAlignment.Left
    idTitle.BackgroundTransparency = 1

    local idName = Instance.new("TextLabel", idCard)
    idName.Size = UDim2.new(0, 200, 0, 20)
    idName.Position = UDim2.new(0, 140, 0, 60)
    idName.Text = "ID: " .. player.Name
    idName.Font = Enum.Font.Gotham
    idName.TextSize = 14
    idName.TextColor3 = Color3.fromRGB(220, 220, 220)
    idName.TextXAlignment = Enum.TextXAlignment.Left
    idName.BackgroundTransparency = 1

    local trustLabel = Instance.new("TextLabel", idCard)
    trustLabel.Size = UDim2.new(0, 200, 0, 20)
    trustLabel.Position = UDim2.new(0, 140, 0, 90)
    trustLabel.Text = "Trust Factor: HIGH"
    trustLabel.Font = Enum.Font.GothamBold
    trustLabel.TextSize = 12
    trustLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    trustLabel.TextXAlignment = Enum.TextXAlignment.Left
    trustLabel.BackgroundTransparency = 1

    local progressBg = Instance.new("Frame", idCard)
    progressBg.Size = UDim2.new(0, 200, 0, 6)
    progressBg.Position = UDim2.new(0, 140, 0, 115)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Size = UDim2.new(0.85, 0, 1, 0)
    progressFill.BackgroundColor3 = ACCENT_COLOR_2
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

    -- === ФУНКЦИИ: GENERAL (ОБЩИЕ) ===
    createToggleCard(pageGeneral, "Speed Hack", "Мгновенное увеличение скорости бега", "6031215978", function(state)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = state and 60 or 16
        end
    end)

    createToggleCard(pageGeneral, "Super Jump", "Увеличенная гравитация прыжка", "6031222886", function(state)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = state and 100 or 50
        end
    end)

    createToggleCard(pageGeneral, "FullBright", "Бесконечный свет во всей игре", "6031265976", function(state)
        game.Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
    end)

    -- === ФУНКЦИИ: MM2 (🔪) ===
    local espActive = false
    createToggleCard(pageMM2, "ESP Ролей", "Взор сквозь стены и определение ролей", "3926305904", function(state)
        espActive = state
        if espActive then
            task.spawn(function()
                while espActive do
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local role, color = "Игрок", Color3.fromRGB(0, 255, 0)
                            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                                role, color = "МАРДЕР", Color3.fromRGB(255, 0, 0)
                            elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                                role, color = "ШЕРИФ", Color3.fromRGB(0, 150, 255)
                            end
                            local bgui = p.Character.HumanoidRootPart:FindFirstChild("MM2_ESP")
                            if not bgui then
                                bgui = Instance.new("BillboardGui", p.Character.HumanoidRootPart)
                                bgui.Name = "MM2_ESP"
                                bgui.Size = UDim2.new(0, 100, 0, 30)
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
        end
    end)

    local noclipActive = false
    createToggleCard(pageMM2, "NoClip", "Возможность ходить сквозь стены", "6031302836", function(state)
        noclipActive = state
    end)
    RunService.Stepped:Connect(function()
        if noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    createActionCard(pageMM2, "Телепорт к Пистолету", "Моментально забрать дропнутый пистолет", "6031094678", function()
        local drop = workspace:FindFirstChild("GunDrop")
        if drop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = drop.CFrame
        end
    end)

    createActionCard(pageMM2, "Телепорт в Лобби", "Вернуться на безопасную базу", "6031225815", function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-109.56, 138.87, 43.15)
        end
    end)

    -- === ВКЛАДКА FUTURE (Глобал) ===
    local soonTxt = Instance.new("TextLabel", pageFuture)
    soonTxt.Size = UDim2.new(1, 0, 0, 50)
    soonTxt.Text = "Новые режимы скоро..."
    soonTxt.Font = Enum.Font.GothamBold
    soonTxt.TextColor3 = Color3.fromRGB(150, 150, 150)
    soonTxt.BackgroundTransparency = 1

    -- Запуск
    SwitchPage("Profile")
    playFadeIn(mainUI)

    -- Проверка ключа раз в 20 сек
    task.spawn(function()
        while true do
            task.wait(20)
            local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. validKey
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response then
                local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
                if validJSON and data and not data.valid then
                    player:Kick("⏳ Время ключа вышло! Получи новый в боте Horda.")
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

-- === ОКНО ВХОДА (Если нет ключа) ===
local loginGroup = Instance.new("CanvasGroup", gui)
loginGroup.Name = "LoginGroup"
loginGroup.Size = UDim2.new(0, 340, 0, 260)
loginGroup.Position = UDim2.new(0.5, -170, 0.5, -130)
applyDeepGlass(loginGroup, 12, 0.15, true)
playFadeIn(loginGroup)

local titleLabel = Instance.new("TextLabel", loginGroup)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "NEON KEY SYSTEM"
titleLabel.TextColor3 = ACCENT_COLOR_1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.BackgroundTransparency = 1

local hwidLabel = Instance.new("TextLabel", loginGroup)
hwidLabel.Size = UDim2.new(1, 0, 0, 20)
hwidLabel.Position = UDim2.new(0, 0, 0, 40)
hwidLabel.Text = "HWID: " .. string.sub(hwid, 1, 15) .. "..."
hwidLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextSize = 11
hwidLabel.BackgroundTransparency = 1

local btnCopy = Instance.new("TextButton", loginGroup)
btnCopy.Size = UDim2.new(1, -40, 0, 40)
btnCopy.Position = UDim2.new(0, 20, 0, 75)
btnCopy.Text = "Получить ключ (Telegram)"
btnCopy.Font = Enum.Font.GothamBold
btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCopy.TextSize = 13
applyDeepGlass(btnCopy, 8, 0.4, false)

local inputKey = Instance.new("TextBox", loginGroup)
inputKey.Size = UDim2.new(1, -40, 0, 40)
inputKey.Position = UDim2.new(0, 20, 0, 125)
inputKey.PlaceholderText = "Вставь ключ сюда..."
inputKey.Text = ""
inputKey.TextColor3 = Color3.fromRGB(255, 255, 255)
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 13
applyDeepGlass(inputKey, 8, 0.5, false)

local btnLogin = Instance.new("TextButton", loginGroup)
btnLogin.Size = UDim2.new(1, -40, 0, 40)
btnLogin.Position = UDim2.new(0, 20, 0, 175)
btnLogin.Text = "АВТОРИЗАЦИЯ"
btnLogin.Font = Enum.Font.GothamBold
btnLogin.TextColor3 = BG_COLOR
btnLogin.BackgroundColor3 = ACCENT_COLOR_1
Instance.new("UICorner", btnLogin).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", loginGroup)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 225)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.BackgroundTransparency = 1

btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.TextColor3 = ACCENT_COLOR_1
    statusLabel.Text = "Ссылка скопирована!"
    pcall(function() GuiService:OpenBrowserWindow(botLink) end)
end)

btnLogin.MouseButton1Click:Connect(function()
    local key = inputKey.Text
    if key == "" then statusLabel.Text = "Введите ключ!"; return end

    btnLogin.Text = "ЗАГРУЗКА..."
    local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. key
    local success, response = pcall(function() return game:HttpGet(url) end)

    if success and response then
        local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
        if validJSON and data and data.valid then
            statusLabel.TextColor3 = ACCENT_COLOR_1
            statusLabel.Text = "ДОСТУП РАЗРЕШЕН"
            task.wait(0.5)
            StartMainCheat(key)
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "ОШИБКА: Ключ недействителен"
            btnLogin.Text = "АВТОРИЗАЦИЯ"
        end
    else
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLabel.Text = "СЕРВЕР НЕДОСТУПЕН"
        btnLogin.Text = "АВТОРИЗАЦИЯ"
    end
end)
