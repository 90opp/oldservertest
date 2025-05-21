local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local placeId = 126884695634066
local url = "https://raw.githubusercontent.com/90opp/oldservertest/refs/heads/main/servers.txt"

-- Функция для загрузки списка jobId из URL
local function loadJobIds()
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        warn("Не удалось загрузить jobId: ".. tostring(response))
        return {}
    end

    local jobIds = {}
    -- предполагаем, что в response просто список jobId, по одному на строку или с переносами
    for line in response:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- убираем пробелы по краям
        if line ~= "" then
            table.insert(jobIds, line)
        end
    end
    return jobIds
end

local jobIds = loadJobIds()
if #jobIds == 0 then
    warn("Список серверов пуст, выходим")
    return
end

local function tryTeleport(jobId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    if success then
        print("Телепорт к серверу:", jobId)
        return true
    else
        warn("Ошибка телепорта:", err)
        return false
    end
end

-- Основной цикл перебора серверов с ожиданием при неудаче
while true do
    for _, jobId in ipairs(jobIds) do
        local teleported = tryTeleport(jobId)
        if teleported then
            -- Телепорт начался — ждем выход из скрипта
            return
        else
            print("Сервер " .. jobId .. " недоступен или полный. Ждем 10 сек и пробуем следующий...")
            wait(10)
        end
    end
end
