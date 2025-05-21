local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = 126884695634066

local jobIds = {}
local currentIndex = 1

-- Загружаем список jobId из GitHub
local function loadJobIds()
    local raw = game:HttpGet("https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt")
    for jobId in string.gmatch(raw, "[^\r\n]+") do
        table.insert(jobIds, jobId)
    end
    print("Загружено серверов:", #jobIds)
end

-- Простой телепорт по очереди без проверок
local function teleportNext()
    if currentIndex > #jobIds then
        currentIndex = 1
    end
    local jobId = jobIds[currentIndex]
    currentIndex += 1

    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

-- Основной цикл
loadJobIds()

while true do
    teleportNext()
    task.wait(5) -- Подождать перед следующим телепортом (ждём пока нажмёшь OK)
end
