util.AddNetworkString("OpenCharacterMenu")

hook.Add("PlayerInitialSpawn", "menutpspawnhoo", function(ply)
local teleportPosition = Vector(-2594.509277, 669.474854, -19257.033203)
if IsValid(ply) then
            ply:SetPos(teleportPosition)

            net.Start("OpenCharacterMenu")
            net.Send(ply)
        end
end)