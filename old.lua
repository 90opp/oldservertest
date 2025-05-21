local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local placeId = 126884695634066
local serversUrl = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"

local serverJobIds = {}
local currentIndex = 1

local function fetchServers()
    local success, result = pcall(function()
        return game:HttpGet(serversUrl)
    end)
    if success then
        -- Разбиваем результат по строкам и фильтруем пустые строки
        for line in result:gmatch("[^\r\n]+") do
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed ~= "" then
                table.insert(serverJobIds, trimmed)
            end
        end
        print("Загружено серверов: "..#serverJobIds)
    else
        warn("Не удалось загрузить список серверов:", result)
    end
end

local function tryTeleport()
    if #serverJobIds == 0 then
        warn("Список серверов пуст, повторная загрузка через 10 сек")
        wait(10)
        fetchServers()
        return
    end

    if currentIndex > #serverJobIds then
        currentIndex = 1
    end

    local jobId = serverJobIds[currentIndex]
    print("Пытаемся телепортироваться на сервер:", jobId)

    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)

    if not success then
        print("Ошибка телепорта:", err)
        if tostring(err):find("GameFull") then
            currentIndex = currentIndex + 1
            wait(10)
            tryTeleport()
        else
            warn("Не удалось телепортироваться: ", err)
            -- Можно попробовать следующий сервер через 5 сек
            currentIndex = currentIndex + 1
            wait(5)
            tryTeleport()
        end
    else
        print("Телепорт отправлен, ожидаем переключения")
    end
end

fetchServers()

while true do
    tryTeleport()
    wait(5)
end
