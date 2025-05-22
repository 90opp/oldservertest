-- 📦 Сервисы
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ⚙️ Конфигурация
local placeId = 126884695634066
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"

-- 🧠 Переменные
local jobIds = {}
local teleporting = false
local delayTime = 10 -- по умолчанию 10 секунд
local currentIndex = 1

-- 🌐 Функция отправки webhook
local function sendLog(message)
    local data = {
        content = tostring(message)
    }

    local success, result = pcall(function()
        return game:HttpPost(
            webhookUrl,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        print("✅ Webhook отправлен.")
    else
        warn("❌ Ошибка при отправке Webhook: ", result)
    end
end

-- 📂 Загрузка jobId
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("✅ Загружено серверов: " .. #jobIds)
    sendLog("🟢 Запуск скрипта. Подключение к Webhook успешно.\n✅ Загружено серверов: " .. #jobIds)
end

-- 🔁 Цикл телепорта
local function teleportLoop()
    while teleporting and currentIndex <= #jobIds do
        local jobId = jobIds[currentIndex]
        local msg = "🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId
        print(msg)
        sendLog(msg)

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        if not success then
            warn("❌ Ошибка телепорта: ", err)
            sendLog("❌ Ошибка телепорта на #" .. currentIndex .. ": " .. tostring(err))
        end

        currentIndex += 1
        task.wait(delayTime)
    end

    if currentIndex > #jobIds then
        sendLog("🛑 Все серверы проверены.")
        print("🛑 Все серверы проверены.")
        teleporting = false
    end
end

-- 🧱 Интерфейс
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "TeleportGui"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2

local startButton = Instance.new("TextButton", frame)
startButton.Size = UDim2.new(0, 100, 0, 30)
startButton.Position = UDim2.new(0, 10, 0, 10)
startButton.Text = "▶️ Старт"
startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startButton.TextColor3 = Color3.new(1, 1, 1)

local stopButton = Instance.new("TextButton", frame)
stopButton.Size = UDim2.new(0, 100, 0, 30)
stopButton.Position = UDim2.new(0, 130, 0, 10)
stopButton.Text = "⛔ Стоп"
stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopButton.TextColor3 = Color3.new(1, 1, 1)

local delayLabel = Instance.new("TextLabel", frame)
delayLabel.Size = UDim2.new(0, 220, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 50)
delayLabel.Text = "⏱ Задержка (сек):"
delayLabel.TextColor3 = Color3.new(1, 1, 1)
delayLabel.BackgroundTransparency = 1

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(0, 220, 0, 30)
delayBox.Position = UDim2.new(0, 10, 0, 75)
delayBox.Text = tostring(delayTime)
delayBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
delayBox.TextColor3 = Color3.new(1, 1, 1)

local indexLabel = Instance.new("TextLabel", frame)
indexLabel.Size = UDim2.new(0, 220, 0, 20)
indexLabel.Position = UDim2.new(0, 10, 0, 110)
indexLabel.Text = "🔢 Текущий индекс: 1"
indexLabel.TextColor3 = Color3.new(1, 1, 1)
indexLabel.BackgroundTransparency = 1

-- 🎛 Обработчики
startButton.MouseButton1Click:Connect(function()
    if not teleporting then
        currentIndex = 1
        teleporting = true
        local newDelay = tonumber(delayBox.Text)
        if newDelay and newDelay >= 1 then
            delayTime = newDelay
        end
        teleportLoop()
    end
end)

stopButton.MouseButton1Click:Connect(function()
    teleporting = false
    print("🛑 Остановка.")
end)

-- 🚀 Старт
loadJobIds()
