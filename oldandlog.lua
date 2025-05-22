local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local placeId = 126884695634066

local jobIds = {}
local currentIndex = 1
local isRunning = false
local delayTime = 10 -- секунды по умолчанию
local teleportConnection

-- Функция отправки сообщения в Discord
local function sendLog(message)
    local data = {
        content = message
    }
    local jsonData = HttpService:JSONEncode(data)

    local success, response = pcall(function()
        game:HttpPost(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("❌ Ошибка отправки webhook: ", response)
    end
end

-- Функция загрузки jobId из ссылки
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    jobIds = {}
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    sendLog("✅ Загружено серверов: "..#jobIds)
end

-- Функция телепорта (без ожидания результата, чтобы можно было вручную нажать "ОК")
local function teleportToNextServer()
    if not isRunning then return end
    if #jobIds == 0 then
        sendLog("❌ Список серверов пуст. Загрузка...")
        loadJobIds()
        if #jobIds == 0 then
            sendLog("❌ Не удалось загрузить серверы. Остановка.")
            isRunning = false
            updateGui()
            return
        end
    end

    local jobId = jobIds[currentIndex]
    sendLog("🔄 Телепорт на сервер #" .. tostring(currentIndex) .. ": " .. jobId)

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)

    if not success then
        sendLog("❌ Ошибка телепорта: " .. tostring(err))
    end

    currentIndex = currentIndex + 1
    if currentIndex > #jobIds then
        currentIndex = 1
        sendLog("🔁 Перезапуск списка серверов.")
    end
end

-- GUI

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Телепорт на серверы"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local delayLabel = Instance.new("TextLabel")
delayLabel.Position = UDim2.new(0, 10, 0, 40)
delayLabel.Size = UDim2.new(0, 120, 0, 20)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Задержка (сек):"
delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
delayLabel.Font = Enum.Font.SourceSans
delayLabel.TextSize = 16
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = frame

local delayBox = Instance.new("TextBox")
delayBox.Position = UDim2.new(0, 130, 0, 38)
delayBox.Size = UDim2.new(0, 130, 0, 24)
delayBox.Text = tostring(delayTime)
delayBox.ClearTextOnFocus = false
delayBox.TextColor3 = Color3.fromRGB(0, 0, 0)
delayBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
delayBox.Font = Enum.Font.SourceSans
delayBox.TextSize = 18
delayBox.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Position = UDim2.new(0, 10, 0, 70)
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 22
toggleButton.Text = "Старт"
toggleButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Text = "X"
closeButton.Parent = frame

local function updateGui()
    toggleButton.Text = isRunning and "Стоп" or "Старт"
    delayBox.Text = tostring(delayTime)
    delayBox.ClearTextOnFocus = false
    delayBox.BackgroundColor3 = isRunning and Color3.fromRGB(170,170,170) or Color3.fromRGB(240,240,240)
    delayBox.TextEditable = not isRunning
end

toggleButton.MouseButton1Click:Connect(function()
    if isRunning then
        -- Стоп
        isRunning = false
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        sendLog("⏹ Телепорт остановлен.")
    else
        -- Запуск
        local inputDelay = tonumber(delayBox.Text)
        if inputDelay and inputDelay >= 1 then
            delayTime = inputDelay
        else
            delayTime = 10
            delayBox.Text = "10"
        end
        isRunning = true
        sendLog("▶ Телепорт запущен. Задержка: "..delayTime.." сек.")
        -- Начинаем цикл телепорта
        teleportToNextServer()
        if teleportConnection then teleportConnection:Disconnect() end
        teleportConnection = RunService.Heartbeat:Connect(function(step)
            -- Используем счетчик времени
            if not isRunning then return end
            local acc = 0
            acc = acc + step
            if acc >= delayTime then
                acc = 0
                teleportToNextServer()
            end
        end)
    end
    updateGui()
end)

closeButton.MouseButton1Click:Connect(function()
    isRunning = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
    screenGui:Destroy()
end)

updateGui()
loadJobIds()
sendLog("🟢 Скрипт запущен. Ждем команд.")
