-- ⚙ Настройки
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local serverListUrl = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"
local placeId = 126884695634066

-- 📦 Переменные
local jobIds = {}
local currentIndex = 1
local running = false
local delaySeconds = 10

-- 📡 Отправка логов в Discord
local function sendLog(message)
    local json = game:GetService("HttpService"):JSONEncode({ content = message })
    local req = (http_request or request or syn and syn.request)

    if req then
        pcall(function()
            req({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = json
            })
        end)
    else
        warn("❌ Нет поддержки HTTP-запросов в вашем эксплойте.")
    end
end

-- ✅ Тестируем Webhook при запуске
sendLog("🟢 Запуск скрипта. Подключение к Webhook успешно.")

-- 🔁 Загрузка JobId
local function loadJobIds()
    local success, result = pcall(function()
        return game:HttpGet(serverListUrl)
    end)

    if success then
        for jobId in string.gmatch(result, "[^\r\n]+") do
            table.insert(jobIds, jobId)
        end
        print("✅ Загружено серверов:", #jobIds)
        sendLog("✅ Загружено серверов: " .. tostring(#jobIds))
    else
        warn("❌ Ошибка загрузки серверов:", result)
        sendLog("❌ Ошибка загрузки серверов: " .. tostring(result))
    end
end

-- 🚀 Телепорт по JobId
local function teleportNext()
    if currentIndex > #jobIds then
        sendLog("🔁 Все сервера проверены. Сброс.")
        currentIndex = 1
        return
    end

    local jobId = jobIds[currentIndex]
    sendLog("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)

    local success, err = pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, jobId, game.Players.LocalPlayer)
    end)

    if not success then
        warn("⚠ Ошибка телепорта: ", err)
        sendLog("⚠ Ошибка телепорта: " .. tostring(err))
    end

    currentIndex += 1
end

-- ⏱️ Основной цикл
task.spawn(function()
    while true do
        if running then
            teleportNext()
            task.wait(delaySeconds)
        else
            task.wait(1)
        end
    end
end)

-- 🖼️ GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 140)
Frame.Position = UDim2.new(0.5, -125, 0.5, -70)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local toggle = Instance.new("TextButton", Frame)
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Text = "▶ Старт"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

local delayBox = Instance.new("TextBox", Frame)
delayBox.Size = UDim2.new(1, -20, 0, 30)
delayBox.Position = UDim2.new(0, 10, 0, 60)
delayBox.PlaceholderText = "Задержка (сек)"
delayBox.Text = tostring(delaySeconds)
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local statusLabel = Instance.new("TextLabel", Frame)
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 100)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ожидание..."

-- 🔘 Обработка кнопок
toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "⏸ Стоп" or "▶ Старт"
    toggle.BackgroundColor3 = running and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
    statusLabel.Text = running and "✅ Активно" or "⏸ Остановлено"
end)

delayBox.FocusLost:Connect(function()
    local value = tonumber(delayBox.Text)
    if value and value >= 1 then
        delaySeconds = value
    else
        delayBox.Text = tostring(delaySeconds)
    end
end)

-- ⏬ Загрузка серверов при старте
loadJobIds()
