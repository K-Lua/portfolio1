util.AddNetworkString("TransitionToMainMenu")
util.AddNetworkString("Requestmainmenu")
util.AddNetworkString("SendNotificationToPlayer")

print("[BREACH INTERNALS] Main Menu Loaded")

local mapSettings = {
    ["gm_flatgrass"] = { -- map id
        pos = {
            Vector(-177.532700, 855.917847, -12735.968750), -- position of the player in main menu
        },    
        angles = {
            Angle(0.462169, 84.151009, 0.000000), -- angle / of the player
        },
        origin = {
            Vector(-125.693024, 968.939392, -12714.952148), -- Third-person camera position
        },
        viewAngles = {
            Angle(13.825750, -110.981934, 0.000000), -- cameras view angles
        },
        fov = 80,
    },
    ["gm_far"] = { 
        pos = {
            Vector(2307.175293, 875.466858, 28.031250),
            Vector(2512.895020, 930.125427, 64.031250), 
        },
        angles = {
            Angle(-2.310000, 83.713249, -0.000000),
            Angle(1.847930, 178.986115, 0.000000), 
        },
        origin = {
            Vector(2370.076172, 1014.577759, 64.036629),
            Vector(2516.908203, 802.827026, 97.408371), 
        },
        viewAngles = {
            Angle(3.291812, -106.403877, -0.000000),
            Angle(14.561497, 110.343773, 0.000000), 
        },
        fov = 80, 
    },

}

local function SetupPlayerForMainMenu(ply)
    local currentMap = game.GetMap()
    local settings = mapSettings[currentMap]

    if settings then
        ply:SetPos(settings.pos[1]) 
        ply:SetEyeAngles(settings.angles[1]) 

        ply:SetModel("models/ninja/mw3/delta/delta4_masked.mdl")
        ply:Give("mg_fnovember2000") 
        ply:SetAmmo(0, "Pistol")
        ply:Freeze(true)
        
        print("[BREACH] Sending TransitionToMainMenu to " .. ply:Nick())
        PrintTable(settings)

        net.Start("TransitionToMainMenu")
        net.WriteVector(settings.origin[1]) 
        net.WriteAngle(settings.angles[1]) 
        net.WriteFloat(settings.fov)
        net.WriteVector(settings.pos[1])
        net.WriteAngle(settings.viewAngles[1]) 
        net.Send(ply)
    else
        print("[BREACH] No settings found for map: " .. currentMap)
    end
end

net.Receive("Requestmainmenu", function(len, ply)
   SetupPlayerForMainMenu(ply)
end)

hook.Add("PlayerInitialSpawn", "SetupMainMenu", function(ply)
    timer.Simple( 0.1, function()
        SetupPlayerForMainMenu(ply)
    end)
end)

concommand.Add("send_notif", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local title = args[1] or "Notification"
    local line1 = args[2] or ""
    local line2 = args[3] or ""
    local line3 = args[4] or ""
    local line4 = args[5] or ""
    local line5 = args[6] or ""

    net.Start("SendNotificationToPlayer")
    net.WriteString(title)
    net.WriteString(line1)
    net.WriteString(line2)
    net.WriteString(line3)
    net.WriteString(line4)
    net.WriteString(line5)
    net.Send(ply)
end)

function sendNotificationToPlayer(ply, title, line1, line2, line3, line4, line5)
    net.Start("SendNotificationToPlayer")
    net.WriteString(title)
    net.WriteString(line1 or "")
    net.WriteString(line2 or "")
    net.WriteString(line3 or "")
    net.WriteString(line4 or "")
    net.WriteString(line5 or "")
    net.Send(ply)
end