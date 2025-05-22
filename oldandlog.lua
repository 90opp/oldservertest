local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = 126884695634066
local webhookUrl = "https://discord.com/api/webhooks/..." -- <<< ВСТАВЬ СВОЙ WEBHOOK СЮДА

local jobIds = {}
local currentIndex = 1
local running = false
local interval = 10

-- Загружаем список jobId
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
end

-- Webhook логер
local function logToDiscord(text)
    local payload = { content = text }
    local requestData = {
        Url = webhookUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    }

    pcall(function()
        if syn and syn.request then
            syn.request(requestData)
        elseif request then
            request(requestData)
        elseif http_request then
            http_request(requestData)
        end
    end)
end

-- Телепорт по очереди
local function teleportLoop()
    while running do
        if currentIndex > #jobIds then
            currentIndex = 1
        end

        local jobId = jobIds[currentIndex]
        CurrentLabel.Text = "Сервер: " .. tostring(currentIndex) .. "/" .. tostring(#jobIds)
        local logMessage = string.format("🔄 Попытка %d/%d\nJobId: `%s`", currentIndex, #jobIds, jobId)
        logToDiscord(logMessage)

        currentIndex += 1

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end)

        if not success then
            logToDiscord("❌ Ошибка телепорта: `" .. tostring(err) .. "`")
        else
            logToDiscord("✅ Телепорт вызван (если не перенесло — сервер фулл или невалидный)")
        end

        task.wait(interval)
    end
end

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

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

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

-- Новый элемент: текущий номер
CurrentLabel = Instance.new("TextLabel", Frame)
CurrentLabel.Size = UDim2.new(1, -20, 0, 25)
CurrentLabel.Position = UDim2.new(0, 10, 0, 100)
CurrentLabel.Text = "Сервер: -"
CurrentLabel.BackgroundTransparency = 1
CurrentLabel.TextColor3 = Color3.new(1, 1, 1)
CurrentLabel.Font = Enum.Font.SourceSansBold
CurrentLabel.TextSize = 20
CurrentLabel.TextXAlignment = Enum.TextXAlignment.Center

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

-- Загружаем jobId при запуске
loadJobIds()
