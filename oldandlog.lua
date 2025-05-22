-- // НАСТРОЙКИ
local placeId = 126884695634066
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local jobSourceUrl = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"

-- // ПЕРЕМЕННЫЕ
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local jobIds = {}
local currentIndex = 1
local running = false
local delayTime = 10

-- // ЗАГРУЗКА JOBID
local function loadJobIds()
    local raw = game:HttpGet(jobSourceUrl)
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
    sendLog("✅ Загружено серверов: " .. #jobIds)
end

-- // ОТПРАВКА В DISCORD
function sendLog(message)
    local data = {
        ["content"] = message
    }
    local success, err = pcall(function()
        game:HttpPost(webhookUrl, game:GetService("HttpService"):JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("❌ Webhook отправка не удалась:", err)
    end
end

-- // ТЕЛЕПОРТ
local function teleportNext()
    if currentIndex > #jobIds then
        sendLog("✅ Все сервера проверены.")
        running = false
        return
    end

    local jobId = jobIds[currentIndex]
    sendLog("🔄 Телепорт на сервер #" .. currentIndex .. ": `" .. jobId .. "`")

    local success, result = pcall(function()
        return TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)

    if not success then
        sendLog("❌ Ошибка при pcall телепорта: " .. tostring(result))
    elseif typeof(result) == "EnumItem" and result ~= Enum.TeleportResult.Success then
        sendLog("⚠️ TeleportResult: " .. tostring(result))
    end

    currentIndex += 1
end

-- // ГУИ
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.Text = "▶️ Старт"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

local delayLabel = Instance.new("TextLabel", frame)
delayLabel.Size = UDim2.new(1, 0, 0, 20)
delayLabel.Position = UDim2.new(0, 0, 0, 50)
delayLabel.Text = "Задержка (сек):"
delayLabel.TextColor3 = Color3.new(1,1,1)
delayLabel.BackgroundTransparency = 1

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(1, 0, 0, 30)
delayBox.Position = UDim2.new(0, 0, 0, 70)
delayBox.Text = tostring(delayTime)
delayBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
delayBox.TextColor3 = Color3.new(1,1,1)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 110)
statusLabel.Text = "Ожидание..."
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1

-- // ЦИКЛ
task.spawn(function()
    while true do
        if running then
            local delayValue = tonumber(delayBox.Text)
            if delayValue then delayTime = delayValue end
            statusLabel.Text = "⏳ Сервер #" .. tostring(currentIndex)
            teleportNext()
        end
        task.wait(delayTime)
    end
end)

-- // СТАРТ/СТОП
toggleButton.MouseButton1Click:Connect(function()
    running = not running
    toggleButton.Text = running and "⏹️ Стоп" or "▶️ Старт"
end)

-- // ИНИЦИАЛИЗАЦИЯ
sendLog("🟢 Запуск скрипта. Подключение к Webhook успешно.")
loadJobIds()
