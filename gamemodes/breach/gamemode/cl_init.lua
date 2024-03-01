-- INCLUDES
include("main/mainmenu/cl_init.lua")
include("main/data/cl_init.lua")

hook.Add("PrePlayerDraw", "MenuStatehide", function(ply)
    if LocalPlayer():GetNWBool("InMenuState", false) then
        if ply != LocalPlayer() then
            ply:DrawShadow(false)
            return true 
        end
    end
end)

hook.Add("HUDShouldDraw", "hidegmoddefaulthud", function(name)
    if name == "CHudHealth" or name == "CHudAmmo" then
        return false 
    end
end)

local backgrounds = {
--    "materials/loading_background/facility_scp_914.jpg",
    "materials/loading_background/scp_hall_three.png",    
--   "materials/loading_background/facility_work_area.jpeg",
}

local logoMaterial = Material("materials/logo/projectbreach_logo_no_background.png")

local function drawBlackSquare()
    local screenWidth, screenHeight = ScrW(), ScrH()
    local squareWidth = 600
    local squareHeight = screenHeight
    local squareX = (screenWidth / 2) - (squareWidth / 2)
    local squareY = 0
    draw.RoundedBox(0, squareX, squareY, squareWidth, squareHeight, Color(0, 0, 0, 178)) 
end

local backgroundMaterial = Material(table.Random(backgrounds), "noclamp smooth") -- random background

hook.Add("HUDPaint", "Startingmenu", function()
    local screenWidth, screenHeight = ScrW(), ScrH()
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(backgroundMaterial)
    surface.DrawTexturedRect(0, 0, screenWidth, screenHeight)
    
    drawBlackSquare()
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(logoMaterial)
    local logoW, logoH = 200, 200 
    surface.DrawTexturedRect((screenWidth / 2) - (logoW / 2), (screenHeight / 2) - logoH - 150, logoW, logoH)
    
    draw.SimpleText("Project", "Countach Bold", screenWidth / 2, screenHeight / 2 - 140, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText("BREACH", "Countach Bold", screenWidth / 2, (screenHeight / 2) -70, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText("Press any button to start", "Countach Bold", screenWidth / 2, (screenHeight / 2) + 240, Color(255, 255, 255), TEXT_ALIGN_CENTER)
end)

triggerinput = false


hook.Add("PlayerButtonDown", "startingmenuinput", function(ply, button)
    if not triggerinput then
        if button >= MOUSE_FIRST and button <= MOUSE_LAST then 
            triggerinput = true
            hook.Remove("HUDPaint", "Startingmenu")
            hook.Remove("PlayerButtonDown", "startingmenuinput")
            gui.EnableScreenClicker(true)
           -- net.Start("Requestmainmenu")
           -- net.SendToServer()
        elseif button >= KEY_FIRST and button <= KEY_LAST then 
            triggerinput = true
            hook.Remove("HUDPaint", "Startingmenu")
            hook.Remove("PlayerButtonDown", "startingmenuinput")
            gui.EnableScreenClicker(true)
            --net.Start("Requestmainmenu")
            --net.SendToServer() 
        end
    end
end)