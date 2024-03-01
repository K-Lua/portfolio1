if SERVER then
    local function initializeDatabase()
        local query = [[
            CREATE TABLE IF NOT EXISTS character_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                steamID TEXT NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                faction TEXT
            );
        ]]
        if not sql.TableExists("character_data") then
            sql.Query(query)
        end
    end

    initializeDatabase()

    util.AddNetworkString("CharacterCreationData")
    util.AddNetworkString("RequestCharacterData")
    util.AddNetworkString("SendCharacterData")

    local function SendCharacterData(ply)
        if not IsValid(ply) then return end

        local steamID = ply:SteamID()
        local query = string.format("SELECT * FROM character_data WHERE steamID = %s", sql.SQLStr(steamID))
        local result = sql.Query(query)

        net.Start("SendCharacterData")
            net.WriteTable(result or {})
        net.Send(ply)
    end
    
    util.AddNetworkString("ExceedLimitNotification")
    util.AddNetworkString("InvalidFactionNotification")
    util.AddNetworkString("MaxiumCharacterNotif")
    util.AddNetworkString("CharAlreadyInFaction")
    util.AddNetworkString("CharCreated")
    net.Receive("CharacterCreationData", function(len, ply)
        local name = net.ReadString()
        local description = net.ReadString()
        local faction = net.ReadString()

        if #name > 16 or #description > 128 then
                    net.Start("ExceedLimitNotification")
                    net.Send(ply)
            return
        end

        local validFactions = {["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true}
        if not validFactions[faction] then
                    net.Start("InvalidFactionNotification")
                    net.Send(ply)
            return
        end

        local steamID = ply:SteamID()
        local countQuery = string.format("SELECT COUNT(*) as count FROM character_data WHERE steamID = %s", sql.SQLStr(steamID))
        local countResult = sql.QueryRow(countQuery)
        if countResult and tonumber(countResult.count) >= 4 then
                    net.Start("MaxiumCharacterNotif")
                    net.Send(ply)
            return
        end

        local factionCheckQuery = string.format("SELECT id FROM character_data WHERE steamID = %s AND faction = %s", sql.SQLStr(steamID), sql.SQLStr(faction))
        local factionCheckResult = sql.QueryRow(factionCheckQuery)
        if factionCheckResult then
                    net.Start("CharAlreadyInFaction")
                    net.Send(ply)
            return
        end

        local query = string.format("INSERT INTO character_data (steamID, name, description, faction) VALUES (%s, %s, %s, %s)",
                                    sql.SQLStr(steamID), sql.SQLStr(name), sql.SQLStr(description), sql.SQLStr(faction))

        local result = sql.Query(query)
        if result == false then
            print("An error occurred while inserting data into the database.")
            print(sql.LastError())
        else
            net.Start("CharCreated")
            net.Send(ply)
            SendCharacterData(ply)
        end
    end)

    hook.Add("PlayerInitialSpawn", "SendInitialCharacterData", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                SendCharacterData(ply)
            end
        end)
    end)

util.AddNetworkString("RequestLoadCharacter")
util.AddNetworkString("CharacterLoaded")

local playerRequests = {}

local function CanProcessRequest(ply)
    if not IsValid(ply) then return false end
    local steamID = ply:SteamID()
    playerRequests[steamID] = playerRequests[steamID] or {}

    local currentTime = CurTime()
    table.insert(playerRequests[steamID], currentTime)

    local oneMinuteAgo = currentTime - 2
    while playerRequests[steamID][1] and playerRequests[steamID][1] < oneMinuteAgo do
        table.remove(playerRequests[steamID], 1)
    end

    return #playerRequests[steamID] <= 5
end

net.Receive("RequestCharacterData", function(len, ply)
    if not CanProcessRequest(ply) then
        print("[CHARACTER] Rate limited: " .. ply:Nick())
        return
    end

    local steamID = ply:SteamID()
    local query = string.format("SELECT name, description, faction FROM character_data WHERE steamID = %s", sql.SQLStr(steamID))
    local result = sql.Query(query)

    if result then
        net.Start("SendCharacterData")
        net.WriteTable(result)
        net.Send(ply)
    else
        print("No character data found for player or error occurred: " .. (sql.LastError() or "No error"))
    end
end)

net.Receive("RequestLoadCharacter", function(len, ply)
    if not CanProcessRequest(ply) then
        print("[CHARACTER] Rate limited: " .. ply:Nick())
        return
    end

    local slotIndex = net.ReadInt(32)
    local steamID = ply:SteamID()

    local query = string.format("SELECT * FROM character_data WHERE steamID = %s", sql.SQLStr(steamID))
    local characters = sql.Query(query)

    if not characters or #characters < slotIndex then
        ply:ChatPrint("Invalid character slot selected.")
        return
    end

    table.sort(characters, function(a, b) return tonumber(a.id) < tonumber(b.id) end)
    local selectedCharacter = characters[slotIndex]

    if selectedCharacter then
        net.Start("CharacterLoaded")
        net.WriteString(selectedCharacter.name)
        net.Send(ply)
        ply:Spawn()
    else
        print("[CHARACTER] Error Loading Character For: " .. ply:Nick())
    end
end)

util.AddNetworkString("RenameCharacter")
util.AddNetworkString("DeleteCharacter")

net.Receive("RenameCharacter", function(len, ply)
    local charID = net.ReadInt(32)
    local newName = net.ReadString()

    if #newName > 16 then
        ply:ChatPrint("Name too long.")
        return
    end

    local steamID = ply:SteamID()
    local query = string.format("UPDATE character_data SET name = %s WHERE id = %d AND steamID = %s",
                                sql.SQLStr(newName), charID, sql.SQLStr(steamID))
    local result = sql.Query(query)
    if result == false then
        print("An error occurred while renaming character: " .. sql.LastError())
    else
        ply:ChatPrint("Character renamed")
    end
end)

net.Receive("DeleteCharacter", function(len, ply)
    local charID = net.ReadInt(32)


    local steamID = ply:SteamID()
    local query = string.format("DELETE FROM character_data WHERE id = %d AND steamID = %s",
                                charID, sql.SQLStr(steamID))
    local result = sql.Query(query)
    if result == false then
        print("An error occurred while deleting character: " .. sql.LastError())
    else
        ply:ChatPrint("Character deleted")
    end
end)


end