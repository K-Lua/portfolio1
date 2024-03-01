print("[BREACH SYSTEMS] Loaded main menu shared")

concommand.Add("deploy_debug", function(ply, cmd, args)
    if IsValid(ply) then

        ply:SetNWBool("InMenuState", false)
        
        ply:Freeze(false)
        
        ply:SetMoveType(MOVETYPE_WALK)
        ply:DrawShadow(true)

        
        print(ply:Nick() .. " has been deployed via debug command.")
    end
end)