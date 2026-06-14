local Players = game:GetService("Players")

-- === ЖДЕМ ПОЛНОЙ ЗАГРУЗКИ ИГРОКА ===
while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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

for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "HordaPremiumUI" then v:Destroy() end
end
for _, v in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name == "HordaPremiumUI" then v:Destroy() end
end

local successCore = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not successCore then gui.Parent = player:WaitForChild("PlayerGui") end

-- === ЧЕРНО-БЕЛАЯ ПАЛИТРА (MINIMALISM) ===
local COLOR_BG = Color3.fromRGB(12, 12, 12)
local COLOR_CARD = Color3.fromRGB(20, 20, 20)
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_GRAY = Color3.fromRGB(100, 100, 100)
local COLOR_DARK_GRAY = Color3.fromRGB(35, 35, 35)

-- === ФУНКЦИИ СТИЛЯ ===
local function applyStyle(obj, radius, isCard)
    obj.BackgroundColor3 = isCard and COLOR_CARD or COLOR_BG
    obj.BorderSizePixel = 0
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius or 8)
    
    local stroke = Instance.new("UIStroke", obj)
    stroke.Thickness = 1
    stroke.Color = COLOR_DARK_GRAY
end

-- === ФУНКЦИЯ DRAGGABLE (ПЕРЕМЕЩЕНИЕ ОКОН) ===
local function makeDraggable(dragArea, moveFrame)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            moveFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === АНИМАЦИЯ ПОЯВЛЕНИЯ ===
local function playPopIn(obj, targetSize)
    obj.Size = UDim2.new(0, targetSize.X.Offset * 0.9, 0, targetSize.Y.Offset * 0.9)
    TweenService:Create(obj, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end

-- === КАРТОЧНАЯ СИСТЕМА (TOGGLE) ===
local function createToggleCard(parent, titleText, descText, iconId, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -20, 0, 65)
    applyStyle(card, 8, true)

    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = COLOR_WHITE

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -120, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 12)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = COLOR_WHITE
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local desc = Instance.new("TextLabel", card)
    desc.Size = UDim2.new(1, -120, 0, 20)
    desc.Position = UDim2.new(0, 50, 0, 32)
    desc.Text = descText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextColor3 = COLOR_GRAY
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1

    local toggleBtn = Instance.new("TextButton", card)
    toggleBtn.Size = UDim2.new(0, 44, 0, 24)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
    toggleBtn.Text = ""
    toggleBtn.BackgroundColor3 = COLOR_BG
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Color = COLOR_DARK_GRAY

    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = COLOR_GRAY
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetPos = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = enabled and COLOR_BG or COLOR_GRAY
        local targetBg = enabled and COLOR_WHITE or COLOR_BG
        
        TweenService:Create(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        callback(enabled)
    end)
    return card
end

