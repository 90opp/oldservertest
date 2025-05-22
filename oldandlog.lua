local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Настройки
local placeId = 126884695634066
local interval = 10 -- интервал между телепортами (в секундах)
local webhookURL = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"

-- GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleportGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 130)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0

local StartButton = Instance.new("TextButton", Frame)
StartButton.Size = UDim2.new(1, -20, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 10)
StartButton.Text = "▶️ Старт"
StartButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)

local StopButton = Instance.new("TextButton", Frame)
StopButton.Size = UDim2.new(1, -20, 0, 40)
StopButton.Position = UDim2.new(0, 10, 0, 55)
StopButton.Text = "⏹️ Стоп"
StopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)

local CurrentLabel = Instance.new("TextLabel", Frame)
CurrentLabel.Size = UDim2.new(1, -20, 0, 20)
CurrentLabel.Position = UDim2.new(0, 10, 0, 100)
CurrentLabel.TextColor3 = Color3.new(1, 1, 1)
CurrentLabel.BackgroundTransparency = 1
CurrentLabel.Text = "Сервер: -"

-- Лог в Discord
local function logToDiscord(reason, jobId)
    local data = {
        ["content"] = "❌ [" .. reason .. "] jobId: `" .. jobId .. "`"
    }

    local success, err = pcall(function()
        HttpService:PostAsync(
            webhookURL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if not success then
        warn("Ошибка Discord логирования:", err)
    end
end

-- Загрузка jobId списка
local jobIds = {}
local success, response = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
end)

if success and response then
    for line in string.gmatch(response, "[^\r\n]+") do
        table.insert(jobIds, line)
    end
else
    warn("❌ Не удалось загрузить список серверов.")
    return
end

-- Автотелепорт
local running = false
local currentIndex = 1

local function teleportLoop()
    while running do
        if currentIndex > #jobIds then
            currentIndex = 1
        end

        local jobId = jobIds[currentIndex]
        CurrentLabel.Text = "Сервер: " .. tostring(currentIndex) .. "/" .. tostring(#jobIds)

        local success, result = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end)

        if not success then
            logToDiscord("TeleportError", jobId)
        end

        currentIndex += 1
        task.wait(interval)
    end
end

-- GUI обработчики
StartButton.MouseButton1Click:Connect(function()
    if not running then
        running = true
        teleportLoop()
    end
end)

StopButton.MouseButton1Click:Connect(function()
    running = false
end)
