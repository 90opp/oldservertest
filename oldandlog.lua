-- // Настройки
local placeId = 126884695634066
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local serversUrl = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"
local delayBetweenTeleports = 10 -- по умолчанию 10 секунд

-- // Службы
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Переменные
local jobIds = {}
local running = false
local currentIndex = 0

-- // GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 10)

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "▶ Старт"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(1, -20, 0, 30)
delayBox.Position = UDim2.new(0, 10, 0, 60)
delayBox.PlaceholderText = "Задержка (сек)"
delayBox.Text = tostring(delayBetweenTeleports)
delayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
delayBox.TextColor3 = Color3.new(1, 1, 1)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 100)
statusLabel.Text = "🟢 Готов к запуску"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.BackgroundTransparency = 1

-- // Webhook отправка
local function sendLog(message)
    if #message > 2000 then
        message = string.sub(message, 1, 2000)
    end
    local data = { content = message }
    local success, err = pcall(function()
        return game:HttpPost(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("❌ Webhook ошибка: ", err)
    end
end

-- // Загрузка серверов
local function loadJobIds()
    jobIds = {}
    local raw = game:HttpGet(serversUrl)
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("✅ Загружено серверов: " .. #jobIds)
    sendLog("✅ Загружено серверов: " .. #jobIds)
end

-- // Телепортация
local function teleportToNext()
    currentIndex += 1
    if currentIndex > #jobIds then
        sendLog("⚠️ Все сервера просмотрены.")
        statusLabel.Text = "⛔ Конец списка"
        return
    end

    local jobId = jobIds[currentIndex]
    local msg = "🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId
    print(msg)
    sendLog(msg)

    local success, result = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)

    if not success then
        sendLog("❌ Ошибка телепорта: " .. tostring(result))
        warn("Ошибка телепорта:", result)
    end
end

-- // Цикл телепорта
local function startTeleportLoop()
    while running do
        teleportToNext()
        task.wait(delayBetweenTeleports)
    end
end

-- // Кнопка
toggleButton.MouseButton1Click:Connect(function()
    if not running then
        running = true
        toggleButton.Text = "⏹ Стоп"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        statusLabel.Text = "▶ Запущено"

        -- Применяем новую задержку
        local num = tonumber(delayBox.Text)
        if num and num > 0 then
            delayBetweenTeleports = num
        end

        currentIndex = 0
        task.spawn(startTeleportLoop)
    else
        running = false
        toggleButton.Text = "▶ Старт"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
        statusLabel.Text = "⏹ Остановлено"
        sendLog("⛔ Телепорт остановлен вручную.")
    end
end)

-- // Первый запуск
sendLog("🟢 Запуск скрипта. Подключение к Webhook успешно.")
loadJobIds()
