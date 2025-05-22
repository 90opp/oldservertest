local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId -- автоматом из текущей игры
local jobIds = {
    "27a4c470-5756-4d09-a8e7-31fd87f183fd",
    -- добавь другие jobId ниже
}

local isRunning = false
local delayTime = 10
local currentIndex = 1
local webhookUrl = ""

-- ========== Webhook ==========
local function sendRequest(req)
    if syn and syn.request then
        return syn.request(req)
    elseif http_request then
        return http_request(req)
    elseif request then
        return request(req)
    else
        warn("❌ HTTP request функция недоступна")
        return nil
    end
end

local function sendWebhook(msg)
    if webhookUrl == "" then return end
    local payload = { content = msg }
    local success, res = pcall(function()
        return sendRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)
    if not success then
        warn("Webhook error:", res)
    end
end

-- ========== GUI ==========
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "JobHopTool"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 320, 0, 210)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0

local closeButton = Instance.new("TextButton", mainFrame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "✖"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local startButton = Instance.new("TextButton", mainFrame)
startButton.Size = UDim2.new(0.45, 0, 0, 40)
startButton.Position = UDim2.new(0.05, 0, 0.65, 0)
startButton.Text = "Старт"
startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
startButton.TextColor3 = Color3.new(1, 1, 1)

local stopButton = Instance.new("TextButton", mainFrame)
stopButton.Size = UDim2.new(0.45, 0, 0, 40)
stopButton.Position = UDim2.new(0.5, 0, 0.65, 0)
stopButton.Text = "Стоп"
stopButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopButton.TextColor3 = Color3.new(1, 1, 1)

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

-- ========== Безопасный телепорт ==========
local function safeTeleport(jobId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    if not success then
        warn("❌ Ошибка телепорта на " .. jobId .. ": " .. tostring(err))
        sendWebhook("❌ Не удалось телепортироваться на сервер " .. jobId .. ": " .. tostring(err))
    else
        print("🔄 Попытка телепорта: " .. jobId)
        sendWebhook("🔄 Попытка телепорта на сервер " .. jobId)
    end
end

local function startCycle()
    isRunning = true
    while isRunning and currentIndex <= #jobIds do
        local jobId = jobIds[currentIndex]
        safeTeleport(jobId)
        currentIndex += 1
        wait(delayTime)
    end
    isRunning = false
end

startButton.MouseButton1Click:Connect(function()
    if not isRunning then
        webhookUrl = webhookBox.Text
        delayTime = tonumber(delayBox.Text) or 10
        currentIndex = 1
        sendWebhook("🟢 Старт обхода серверов.")
        startCycle()
    end
end)

stopButton.MouseButton1Click:Connect(function()
    isRunning = false
    sendWebhook("🔴 Остановка обхода.")
end)
