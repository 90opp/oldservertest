-- СЕРВИСЫ
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- НАСТРОЙКИ
local PLACE_ID = 126884695634066 -- ID вашего плейса
local WEBHOOK_URL = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"
local SERVERS_URL = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"

-- ПЕРЕМЕННЫЕ
local player = Players.LocalPlayer
local jobIds = {}
local running = false
local currentIndex = 0
local delayTime = 10

-- GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "TeleporterGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 10)

local startStopButton = Instance.new("TextButton", frame)
startStopButton.Size = UDim2.new(0, 120, 0, 40)
startStopButton.Position = UDim2.new(0.5, -60, 0, 10)
startStopButton.Text = "▶ Старт"
startStopButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startStopButton.TextColor3 = Color3.new(1, 1, 1)

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(0, 80, 0, 30)
delayBox.Position = UDim2.new(0.5, -40, 0, 60)
delayBox.Text = tostring(delayTime)
delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delayBox.TextColor3 = Color3.new(1, 1, 1)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 100)
label.Text = "Сервер: 0"
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1

local closeButton = Instance.new("TextButton", frame)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)

-- ФУНКЦИИ

local function sendWebhook(message)
    local success, response = pcall(function()
        local payload = HttpService:JSONEncode({
            content = message
        })
        return game:HttpPost(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("❌ Webhook error: " .. tostring(response))
    else
        print("✅ Webhook sent")
    end
end

local function loadJobIds()
    jobIds = {}
    local raw = game:HttpGet(SERVERS_URL)
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
    sendWebhook("✅ Загружено серверов: " .. #jobIds)
end

local function teleportLoop()
    while running do
        currentIndex += 1
        if currentIndex > #jobIds then
            running = false
            startStopButton.Text = "▶ Старт"
            break
        end
        local jobId = jobIds[currentIndex]
        label.Text = "Сервер: " .. currentIndex
        sendWebhook("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        print("Телепорт на:", jobId)
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
        task.wait(delayTime)
    end
end

-- GUI: КНОПКИ

startStopButton.MouseButton1Click:Connect(function()
    if not running then
        delayTime = tonumber(delayBox.Text) or 10
        running = true
        startStopButton.Text = "⏹ Стоп"
        teleportLoop()
    else
        running = false
        startStopButton.Text = "▶ Старт"
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ЗАПУСК

sendWebhook("🟢 Запуск скрипта. Webhook подключен.")
loadJobIds()
