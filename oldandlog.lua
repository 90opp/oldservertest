-- Инициализация переменных
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local isRunning = false
local currentIndex = 1
local jobIds = {}
local webhookUrl = ""
local delayTime = 10

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "TPTool"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0

local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Text = "✖"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local startButton = Instance.new("TextButton", mainFrame)
startButton.Text = "Старт"
startButton.Size = UDim2.new(0.45, 0, 0, 40)
startButton.Position = UDim2.new(0.05, 0, 0.65, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local stopButton = Instance.new("TextButton", mainFrame)
stopButton.Text = "Стоп"
stopButton.Size = UDim2.new(0.45, 0, 0, 40)
stopButton.Position = UDim2.new(0.5, 0, 0.65, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local delayBox = Instance.new("TextBox", mainFrame)
delayBox.PlaceholderText = "Задержка (сек)"
delayBox.Size = UDim2.new(0.9, 0, 0, 30)
delayBox.Position = UDim2.new(0.05, 0, 0.15, 0)
delayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
delayBox.TextColor3 = Color3.new(1, 1, 1)

local webhookBox = Instance.new("TextBox", mainFrame)
webhookBox.PlaceholderText = "Discord Webhook URL"
webhookBox.Size = UDim2.new(0.9, 0, 0, 30)
webhookBox.Position = UDim2.new(0.05, 0, 0.35, 0)
webhookBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
webhookBox.TextColor3 = Color3.new(1, 1, 1)

-- Функция отправки в webhook
local function sendWebhook(message)
    if webhookUrl == "" then return end
    local payload = {
        ["content"] = message
    }
    local success, response = pcall(function()
        return syn.request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
    if not success then
        warn("❌ Webhook Error:", response)
    end
end

-- Загрузка jobId'ов
local function loadJobIds()
    local success, raw = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    end)
    if success then
        for jobId in string.gmatch(raw, "[^\r\n]+") do
            table.insert(jobIds, jobId)
        end
        sendWebhook("🟢 Скрипт запущен. Загружено серверов: " .. #jobIds)
        print("Загружено серверов:", #jobIds)
    else
        warn("Не удалось загрузить сервера")
    end
end

-- Телепортация
local function startTeleporting()
    isRunning = true
    while isRunning and currentIndex <= #jobIds do
        local jobId = jobIds[currentIndex]
        print("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        sendWebhook("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
        wait(delayTime)
        currentIndex += 1
    end
end

-- Обработчики кнопок
startButton.MouseButton1Click:Connect(function()
    if not isRunning then
        webhookUrl = webhookBox.Text
        delayTime = tonumber(delayBox.Text) or 10
        currentIndex = 1
        startTeleporting()
    end
end)

stopButton.MouseButton1Click:Connect(function()
    isRunning = false
end)

-- Запуск
loadJobIds()
