local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local placeId = 126884695634066
local jobIds = {}

local url = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"

local function fetchJobIds()
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        local lines = {}
        for line in response:gmatch("[^\r\n]+") do
            line = line:match("^%s*(.-)%s*$") -- убираем пробелы по краям
            if #line > 0 then
                table.insert(lines, line)
            end
        end
        return lines
    else
        warn("Ошибка загрузки jobId: " .. tostring(response))
        return nil
    end
end

local teleporting = false

TeleportService.TeleportInitFailed:Connect(function(player, result)
    warn("TeleportInitFailed: " .. tostring(result))
    teleporting = false
end)

local function tryTeleport(jobId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    if not success then
        warn("Ошибка при попытке телепорта: " .. tostring(err))
        return false
    end
    return true
end

task.spawn(function()
    jobIds = fetchJobIds()
    if not jobIds or #jobIds == 0 then
        warn("Список jobId пуст или не загружен.")
        return
    end

    while true do
        if not teleporting then
            teleporting = true

            for i, jobId in ipairs(jobIds) do
                print("Пытаемся телепортироваться на сервер:", jobId)
                local success = tryTeleport(jobId)
                if success then
                    print("Телепорт инициализирован, ждем переход...")
                    break
                else
                    print("Неудачный телепорт, ждем 10 сек и пробуем следующий сервер.")
                    task.wait(10)
                end
            end

            teleporting = false
        end
        task.wait(5)
    end
end)
