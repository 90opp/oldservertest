local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local jobIdToCheck = "27a4c470-5756-4d09-a8e7-31fd87f183fd" -- твой jobId
local placeId = game.PlaceId

local teleportSucceeded = false
local teleportTimedOut = false

local function checkServerAvailability(jobId)
    teleportSucceeded = false
    teleportTimedOut = false

    -- Подписываемся на событие ухода игрока (телеорта)
    local conn
    conn = Players.PlayerRemoving:Connect(function(plr)
        if plr == player then
            teleportSucceeded = true
            conn:Disconnect()
        end
    end)

    -- Запускаем телепорт
    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)

    -- Ждём до 5 секунд, чтобы понять, ушёл ли игрок
    local timer = 0
    local timeout = 5
    while timer < timeout do
        if teleportSucceeded then
            print("Телепорт на сервер "..jobId.." успешен. Сервер активен.")
            return true
        end
        wait(0.5)
        timer = timer + 0.5
    end

    -- Если через 5 секунд игрок не ушёл — телепорт скорее всего не удался
    print("Телепорт на сервер "..jobId.." не удался (возможно сервер неактивен или полный).")
    return false
end

checkServerAvailability(jobIdToCheck)
