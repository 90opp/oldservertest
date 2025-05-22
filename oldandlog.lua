local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local jobIds = {}
local currentIndex = 1
local running = false
local delayBetween = 10

local webhookUrl = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"

-- 📥 Загрузка jobId-ов
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
end

-- 📬 Лог в Discord
local function sendLog(message)
    local payload = HttpService:JSONEncode({ content = message })
    pcall(function()
        HttpService:PostAsync(webhookUrl, payload, Enum.HttpContentType.ApplicationJson)
    end)
end

-- 🚀 Телепорт
local function startTeleport()
    while running and currentIndex <= #jobIds do
        local jobId = jobIds[currentIndex]
        StatusLabel.Text = "Телепорт " .. currentIndex .. "/" .. #jobIds
        sendLog("➡️ Попытка " .. currentIndex .. ": `" .. jobId .. "`")

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
        end)

        if not success then
            sendLog("❌ Ошибка на " .. currentIndex .. ": `" .. tostring(err) .. "`")
        end

        currentIndex += 1
        task.wait(delayBetween)
    end

    running = false
    ToggleButton.Text = "Start"
    StatusLabel.Text = "Finished"
    sendLog("✅ Завершён обход всех серверов.")
end

-- 🖼️ GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleporterGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 170)
Frame.Position = UDim2.new(0.5, -110, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Start"
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

local DelayBox = Instance.new("TextBox", Frame)
DelayBox.Size = UDim2.new(1, -20, 0, 30)
DelayBox.Position = UDim2.new(0, 10, 0, 60)
DelayBox.PlaceholderText = "Delay (sec)"
DelayBox.Text = tostring(delayBetween)
DelayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DelayBox.TextColor3 = Color3.new(1, 1, 1)

StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Idle"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.TextScaled = true

-- 🟢 Кнопка Start/Stop
ToggleButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        ToggleButton.Text = "Start"
        StatusLabel.Text = "Остановлено"
        sendLog("⏹️ Скрипт остановлен вручную.")
    else
        delayBetween = tonumber(DelayBox.Text) or 10
        currentIndex = 1
        jobIds = {}
        loadJobIds()
        if #jobIds > 0 then
            running = true
            ToggleButton.Text = "Stop"
            sendLog("▶️ Запуск обхода серверов...")
            task.spawn(startTeleport)
        else
            StatusLabel.Text = "Список пуст"
        end
    end
end)
