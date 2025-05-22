--// Roblox Discord Webhook GUI + КД

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Функция для безопасного вызова request (Synapse X и др.)
local requestFunc = syn and syn.request or request or http_request
if not requestFunc then
    warn("HTTP request function not found! Запускать нужно в эксплойте.")
    return
end

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WebhookSenderGui"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Text = "Discord Webhook Sender"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Крестик (закрыть)
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Ввод вебхука
local webhookInput = Instance.new("TextBox")
webhookInput.PlaceholderText = "Вставьте Discord Webhook URL"
webhookInput.Size = UDim2.new(1, -20, 0, 40)
webhookInput.Position = UDim2.new(0, 10, 0, 40)
webhookInput.ClearTextOnFocus = false
webhookInput.Text = ""
webhookInput.TextWrapped = true
webhookInput.TextXAlignment = Enum.TextXAlignment.Left
webhookInput.Font = Enum.Font.SourceSans
webhookInput.TextSize = 16
webhookInput.Parent = frame

-- Ввод КД (задержки)
local cdInput = Instance.new("TextBox")
cdInput.PlaceholderText = "Введите задержку между сообщениями (сек)"
cdInput.Size = UDim2.new(1, -20, 0, 40)
cdInput.Position = UDim2.new(0, 10, 0, 90)
cdInput.ClearTextOnFocus = false
cdInput.Text = "5" -- по умолчанию 5 секунд
cdInput.TextXAlignment = Enum.TextXAlignment.Left
cdInput.Font = Enum.Font.SourceSans
cdInput.TextSize = 16
cdInput.Parent = frame

-- Кнопка Старт/Стоп
local startBtn = Instance.new("TextButton")
startBtn.Text = "Старт"
startBtn.Size = UDim2.new(0.5, -15, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 140)
startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 18
startBtn.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Text = "Стоп"
stopBtn.Size = UDim2.new(0.5, -15, 0, 40)
stopBtn.Position = UDim2.new(0.5, 5, 0, 140)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 18
stopBtn.Parent = frame

stopBtn.Visible = false

-- Функция отправки сообщения в Discord webhook
local function SendMessage(url, message)
    local headers = {["Content-Type"] = "application/json"}
    local data = {["content"] = message}
    local body = HttpService:JSONEncode(data)

    local response = requestFunc({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })

    print("Message sent! Status:", response.StatusCode)
    return response.StatusCode == 204 or response.StatusCode == 200
end

-- Переменная для контроля цикла отправки
local sending = false

-- Цикл отправки сообщений с задержкой
local function StartSending()
    local webhook = webhookInput.Text
    local cd = tonumber(cdInput.Text)
    if not webhook or webhook == "" then
        warn("Введите валидный webhook URL")
        return
    end
    if not cd or cd < 1 then
        warn("Введите корректное число для задержки (от 1 секунды)")
        return
    end

    sending = true
    startBtn.Visible = false
    stopBtn.Visible = true

    while sending do
        local success = SendMessage(webhook, "Тестовое сообщение с задержкой " .. cd .. " секунд.")
        if not success then
            warn("Ошибка отправки сообщения!")
        end
        wait(cd)
    end
end

local function StopSending()
    sending = false
    startBtn.Visible = true
    stopBtn.Visible = false
end

startBtn.MouseButton1Click:Connect(StartSending)
stopBtn.MouseButton1Click:Connect(StopSending)
