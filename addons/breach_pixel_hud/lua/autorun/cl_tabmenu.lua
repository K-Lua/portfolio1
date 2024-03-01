if CLIENT then

    local scoreboard
    local playerRows = {}
    local lastPlayerCount = 0
    local updateInterval = 10  

    local function CreatePlayerEntry(parent, ply)
        local entry = vgui.Create("DPanel", parent)
        entry:SetSize(parent:GetWide(), 40)
        entry:SetBackgroundColor(Color(33, 33, 33))
        entry.Player = ply 

        local avatar = vgui.Create("AvatarImage", entry)
        avatar:SetSize(32, 32)
        avatar:SetPos(10, 4)
        avatar:SetPlayer(ply, 32)

        local name = vgui.Create("DLabel", entry)
        name:SetFont("DermaDefault")
        name:SetTextColor(team.GetColor(ply:Team()))
        name:SetText(ply:Nick())
        name:SizeToContents()
        name:SetPos(50, 10)
        entry.NameLabel = name  

        local jobName = vgui.Create("DLabel", entry)
        jobName:SetFont("DermaDefault")
        jobName:SetTextColor(team.GetColor(ply:Team()))
        jobName:SetText(ply:getDarkRPVar("job") or "Unknown")
        jobName:SizeToContents()
        jobName:SetPos(70, 10)
        entry.JobLabel = jobName  

        return entry
    end

local function RefreshScoreboardEntries()
    for _, entry in pairs(playerRows) do
        if IsValid(entry) and IsValid(entry.Player) then
            entry.NameLabel:SetText(entry.Player:Nick())
            entry.NameLabel:SizeToContents()
            entry.JobLabel:SetText(entry.Player:getDarkRPVar("job") or "Unknown")
            entry.JobLabel:SizeToContents()

            local nameWidth = entry.NameLabel:GetWide()
            local jobWidth = entry.JobLabel:GetWide()
            local totalWidth = nameWidth + jobWidth + 20  

            local parentWidth = entry:GetWide()
            local startX = 50  

            if entry.NameLabel and entry.JobLabel then
                if startX + totalWidth > parentWidth - 200 then 
                    entry.JobLabel:SetPos(startX, 30)  
                else
                    entry.JobLabel:SetPos(startX + nameWidth + 20, 10)  
                end
            end
        end
    end
end

    local function UpdateScoreboard()
        if not IsValid(scoreboard) then return end

        local currentPlayerCount = #player.GetAll()
        if lastPlayerCount == currentPlayerCount then return end
        lastPlayerCount = currentPlayerCount

        for _, row in pairs(playerRows) do
            if IsValid(row) then row:Remove() end
        end
        playerRows = {}

        local index = 0
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsPlayer() or ply:IsBot() then
                local entry = CreatePlayerEntry(scoreboard, ply)
                entry:SetPos(0, -50)
                entry:MoveTo(0, index * 45, 0.3, index * 0.1)
                table.insert(playerRows, entry)
                index = index + 1
            end
        end

        scoreboard:SetTall(index * 45)
    end

    hook.Add("ScoreboardShow", "openbreachscoreboard", function()
        if not IsValid(scoreboard) then
            scoreboard = vgui.Create("DPanel")
            scoreboard:SetSize(700, ScrH() * 0.8)
            scoreboard:Center()
            scoreboard:SetBackgroundColor(Color(0, 0, 0, 0))

            UpdateScoreboard()
        end

        scoreboard:Show()
        gui.EnableScreenClicker(true)

        timer.Create("breachScoreboardRefreshTimer", updateInterval, 0, RefreshScoreboardEntries)
        return false
    end)

    hook.Add("ScoreboardHide", "closebreachscoreboard", function()
        if IsValid(scoreboard) then
            scoreboard:Hide()
            gui.EnableScreenClicker(false)
        end
        timer.Remove("breachScoreboardRefreshTimer")
    end)

    hook.Add("Think", "UpdateScoreboardThink", function()
        UpdateScoreboard()
        RefreshScoreboardEntries()
    end)

end