repeat wait() until game:IsLoaded()

while true do wait(0.1)
    local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("ver") and gui.ver:FindFirstChild("ver") then
        local version = gui.ver.ver.Text
        if version == "v.246" or version == "v.239" then
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local PlaceID = game.PlaceId
            local AllIDs = {}
            local Cursor = nil
            local Hour = os.date("!*t").hour
            local BestServer = nil
            local BestCreated = math.huge

            pcall(function()
                AllIDs = HttpService:JSONDecode(readfile("OldServers.json"))
            end)

            if type(AllIDs) ~= "table" then
                AllIDs = { Hour }
                writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
            elseif AllIDs[1] ~= Hour then
                AllIDs = { Hour }
                writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
            end

            local function FetchServers()
                local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
                if Cursor then url = url .. "&cursor=" .. Cursor end
                local data = HttpService:JSONDecode(game:HttpGet(url))
                Cursor = data.nextPageCursor

                for _, server in pairs(data.data) do
                    if server.playing < server.maxPlayers then
                        local isNew = true
                        for _, id in pairs(AllIDs) do
                            if server.id == id then
                                isNew = false
                                break
                            end
                        end

                        if isNew and server.created < BestCreated then
                            BestCreated = server.created
                            BestServer = server
                        end
                    end
                end
            end

            local maxAttempts = 10
            for i = 1, maxAttempts do
                FetchServers()
                if Cursor == nil then break end
                wait(0.5)
            end

            if BestServer then
                table.insert(AllIDs, BestServer.id)
                writefile("OldServers.json", HttpService:JSONEncode(AllIDs))
                print("Телепорт в сервер:", BestServer.id, "Создан:", BestServer.created)
                TeleportService:TeleportToPlaceInstance(PlaceID, BestServer.id, game.Players.LocalPlayer)
            else
                warn("Подходящий сервер не найден.")
            end
        end
    end
end
