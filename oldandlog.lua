local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local placeId = 126884695634066
local jobIds = {}
local currentIndex = 1
local running = false
local delayBetween = 10

-- Функция отправки логов в Discord
local function sendLog(message)
    local payload = {
        content = message
    }
    local success, err = pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Не удалось отправить лог:", err)
    end
end

-- Загружаем jobId'ы с твоего файла
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
    sendLog("✅ Загружено серверов: " .. #jobIds)
end

-- Обработчик ошибок телепортации
TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
    sendLog("❌ Ошибка телепорта: " .. tostring(result) .. " | " .. tostring(errorMessage or ""))
end)

-- Попытка телепортации
local function teleportNext()
    if currentIndex > #jobIds then
        sendLog("✅ Все сервера проверены.")
        running = false
        return
    end

    local jobId = jobIds[currentIndex]
    sendLog("🔄 Пытаемся телепортироваться на сервер #" .. currentIndex .. " | JobId: `" .. jobId .. "`")

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)

    if not success then
        sendLog("⚠️ pcall ошибка при телепорте: " .. tostring(err))
    end

    currentIndex += 1
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TeleportAutoGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 250, 0, 130)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "▶️ Старт"
Toggle.TextSize = 20
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
Instance.new("UICorner", Toggle)

local DelayBox = Instance.new("TextBox", Frame)
DelayBox.Size = UDim2.new(1, -20, 0, 30)
DelayBox.Position = UDim2.new(0, 10, 0, 60)
DelayBox.PlaceholderText = "Задержка (сек)"
DelayBox.Text = tostring(delayBetween)
DelayBox.TextSize = 18
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", DelayBox)

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 95)
Status.Text = "Остановлено"
Status.TextSize = 16
Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1

-- Запуск цикла
local function startLoop()
    running = true
    Toggle.Text = "⏹️ Стоп"
    Toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    Status.Text = "Работает..."
    task.spawn(function()
        while running do
            teleportNext()
            task.wait(delayBetween)
        end
    end)
end

local function stopLoop()
    running = false
    Toggle.Text = "▶️ Старт"
    Toggle.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    Status.Text = "Остановлено"
end

Toggle.MouseButton1Click:Connect(function()
    if running then
        stopLoop()
    else
        delayBetween = tonumber(DelayBox.Text) or 10
        currentIndex = 1
        startLoop()
    end
end)

-- Старт
loadJobIds()
sendLog("🔔 Скрипт запущен. Готов к работе.")