-- === КАРТОЧНАЯ СИСТЕМА (ACTION) ===
local function createActionCard(parent, titleText, descText, iconId, callback)
    local card = Instance.new("TextButton", parent)
    card.Size = UDim2.new(1, -20, 0, 65)
    card.Text = ""
    card.AutoButtonColor = false
    applyStyle(card, 8, true)

    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. iconId
    icon.ImageColor3 = COLOR_WHITE

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 12)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = COLOR_WHITE
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local desc = Instance.new("TextLabel", card)
    desc.Size = UDim2.new(1, -70, 0, 20)
    desc.Position = UDim2.new(0, 50, 0, 32)
    desc.Text = descText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextColor3 = COLOR_GRAY
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    
    local runIcon = Instance.new("ImageLabel", card)
    runIcon.Size = UDim2.new(0, 20, 0, 20)
    runIcon.Position = UDim2.new(1, -40, 0.5, -10)
    runIcon.BackgroundTransparency = 1
    runIcon.Image = "rbxassetid://6031094678" -- Play/Arrow icon
    runIcon.ImageColor3 = COLOR_WHITE

    card.MouseButton1Click:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = COLOR_DARK_GRAY}):Play()
        task.wait(0.1)
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = COLOR_CARD}):Play()
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
    
    if gui:FindFirstChild("LoginFrame") then gui.LoginFrame:Destroy() end

    -- Главный контейнер
    local mainUI = Instance.new("Frame", gui)
    mainUI.Name = "MainHubFrame"
    mainUI.Size = UDim2.new(0, 520, 0, 360)
    mainUI.Position = UDim2.new(0.5, -260, 0.5, -180)
    mainUI.ClipsDescendants = true -- Важно для сворачивания
    applyStyle(mainUI, 10, false)
    
    -- ВЕРХНЯЯ ПАНЕЛЬ (TopBar - для перемещения и кнопок окна)
    local topBar = Instance.new("Frame", mainUI)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = COLOR_CARD
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
    
    -- Прямоугольник чтобы закрасить нижние углы topBar (делает их прямыми)
    local topBarPatch = Instance.new("Frame", topBar)
    topBarPatch.Size = UDim2.new(1, 0, 0, 10)
    topBarPatch.Position = UDim2.new(0, 0, 1, -10)
    topBarPatch.BackgroundColor3 = COLOR_CARD
    topBarPatch.BorderSizePixel = 0

    local topBarStroke = Instance.new("Frame", topBar)
    topBarStroke.Size = UDim2.new(1, 0, 0, 1)
    topBarStroke.Position = UDim2.new(0, 0, 1, 0)
    topBarStroke.BackgroundColor3 = COLOR_DARK_GRAY
    topBarStroke.BorderSizePixel = 0

    makeDraggable(topBar, mainUI) -- Делаем меню перемещаемым за шапку

    local hubTitle = Instance.new("TextLabel", topBar)
    hubTitle.Size = UDim2.new(0, 200, 1, 0)
    hubTitle.Position = UDim2.new(0, 15, 0, 0)
    hubTitle.Text = "HORDA UI // PREMIUM"
    hubTitle.Font = Enum.Font.GothamBold
    hubTitle.TextSize = 13
    hubTitle.TextColor3 = COLOR_WHITE
    hubTitle.TextXAlignment = Enum.TextXAlignment.Left
    hubTitle.BackgroundTransparency = 1

    -- Кнопка Свернуть
    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -80, 0, 0)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.TextColor3 = COLOR_WHITE
    minBtn.BackgroundTransparency = 1

    -- Кнопка Закрыть
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -40, 0, 0)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 15
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BackgroundTransparency = 1
    closeBtn.MouseButton1Click:Connect(function() mainUI.Visible = false end)

    -- ЛОГИКА СВОРАЧИВАНИЯ В ПОЛОСКУ
    local isMinimized = false
    local fullSize = UDim2.new(0, 520, 0, 360)
    local minSize = UDim2.new(0, 520, 0, 40)
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        minBtn.Text = isMinimized and "+" or "-"
        TweenService:Create(mainUI, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = isMinimized and minSize or fullSize}):Play()
    end)

    -- SIDEBAR (Боковая панель)
    local sidebar = Instance.new("Frame", mainUI)
    sidebar.Size = UDim2.new(0, 60, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = COLOR_BG
    sidebar.BorderSizePixel = 0
    
    local sidebarLine = Instance.new("Frame", sidebar)
    sidebarLine.Size = UDim2.new(0, 1, 1, 0)
    sidebarLine.Position = UDim2.new(1, 0, 0, 0)
    sidebarLine.BackgroundColor3 = COLOR_DARK_GRAY
    sidebarLine.BorderSizePixel = 0

    -- КОНТЕНТ (Правая часть)
    local contentArea = Instance.new("Frame", mainUI)
    contentArea.Size = UDim2.new(1, -60, 1, -40)
    contentArea.Position = UDim2.new(0, 60, 0, 40)
    contentArea.BackgroundTransparency = 1

    local pages = {}
    local tabButtons = {}

    local function SwitchPage(name)
        for pName, page in pairs(pages) do page.Visible = (pName == name) end
        for bName, btn in pairs(tabButtons) do
            local color = (bName == name) and COLOR_WHITE or COLOR_GRAY
            TweenService:Create(btn.Icon, TweenInfo.new(0.2), {ImageColor3 = color}):Play()
        end
    end

    local function createSidebarTab(iconId, name, yOffset)
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, 0, 0, 50)
        btn.Position = UDim2.new(0, 0, 0, yOffset)
        btn.Text = ""
        btn.BackgroundTransparency = 1
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 26, 0, 26)
        icon.Position = UDim2.new(0.5, -13, 0.5, -13)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. iconId
        icon.ImageColor3 = COLOR_GRAY
        
        tabButtons[name] = btn

        local page = Instance.new("ScrollingFrame", contentArea)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = COLOR_DARK_GRAY
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local spacer = Instance.new("Frame", page)
        spacer.Size = UDim2.new(1, 0, 0, 5)
        spacer.BackgroundTransparency = 1

        btn.MouseButton1Click:Connect(function() SwitchPage(name) end)
        pages[name] = page
        return page
    end

    -- Создаем вкладки (Используем ID иконок вместо эмодзи)
    local pageProfile = createSidebarTab("7432319085", "Profile", 10) -- User Icon
    local pageGeneral = createSidebarTab("7059346373", "General", 70) -- Settings Icon
    local pageMM2     = createSidebarTab("6962275465", "MM2", 130)    -- Crosshair/Target Icon

    -- === ВКЛАДКА ПРОФИЛЬ ===
    local idCard = Instance.new("Frame", pageProfile)
    idCard.Size = UDim2.new(1, -40, 0, 160)
    applyStyle(idCard, 8, true)
    
    local avatar = Instance.new("ImageLabel", idCard)
    avatar.Size = UDim2.new(0, 100, 0, 100)
    avatar.Position = UDim2.new(0, 20, 0, 30)
    avatar.BackgroundTransparency = 1
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    pcall(function()
        avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    local avaStroke = Instance.new("UIStroke", avatar)
    avaStroke.Color = COLOR_DARK_GRAY
    avaStroke.Thickness = 2

    local idTitle = Instance.new("TextLabel", idCard)
    idTitle.Size = UDim2.new(0, 200, 0, 30)
    idTitle.Position = UDim2.new(0, 140, 0, 30)
    idTitle.Text = "USER PROFILE"
    idTitle.Font = Enum.Font.GothamBold
    idTitle.TextSize = 18
    idTitle.TextColor3 = COLOR_WHITE
    idTitle.TextXAlignment = Enum.TextXAlignment.Left
    idTitle.BackgroundTransparency = 1

    local idName = Instance.new("TextLabel", idCard)
    idName.Size = UDim2.new(0, 200, 0, 20)
    idName.Position = UDim2.new(0, 140, 0, 60)
    idName.Text = "@" .. player.Name
    idName.Font = Enum.Font.Gotham
    idName.TextSize = 14
    idName.TextColor3 = COLOR_GRAY
    idName.TextXAlignment = Enum.TextXAlignment.Left
    idName.BackgroundTransparency = 1

    local trustLabel = Instance.new("TextLabel", idCard)
    trustLabel.Size = UDim2.new(0, 200, 0, 20)
    trustLabel.Position = UDim2.new(0, 140, 0, 90)
    trustLabel.Text = "STATUS: PREMIUM ACTIVE"
    trustLabel.Font = Enum.Font.GothamBold
    trustLabel.TextSize = 12
    trustLabel.TextColor3 = COLOR_WHITE
    trustLabel.TextXAlignment = Enum.TextXAlignment.Left
    trustLabel.BackgroundTransparency = 1

    -- === ФУНКЦИИ: GENERAL ===
    createToggleCard(pageGeneral, "Speed Hack", "Мгновенное увеличение скорости бега", "6031215978", function(state)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = state and 60 or 16
        end
    end)

    createToggleCard(pageGeneral, "High Jump", "Высокий прыжок (Гравитация)", "6031222886", function(state)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = state and 100 or 50
        end
    end)
    
    local infJumpEnabled = false
    createToggleCard(pageGeneral, "Infinite Jump", "Бесконечные прыжки в воздухе", "6031082533", function(state)
        infJumpEnabled = state
    end)
    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    local flyEnabled = false
    local flyBody
    createToggleCard(pageGeneral, "Fly (Полет)", "Свободный полет по карте", "6031252110", function(state)
        flyEnabled = state
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = player.Character.HumanoidRootPart
        if flyEnabled then
            workspace.Gravity = 0
            flyBody = Instance.new("BodyVelocity", hrp)
            flyBody.Velocity = Vector3.new(0,0,0)
            flyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        else
            workspace.Gravity = 196.2
            if flyBody then flyBody:Destroy() end
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if flyEnabled and flyBody and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local cam = workspace.CurrentCamera
            local moveVec = require(player:WaitForChild("PlayerScripts").PlayerModule).controls:GetMoveVector()
            flyBody.Velocity = (cam.CFrame.LookVector * (moveVec.Z * -50)) + (cam.CFrame.RightVector * (moveVec.X * 50))
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyBody.Velocity = flyBody.Velocity + Vector3.new(0, 50, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyBody.Velocity = flyBody.Velocity - Vector3.new(0, 50, 0) end
        end
    end)

    createToggleCard(pageGeneral, "FullBright", "Убрать тени и включить свет", "6031265976", function(state)
        game.Lighting.Ambient = state and COLOR_WHITE or Color3.fromRGB(128, 128, 128)
        game.Lighting.GlobalShadows = not state
    end)

    -- === ФУНКЦИИ: MM2 ===
    local espActive = false
    createToggleCard(pageMM2, "ESP Ролей", "Видеть Убийцу (Кр) и Шерифа (Син)", "6031253026", function(state)
        espActive = state
        if espActive then
            task.spawn(function()
                while espActive do
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local role, color = "Игрок", Color3.fromRGB(200, 200, 200)
                            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                                role, color = "МАРДЕР", Color3.fromRGB(255, 50, 50)
                            elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                                role, color = "ШЕРИФ", Color3.fromRGB(50, 150, 255)
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
    createToggleCard(pageMM2, "NoClip", "Проходить сквозь стены", "6031302836", function(state)
        noclipActive = state
    end)
    RunService.Stepped:Connect(function()
        if noclipActive and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    createToggleCard(pageMM2, "X-Ray (Прозрачная карта)", "Делает стены карты прозрачными", "6031265976", function(state)
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Parent ~= player.Character and not part:IsDescendantOf(player.Character) then
                if part.Name ~= "HumanoidRootPart" and part.Name ~= "Handle" then
                    part.Transparency = state and 0.6 or 0
                end
            end
        end
    end)

    createActionCard(pageMM2, "Телепорт к Пистолету", "Забрать дропнутый пистолет", "6031094678", function()
        local drop = workspace:FindFirstChild("GunDrop")
        if drop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = drop.CFrame
        end
    end)
    
    createActionCard(pageMM2, "Телепорт на Карту", "Телепорт на случайный спавн карты", "6031225815", function()
        local map = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChildWhichIsA("Model")
        if map and map:FindFirstChild("Spawns") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                player.Character.HumanoidRootPart.CFrame = spawns[math.random(1, #spawns)].CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)

    createActionCard(pageMM2, "Телепорт в Лобби", "Спрятаться в лобби", "6031225815", function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-109.56, 138.87, 43.15)
        end
    end)

    -- Запуск
    SwitchPage("Profile")
    playPopIn(mainUI, fullSize)

    -- Проверка ключа
    task.spawn(function()
        while true do
            task.wait(20)
            local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. validKey
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response then
                local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
                if validJSON and data and not data.valid then
                    player:Kick("⏳ Ключ истек! Получи новый в Telegram боте.")
                    break 
                end
            end
        end
    end)
end

-- === ОКНО ВХОДА ===
local loginFrame = Instance.new("Frame", gui)
loginFrame.Name = "LoginFrame"
loginFrame.Size = UDim2.new(0, 340, 0, 260)
loginFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
applyStyle(loginFrame, 10, false)
makeDraggable(loginFrame, loginFrame) -- Окно логина тоже можно перетаскивать!
playPopIn(loginFrame, UDim2.new(0, 340, 0, 260))

local titleLabel = Instance.new("TextLabel", loginFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "SYSTEM LOGIN"
titleLabel.TextColor3 = COLOR_WHITE
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.BackgroundTransparency = 1

local hwidLabel = Instance.new("TextLabel", loginFrame)
hwidLabel.Size = UDim2.new(1, 0, 0, 20)
hwidLabel.Position = UDim2.new(0, 0, 0, 40)
hwidLabel.Text = "HWID: " .. string.sub(hwid, 1, 15) .. "..."
hwidLabel.TextColor3 = COLOR_GRAY
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextSize = 11
hwidLabel.BackgroundTransparency = 1

local btnCopy = Instance.new("TextButton", loginFrame)
btnCopy.Size = UDim2.new(1, -40, 0, 40)
btnCopy.Position = UDim2.new(0, 20, 0, 75)
btnCopy.Text = "ПОЛУЧИТЬ КЛЮЧ"
btnCopy.Font = Enum.Font.GothamBold
btnCopy.TextColor3 = COLOR_WHITE
applyStyle(btnCopy, 8, true)

local inputKey = Instance.new("TextBox", loginFrame)
inputKey.Size = UDim2.new(1, -40, 0, 40)
inputKey.Position = UDim2.new(0, 20, 0, 125)
inputKey.PlaceholderText = "Введите ключ..."
inputKey.Text = ""
inputKey.TextColor3 = COLOR_WHITE
inputKey.Font = Enum.Font.Gotham
inputKey.TextSize = 13
applyStyle(inputKey, 8, true)

local btnLogin = Instance.new("TextButton", loginFrame)
btnLogin.Size = UDim2.new(1, -40, 0, 40)
btnLogin.Position = UDim2.new(0, 20, 0, 175)
btnLogin.Text = "АВТОРИЗАЦИЯ"
btnLogin.Font = Enum.Font.GothamBold
btnLogin.TextColor3 = COLOR_BG
btnLogin.BackgroundColor3 = COLOR_WHITE
Instance.new("UICorner", btnLogin).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", loginFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 225)
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.BackgroundTransparency = 1

btnCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(botLink) end)
    statusLabel.TextColor3 = COLOR_WHITE
    statusLabel.Text = "Ссылка скопирована!"
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
            statusLabel.TextColor3 = COLOR_WHITE
            statusLabel.Text = "УСПЕШНО"
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

-- === АСИНХРОННЫЙ АВТО-ЛОГИН ===
task.spawn(function()
    local savedKey = loadKey()
    if savedKey ~= "" then
        statusLabel.TextColor3 = COLOR_GRAY
        statusLabel.Text = "Проверка ключа..."
        local url = SERVER_IP .. "/check_key?hwid=" .. hwid .. "&key=" .. savedKey
        local success, response = pcall(function() return game:HttpGet(url) end)
        if success and response then
            local validJSON, data = pcall(function() return HttpService:JSONDecode(response) end)
            if validJSON and data and data.valid then
                StartMainCheat(savedKey)
                return 
            end
        end
        statusLabel.Text = ""
    end
end)
