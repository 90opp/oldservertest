-- Настройки
local placeId = 126884695634066
local interval = 10
local webhook = "https://discord.com/api/webhooks/1375024901660086272/agHw7Y_gbnMZkwiXtLLGjYWE0EN4dW3t9ShQ3Auc5OtbkUF7_5V5PF8IQS21kEwAup3X" -- Замените на ваш Webhook

-- Roblox сервисы
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Переменные
local jobIds = {}
local currentIndex = 1
local running = false

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TeleportGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 250, 0, 160)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Start"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 60)
SpeedBox.PlaceholderText = "Интервал (сек)"
SpeedBox.Text = tostring(interval)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 20

local CurrentLabel = Instance.new("TextLabel", Frame)
CurrentLabel.Size = UDim2.new(1, -20, 0, 25)
CurrentLabel.Position = UDim2.new(0, 10, 0, 100)
CurrentLabel.Text = "Сервер: -"
CurrentLabel.BackgroundTransparency = 1
CurrentLabel.TextColor3 = Color3.new(1, 1, 1)
CurrentLabel.Font = Enum.Font.SourceSansBold
CurrentLabel.TextSize = 20
CurrentLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Универсальная функция запроса
local function universalRequest(tbl)
    local req = (syn and syn.request) or
                (http and http.request) or
                (request) or
                (fluxus and fluxus.request) or
                (krnl and krnl.request) or
                (krnl_http_request)
    if req then
        return req(tbl)
    else
        warn("❌ HTTP-запрос не поддерживается данным экзекьютором")
    end
end

-- Функция отправки webhook
local function sendWebhook(message)
    universalRequest({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({content = message})
    })
end

-- Обработка ошибок телепорта
TeleportService.TeleportInitFailed:Connect(function(_, result)
    local jobId = jobIds[currentIndex - 1] or "?"
    local msg = "❌ Ошибка телепорта:\nJobId: `" .. jobId .. "`\nПричина: `" .. tostring(result) .. "`"
    warn(msg)
    sendWebhook(msg)
end)

-- Загрузка JobId
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
end

-- Основной цикл
local function teleportLoop()
    while running do
        if currentIndex > #jobIds then
            currentIndex = 1
        end

        local jobId = jobIds[currentIndex]
        CurrentLabel.Text = "Сервер: " .. tostring(currentIndex) .. "/" .. tostring(#jobIds)

        local msg = "🔄 Попытка " .. tostring(currentIndex) .. "/" .. tostring(#jobIds) ..
                    "\nJobId: `" .. jobId .. "`\n✅ Телепорт вызван (если не перенесло — сервер фулл или невалид)"
        sendWebhook(msg)

        currentIndex += 1
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        task.wait(interval)
    end
end

-- Обработка кнопки
local function toggle()
    running = not running
    ToggleButton.Text = running and "Stop" or "Start"
    ToggleButton.BackgroundColor3 = running and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)

    if running then
        interval = tonumber(SpeedBox.Text) or 10
        coroutine.wrap(teleportLoop)()
    end
end

ToggleButton.MouseButton1Click:Connect(toggle)

-- Запуск
loadJobIds()
