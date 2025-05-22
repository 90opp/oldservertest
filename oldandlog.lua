--// Настройки
local PLACE_ID = 126884695634066
local WEBHOOK_URL = "https://discord.com/api/webhooks/1369788968308183100/92N-vJra_IFxv2hCsGrr1P27s0fOz-7EFAPXWufAw0suTjOqpDdMmAttDUUXIlPf3-ze"

--// Переменные
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local running = false
local jobIds = {}
local currentIndex = 0
local delaySeconds = 10

--// Функция отправки Webhook через HttpGet
local function sendWebhook(message)
    local url = WEBHOOK_URL .. "?wait=true&content=" .. HttpService:UrlEncode(message)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        warn("❌ Webhook Error: " .. tostring(response))
    else
        print("✅ Webhook отправлен.")
    end
end

--// Загрузка JobId из файла
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("✅ Загружено серверов:", #jobIds)
    sendWebhook("🟢 Скрипт запущен. Загружено серверов: " .. tostring(#jobIds))
end

--// Телепорт по списку
local function teleportLoop()
    while running and currentIndex < #jobIds do
        currentIndex += 1
        local jobId = jobIds[currentIndex]
        print("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)
        sendWebhook("🔄 Телепорт на сервер #" .. currentIndex .. ": " .. jobId)

        pcall(function()
            TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
        end)

        wait(delaySeconds)
    end
end

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0

local toggleButton = Instance.new("TextButton", Frame)
toggleButton.Size = UDim2.new(0, 280, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "▶ Старт"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20

local delayBox = Instance.new("TextBox", Frame)
delayBox.Size = UDim2.new(0, 280, 0, 30)
delayBox.Position = UDim2.new(0, 10, 0, 60)
delayBox.PlaceholderText = "Задержка (сек): по умолчанию 10"
delayBox.Text = ""
delayBox.TextColor3 = Color3.new(1,1,1)
delayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
delayBox.Font = Enum.Font.SourceSans
delayBox.TextSize = 18

local closeButton = Instance.new("TextButton", Frame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20

--// Обработчики кнопок
toggleButton.MouseButton1Click:Connect(function()
    if running then
        running = false
        toggleButton.Text = "▶ Старт"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
    else
        local val = tonumber(delayBox.Text)
        if val then
            delaySeconds = val
        end
        running = true
        toggleButton.Text = "⏸ Стоп"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        spawn(teleportLoop)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--// Запуск
loadJobIds()
