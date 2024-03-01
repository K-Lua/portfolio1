DeriveGamemode("base") -- yea, im original,

--- INCLUDES
include("main/mainmenu/sv_init.lua")
include("main/mainmenu/shared.lua")
include("main/data/sv_init.lua")
include("main/data/cl_init.lua")

--- ADD CS LUA
AddCSLuaFile("main/mainmenu/cl_init.lua")
AddCSLuaFile("main/mainmenu/shared.lua")
AddCSLuaFile("main/data/cl_init.lua")

function GM:Initialize()
    print("SCP: Project Breach initializing...")
end

function GM:PlayerInitialSpawn(ply)
    print("[BREACH] " .. ply:Nick() .. " has spawned . . . ")
    
    ply:SetSolid(SOLID_NONE)
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:Freeze(true)
    
--    ply:SetMuted(true)

    ply:SetNWBool("InMenuState", true) -- keep track of players in the menu state, 
end


concommand.Add("breach_cmd", function(ply, cmd, args)
    print("works")
end)