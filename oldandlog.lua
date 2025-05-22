-- ✅ Настройки
local placeId = 126884695634066
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local delayBetweenTeleports = 10 -- секунд

-- 📦 Переменные
local jobIds = {}
local running = false
local currentIndex = 1

-- 🔗 Функция отправки в Webhook
local function sendWebhook(message)
    local payload = {
        content = message
    }
    
    local encoded = game:GetService("HttpService"):JSONEncode(payload)

    local response = syn.request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = encoded
    })

    if response.StatusCode == 200 or response.StatusCode == 204 then
        print("📨 Webhook отправлен успешно.")
    else
        warn("❌ Ошибка отправки webhook:", response.StatusCode, response.Body)
    end
end

-- 🔄 Загрузка серверов
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("✅ Загружено серверов:", #jobIds)
    sendWebhook("🟢 Скрипт запущен. Загружено серверов: " .. #jobIds)
end

-- ⏩ Функция телепорта
local function teleportLoop()
    while running and currentIndex <= #jobIds do
        local jobId = jobIds[currentIndex]
        print("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        sendWebhook("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        
        game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, jobId, game.Players.LocalPlayer)
        
        currentIndex += 1
        wait(delayBetweenTeleports)
    end
end

-- 🖼️ GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0.5, -110, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local StartStopButton = Instance.new("TextButton", Frame)
StartStopButton.Size = UDim2.new(1, -10, 0, 40)
StartStopButton.Position = UDim2.new(0, 5, 0, 5)
StartStopButton.Text = "▶ Старт"
StartStopButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
StartStopButton.TextColor3 = Color3.new(1, 1, 1)

local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Size = UDim2.new(1, -10, 0, 30)
CloseButton.Position = UDim2.new(0, 5, 1, -35)
CloseButton.Text = "✖ Закрыть GUI"
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CloseButton.TextColor3 = Color3.new(1, 1, 1)

-- ⏯️ Обработчики кнопок
StartStopButton.MouseButton1Click:Connect(function()
    running = not running
    if running then
        StartStopButton.Text = "⏹ Стоп"
        StartStopButton.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
        teleportLoop()
    else
        StartStopButton.Text = "▶ Старт"
        StartStopButton.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 🚀 Старт
loadJobIds()
