local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local jobIds = {}
local webhookUrl = ""
local placeId = game.PlaceId
local universeId = nil

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "ServerTool"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local function createButton(text, position, onClick)
    local button = Instance.new("TextButton", mainFrame)
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.MouseButton1Click:Connect(onClick)
    return button
end

local function sendWebhook(msg)
    if webhookUrl == "" then return end
    local payload = {
        content = msg
    }
    local req = {
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    }
    local success, response = pcall(function()
        if syn and syn.request then
            return syn.request(req)
        elseif request then
            return request(req)
        elseif http_request then
            return http_request(req)
        end
    end)
    if not success then warn("Webhook error", response) end
end

-- === Загрузка JobId из ссылки ===
local function loadJobIds()
    local success, data = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/main/servers.txt")
    end)
    if success then
        jobIds = {}
        for line in string.gmatch(data, "[^\r\n]+") do
            table.insert(jobIds, line)
        end
        print("Загружено JobId:", #jobIds)
    else
        warn("Не удалось загрузить список серверов")
    end
end

-- === Первая функция: попытка телепортироваться ===
local function tryTeleportAll()
    for i, jobId in ipairs(jobIds) do
        sendWebhook("🌀 Попытка телепорта: " .. jobId)
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end)
        if not success then
            print("❌ Не удалось телепортироваться на сервер:", jobId)
        end
        wait(10)
    end
end

-- === Вторая функция: получить инфо о серверах по jobId ===
local function getServerInfo(jobId)
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.id == jobId then
                print("ℹ️ JobId:", jobId, "| Игроков:", server.playing, "/", server.maxPlayers)
                return true
            end
        end
        print("❌ Сервер не найден:", jobId)
    else
        warn("Ошибка получения серверов")
    end
end

-- === Кнопки ===
createButton("Проверить сервера (TP)", UDim2.new(0.05, 0, 0.2, 0), function()
    loadJobIds()
    tryTeleportAll()
end)

createButton("Проверить инфо", UDim2.new(0.05, 0, 0.35, 0), function()
    loadJobIds()
    for _, jobId in ipairs(jobIds) do
        getServerInfo(jobId)
        wait(1)
    end
end)
