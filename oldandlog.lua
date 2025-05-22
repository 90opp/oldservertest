-- GUI + авто-телепорт с задержкой + Discord лог
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local running = false
local delayBetween = 10
local jobList = {}
local currentIndex = 1

-- Вставь свой вебхук сюда!
local Webhook_URL = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"

-- ========== GUI ==========
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

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Idle"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.TextScaled = true

-- ========== ФУНКЦИИ ==========

local function sendLog(message)
    local payload = HttpService:JSONEncode({
        content = message
    })

    pcall(function()
        HttpService:PostAsync(Webhook_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
end

local function loadJobIds()
    local success, result = pcall(function()
        return HttpService:GetAsync("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    end)
    if success then
        jobList = {}
        for line in result:gmatch("[^\r\n]+") do
            if line:match("[%w%-]+") then
                table.insert(jobList, line)
            end
        end
        return true
    else
        warn("Ошибка загрузки JobId списка")
        sendLog("❌ Ошибка загрузки списка серверов.")
        return false
    end
end

local function startTeleport()
    while running and currentIndex <= #jobList do
        local jobId = jobList[currentIndex]
        local msg = string.format("➡️ Пытаюсь сервер %d/%d\nJobId: `%s`", currentIndex, #jobList, jobId)
        StatusLabel.Text = "Teleporting " .. currentIndex .. "/" .. #jobList
        sendLog(msg)

        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(tonumber(game.PlaceId), jobId, player)
        end)

        if not success then
            sendLog("⚠️ Ошибка на " .. currentIndex .. ": `" .. tostring(err) .. "`")
        end

        currentIndex += 1
        task.wait(delayBetween)
    end

    running = false
    ToggleButton.Text = "Start"
    StatusLabel.Text = "Finished"
    sendLog("✅ Завершён обход всех серверов.")
end

-- ========== КНОПКА ==========
ToggleButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        ToggleButton.Text = "Start"
        StatusLabel.Text = "Stopped"
        sendLog("⏹️ Скрипт остановлен вручную.")
    else
        delayBetween = tonumber(DelayBox.Text) or 10
        currentIndex = 1
        local loaded = loadJobIds()
        if loaded and #jobList > 0 then
            running = true
            ToggleButton.Text = "Stop"
            sendLog("▶️ Запуск обхода серверов...")
            task.spawn(startTeleport)
        else
            StatusLabel.Text = "Failed to load"
        end
    end
end)
