repeat wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceID = game.PlaceId

-- Проверка GUI версии
while true do
    wait(0.1)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("ver") and gui.ver:FindFirstChild("ver") then
        local version = gui.ver.ver.Text
        if version == "v.246" or version == "v.239" then
            break
        end
    end
end

-- Загружаем ID уже посещённых серверов
local AllIDs = {}
local Hour = os.date("!*t").hour
pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("OldServers.json"))
end)

if type(AllIDs) ~= "table" or AllIDs[1] ~= Hour then
    AllIDs = { Hour }
    writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
end

-- Безопасный телепорт с проверкой на переполненность
local function safeTeleport(placeId, jobId)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)

    if not success then
        warn("Teleport failed:", err)
        if string.find(err, "teleportgamefull") then
            return false
        end
    end

    return true
end

-- Поиск подходящего сервера
local function findOldestServer()
    local Cursor = nil
    local BestServer = nil
    local BestCreated = math.huge
    local MaxPages = 10

    for page = 1, MaxPages do
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
        if Cursor then url = url .. "&cursor=" .. Cursor end

        local data = HttpService:JSONDecode(game:HttpGet(url))
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
    local server = findOldestServer()
    if server then
        print("Попытка телепорта в сервер:", server.id, "Создан:", server.created)
        table.insert(AllIDs, server.id)
        writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
        local ok = safeTeleport(PlaceID, server.id)
        if ok then break end
    else
        warn("Подходящих серверов не найдено. Повтор через 5 сек...")
        wait(5)
    end
end
