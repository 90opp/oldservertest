local jobIds = {
    -- сюда твои jobId
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local PlaceId = game.PlaceId

local current = 1

local function tryTeleport()
    if current > #jobIds then
        warn("❌ Все сервера перепробованы.")
        return
    end

    local jobId = jobIds[current]
    print("🔁 Пробуем телепорт на:", jobId)

    local success, result = pcall(function()
        return TeleportService:TeleportToPlaceInstance(PlaceId, jobId, Players.LocalPlayer)
    end)

    if success then
        print("✅ Телепорт отправлен.")
    else
        warn("⚠️ Не удалось телепортироваться:", result)
        current += 1
        -- обязательно task.delay, не перезаписывай task
        task.delay(1.5, tryTeleport)
    end
end

tryTeleport()
