print("[BREACH] Client Data Module Loaded")

playerData = {}

net.Receive("SendPlayerData", function()
    data = net.ReadTable()

    playerData.Money = data.Money
    playerData.Credits = data.Credits
    playerData.Weapons = data.Weapons
    playerData.Operators = data.Operators
    playerData.XP = data.Xp
    playerData.Level = data.Level

    print("[BREACH] Received Player Data:")
    PrintTable(playerData)
end)