activeNotifs = activeNotifs or {} -- to keep track of notifications.

local function updateNotifPositions()
    local baseY = ScrH() * 0.7
    local spacing = 5  -- This is so I can add a setting for the player to customise later on.

    for i, notifPanel in ipairs(activeNotifs) do
        local targetY = baseY - ((notifPanel:GetTall() + spacing) * i)
        notifPanel:MoveTo(notifPanel:GetX(), targetY, 0.2, 0, -1)
    end
end

function scpbasenotif(duration, chipcolor, content) -- duration( in seconds), (chip color is the small square at the right), content (for example the content would be hello then the notify would say hello)
    local screenWidth, screenHeight = ScrW(), ScrH()
    local notifWidth, notifHeight = 300, 50
    local notifX, notifY = screenWidth, screenHeight * 0.7

    local notifPanel = vgui.Create("DPanel")
    notifPanel:SetSize(notifWidth, notifHeight)
    notifPanel:SetPos(screenWidth, notifY)
    notifPanel:SetDrawOnTop(true)
    notifPanel.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(25, 25, 25, 255)) 
        draw.RoundedBox(0, w - 10, 0, 10, h, chipcolor) 
    end

    table.insert(activeNotifs, notifPanel)
    updateNotifPositions()

    local label = vgui.Create("DLabel", notifPanel)
    label:SetFont("DermaDefaultBold")
    label:SetText(content)
    label:SizeToContents()
    label:SetPos(10, (notifHeight - label:GetTall()) / 2)

    notifPanel:MoveTo(screenWidth - notifWidth - 10, notifY, 0.3, 0, -1)

    local function removeNotif()
        notifPanel:MoveTo(screenWidth, notifPanel:GetY(), 0.3, 0, -1, function()
            if IsValid(notifPanel) then
                notifPanel:Remove()
                table.RemoveByValue(activeNotifs, notifPanel)
                updateNotifPositions()
            end
        end)
    end

    timer.Simple(duration, removeNotif)
end

concommand.Add("test_notif", function(ply, cmd, args)
    local duration = tonumber(args[1]) or 5
    local r = tonumber(args[2]) or 255
    local g = tonumber(args[3]) or 0
    local b = tonumber(args[4]) or 0
    local content = args[5] or "Test notification"

    scpbasenotif(duration, Color(r, g, b), content)
end)

net.Receive("ExceedLimitNotification", function()
    scpbasenotif(3, Color(139, 0, 0), "Name or description exceeds length limit.")
end)

net.Receive("InvalidFactionNotification", function()
    scpbasenotif(3, Color(139, 0, 0), "Invalid Faction.")
end)

net.Receive("MaxiumCharacterNotif", function()
    scpbasenotif(3, Color(139, 0, 0), "Maxium Number of characters reached.")
end)

net.Receive("CharAlreadyInFaction", function()
    scpbasenotif(3, Color(139, 0, 0), "You already have a character in this faction.")
end)

net.Receive("CharCreated", function()
    scpbasenotif(3, Color(0, 200, 0), "Character created!")
end)

local lasttimenocliped = 0 
local cooldown = 3.1 

hook.Add("PlayerNoClip", "Noclipnotif", function(ply)
    if CurTime() - lasttimenocliped >= cooldown then
        lasttimenocliped = CurTime()
        scpbasenotif(3, Color(0, 200, 200), "Toggled Noclip")
    end
end)