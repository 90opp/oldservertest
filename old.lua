local jobIds = {
    "e8234da7-5c53-4008-aa36-5163b28ed96d",
    "f128295e-d0a2-4a41-ab25-6f8ff22e4ce7",
    "55691982-d532-48f6-a183-f8e667fcc64e",
    "2a4c2857-f95a-429d-8971-5906ad341465",
    "c42d2902-252c-4d3e-a78a-a117cf7d85c2",
    "744def34-9106-47ca-a7e7-4cbf260a9ad6",
    "57e7f46b-e9d3-4dc3-be65-fb40c8153e22",
    "023a0682-5dc4-4964-b30d-a722233316b4",
    "e84f9994-409e-4c0e-8e78-8db6ed2b4b81",
    "ec16b73f-331c-409b-a94e-a89ab8af8dfd",
    "93931bbe-bf12-49bf-9521-3e8edc6e041e",
    "6c1493ef-d5e2-4b38-a272-ff35dbe65245",
    "7f2e7d19-e518-4f0d-972d-2be65d506a04",
    "30903540-da51-47d0-961b-38eeea8d1a69",
    "82bd5c47-0bae-4892-89e1-6c7dc3fa4092",
    "5a5f68a3-103a-4b41-bcad-aab887b54ba8",
    "1c0e2436-aa2a-461f-bb9a-b7f090ac52a0",
    "65e66885-2c29-4d48-918c-fd93f568a571",
    "d187f664-c521-442d-ae47-491806da43aa",
    "1d5ac5d2-905f-4d23-a6a4-39c973625a44",
    "f8a1019c-b6c6-425d-aebb-4704c876be4b",
    "66fcd226-1201-4a2c-87ae-959dbc4cd5d8",
    "5931a958-8ccf-4816-a7a9-92a87b0b49aa",
    "896b6bfb-6f3c-416e-8654-04805902a9a7",
    "7a6ec2c6-5bd5-4478-b6ae-d4f5c9b7e657",
    "43db38ae-c551-41cb-8ef4-0d7d13485880",
    "bcc361c5-1346-472b-8e38-2d0e395adbcc",
    "bfab4fb3-4efb-4825-84ad-5b7682261bf3",
    "d2dfb802-b30b-41dd-86b1-e85d5bab9c98",
    "72e2293b-eb93-4ede-9007-b76fa7b8d8e5",
    "0dfe6962-f056-445b-9038-ac2faa384690",
    "fc0cb970-ba85-4936-b5f9-09aff8d74341",
    "2eec06be-b2a0-4541-a129-d08975343f47",
    "4bc4fd6a-0be9-4aac-a42b-2ef7d49bc401",
    "ce344707-8ff2-437c-a8f9-1d850ff03fbb",
    "65859db2-1742-403d-8ad1-342745347b9a",
    "d2d4d4ec-ad7d-4469-be7b-a155f039d20c",
    "2e07ef27-1d33-4a36-a36a-77cbfb7f7c2f",
    "f9112f4e-652b-4acf-b6a4-a6f8dcf0b335",
    "702112db-4cc2-429f-bd0b-220eaf8175d0",
    "3cd56dac-8af4-4db4-845c-5c0180e27f35",
    "6af16cf1-6760-4e3e-8069-635cbeeadee3",
    "eea87841-850e-4543-aca6-68881c18119c",
    "095e78b6-2583-4664-96d2-a12a2c3b6499",
    "4d584a32-ff7e-4bca-b8e0-2bc9687b1c6a",
    "ea807338-9cf3-4cd6-a8c5-d2c53587a282"
}

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local current = 1

local function tryTeleport()
    if current > #jobIds then
        warn("❌ Все JobId перепробованы. Телепорт не удался.")
        return
    end

    local jobId = jobIds[current]
    print("🔁 Пробуем телепорт на:", jobId)

    local success, result = pcall(function()
        return TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
    end)

    if success then
        print("✅ Телепорт инициирован. Ждём переход...")
        -- игрок будет перенаправлен
    else
        warn("⚠️ Ошибка телепорта:", result)
        if tostring(result):find("experience is full") then
            print("⛔ Сервер полный. Пробуем следующий...")
            current += 1
            task.wait(0.5)
            tryTeleport()
        else
            warn("❗ Другая ошибка. Скрипт остановлен.")
        end
    end
end

tryTeleport()
