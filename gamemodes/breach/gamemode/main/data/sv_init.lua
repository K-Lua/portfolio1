print("[BREACH] SV Data Module Loaded")

util.AddNetworkString("SendPlayerData")

local function InitializeDatabase()
    if not sql.TableExists("player_data") then
        local query = [[
            CREATE TABLE player_data (
                ID INTEGER PRIMARY KEY AUTOINCREMENT,
                SteamID TEXT UNIQUE,
                Money INTEGER DEFAULT 100,
                Credits INTEGER DEFAULT 0,
                Weapons TEXT DEFAULT '{}',
                Operators TEXT DEFAULT '{}',
                Xp INTEGER DEFAULT 0,
                Level INTEGER DEFAULT 1
            );
        ]]
        sql.Query(query)
        
        if sql.LastError() then
            error("Failed to create player_data table: " .. sql.LastError())
        else
            print("Successfully created player_data table.")
        end
    end
end

InitializeDatabase()

hook.Add("PlayerInitialSpawn", "CheckPlayerDatabaseEntry", function(ply)
    local steamID = ply:SteamID()
    
    local existsQuery = sql.QueryValue("SELECT SteamID FROM player_data WHERE SteamID = " .. sql.SQLStr(steamID))
    
    if not existsQuery then
        local insertQuery = [[
            INSERT INTO player_data (SteamID, Money, Credits, Weapons, Operators, Xp, Level)
            VALUES (]] .. sql.SQLStr(steamID) .. [[, 100, 0, '{}', '{}', 0, 1);
        ]]
        sql.Query(insertQuery)
        
        if sql.LastError() then
            error("[BREACH] Failed to insert new player data for " .. steamID .. ": " .. sql.LastError())
        else
            print("[BREACH] New player data inserted for " .. steamID)
        end
    end
end)

local function GetPlayerData(steamID)
    local safeSteamID = sql.SQLStr(steamID)
    local query = "SELECT * FROM player_data WHERE SteamID = " .. safeSteamID

    local result = sql.QueryRow(query)
    if result then
        result.Weapons = util.JSONToTable(result.Weapons or "{}")
        result.Operators = util.JSONToTable(result.Operators or "{}")
        return result
    else
        if sql.LastError() then
            print("Error fetching player data for " .. steamID .. ": " .. sql.LastError())
        end
        return nil
    end
end

hook.Add("PlayerInitialSpawn", "SendPlayerDataToClient", function(ply)
    local steamID = ply:SteamID()
    local data = GetPlayerData(steamID)

    if not data then
        print("[BREACH] No data found for player, creating new entry...") 

        data = GetPlayerData(steamID)
    end

    if data then
        net.Start("SendPlayerData")
            net.WriteTable(data)
        net.Send(ply)
    else
        print("[BREACH] Failed to retrieve or create player data for " .. steamID)
    end
end)