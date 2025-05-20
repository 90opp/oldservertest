repeat wait() until game:IsLoaded()
print("[ЛОГ] Игра загружена")

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId

-- Ожидание GUI и версии
print("[ЛОГ] Проверка наличия GUI...")
while true do
    wait(0.5)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("ver") and gui.ver:FindFirstChild("ver") then
        local version = gui.ver.ver.Text
        print("[ЛОГ] Найдена версия GUI: " .. version)
        if version == "v.246" or version == "v.239" then
            print("[ЛОГ] Версия подходит. Продолжаем...")
            break
        else
            warn("[ЛОГ] Неподходящая версия GUI: " .. version)
        end
    end
end

-- Загрузка ID посещённых серверов
print("[ЛОГ] Загрузка OldServers.json...")
local AllIDs = {}
local Hour = os.date("!*t").hour
local fileLoaded = pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("OldServers.json"))
end)

if not fileLoaded then
    warn("[ЛОГ] Файл не найден. Создаём новый...")
end

if type(AllIDs) ~= "table" or AllIDs[1] ~= Hour then
    print("[ЛОГ] Сброс ID, новый час")
    AllIDs = { Hour }
    writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
else
    print("[ЛОГ] Загружено ID: " .. tostring(#AllIDs - 1))
end

-- Безопасный телепорт
local function safeTeleport(placeId, jobId)
    print("[ЛОГ] Попытка телепорта в сервер:", jobId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)

    if not success then
        warn("[ОШИБКА] Teleport failed:", err)
        if string.find(err, "teleportgamefull") then
            warn("[ЛОГ] Сервер фулл, ищем другой...")
            return false
        end
    end

    print("[ЛОГ] Успешный телепорт!")
    return true
end

-- Поиск подходящего сервера
local function findOldestServer()
    print("[ЛОГ] Начат поиск серверов...")
    local Cursor = nil
    local BestServer = nil
    local BestCreated = math.huge
    local MaxPages = 10

    for page = 1, MaxPages do
        print("[ЛОГ] Чтение страницы:", page)
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor then url = url .. "&cursor=" .. Cursor end

        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if not success then
            warn("[ОШИБКА] Не удалось загрузить серверы:", data)
            break
        end

        Cursor = data.nextPageCursor

        for _, server in pairs(data.data) do
            local isNew = true
            for _, id in pairs(AllIDs) do
                if server.id == id then
                    isNew = false
                    break
                end
            end

            if isNew and server.playing < server.maxPlayers and server.created < BestCreated then
                BestCreated = server.created
                BestServer = server
            end
        end

        if not Cursor then break end
        wait(0.3)
    end

    return BestServer
end

-- Цикл до успешного телепорта
while true do
    print("[ЛОГ] Поиск старого сервера...")
    local server = findOldestServer()
    if server then
        print("[ЛОГ] Найден сервер: " .. server.id .. " | Игроков: " .. server.playing .. "/" .. server.maxPlayers)
        table.insert(AllIDs, server.id)
        writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
        local ok = safeTeleport(PlaceID, server.id)
        if ok then
            print("[ЛОГ] Телепорт прошёл успешно. Завершение скрипта.")
            break
        else
            print("[ЛОГ] Повторный поиск через 3 секунды...")
            wait(3)
        end
    else
        warn("[ЛОГ] Подходящий сервер не найден. Повтор через 5 сек...")
        wait(5)
    end
end
