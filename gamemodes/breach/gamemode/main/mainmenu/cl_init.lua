print("[BREACH EXTERNALS] Loaded main menu client")
include("main/mainmenu/shared.lua")
settings = settings or {}


concommand.Add("unlockmouse_Debug", function(ply, cmd, args)
    if IsValid(ply) then

        gui.EnableScreenClicker(false)

        hook.Add("ShouldDrawLocalPlayer", "showlocalplayer", function()
        if ply:GetNWBool("InMenuState") then
        return false
        end
    end)
    end
end)

net.Receive("TransitionToMainMenu", function()
    print("[BREACH] Menu State: Main - Just the Receive,")

    local settings = {}
    settings.origin = net.ReadVector()
    settings.angles = net.ReadAngle()
    settings.fov = net.ReadFloat()
    settings.pos = net.ReadVector()
    settings.viewAngles = net.ReadAngle()
    
    print("[BREACH] Menu State: Main - Settings received:")
    PrintTable(settings)
    
    hook.Add("ShouldDrawLocalPlayer", "showlocalplayer", function()
        return true
    end)

    hook.Add("CalcView", "OverrideViewForMainMenu", function(ply, pos, angles, fov)
        if ply:GetNWBool("InMenuState") then
            local view = {}
            view.origin = settings.origin
            view.angles = settings.viewAngles
            view.fov = settings.fov

            return view
        end
    end)
end)


hook.Add("HUDPaint", "drawplayernameinmainmenu", function()
    local ply = LocalPlayer()
    if ply:GetNWBool("InMenuState") then
    if notificationData and notificationData.show then return end
    if not ply:Alive() then return end 

    local pos = ply:GetPos() + Vector(0, 0, 60)
    local screenPos = pos:ToScreen()

    local text = ply:GetName() 
    local font = "Countach Light Italic" 
    surface.SetFont(font) 

    local textWidth, textHeight = surface.GetTextSize(text)

    local x = screenPos.x - textWidth / 2
    local y = screenPos.y - textHeight / 2

    local textColor = Color(255, 255, 0, 150)  
    local outlineColor = Color(0, 0, 0, 100)

    if screenPos.visible then
        draw.SimpleTextOutlined(text, font, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outlineColor)
    end
    end
end)

local currentTab = "Deploy" 


local tabs = {
    {name = "Deploy", action = function() print("Deploy") end, gradientXOffset = -22, gradientWidthOffset = 20},
    {name = "Weapons", action = function() print("Weapons") end, gradientXOffset = -10, gradientWidthOffset = 25},
    {name = "Loadout", action = function() print("Battle Pass") end, gradientXOffset = -16, gradientWidthOffset = 30},
    {name = "Operators", action = function() print("Operators") end, gradientXOffset = -8, gradientWidthOffset = 30},
    {name = "Challenges", action = function() print("Challenges") end, gradientXOffset = -6, gradientWidthOffset = 40},
    {name = "Store", action = function() print("Store") end, gradientXOffset = -20, gradientWidthOffset = 4},
}


local function drawVerticalGradient(x, y, w, h, color1, color2)
    for i = 0, h do
        local progress = i / h
        local r = Lerp(progress, color1.r, color2.r)
        local g = Lerp(progress, color1.g, color2.g)
        local b = Lerp(progress, color1.b, color2.b)
        local a = Lerp(progress, color1.a, color2.a)
        
        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x, y + i, w, 1)
    end
end

local function drawHorizontalGradient(x, y, w, h, color1, color2)
    for i = 0, w do
        local progress = i / w
        local fadeProgress = progress^0.4 

        local r = Lerp(fadeProgress, color1.r, color2.r)
        local g = Lerp(fadeProgress, color1.g, color2.g)
        local b = Lerp(fadeProgress, color1.b, color2.b)
        local a = Lerp(fadeProgress, color1.a, color2.a)

        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x + i, y, 1, h)
    end
end



local function selectTab(tabName)
    currentTab = tabName
    for _, tab in ipairs(tabs) do
        if tab.name == tabName then
            tab.action()
            break
        end
    end
end

hook.Add("HUDPaint", "drawmainmenuuielement", function()
    local ply = LocalPlayer()
    if ply:GetNWBool("InMenuState") then

        local bgMaterial = Material("uielements/main_menu_pattern_one.png") 
        surface.SetDrawColor(255, 255, 255, 250)
        surface.SetMaterial(bgMaterial)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        

        local logoMaterial = Material("logo/projectbreach_logo_no_background.png") 
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(logoMaterial)
        surface.DrawTexturedRect(10, 0, 90, 90) 
        
        drawmainmenuinfo()
        
        local mouseX, mouseY = gui.MousePos()
        local startX = 240
        local startY = 20
        local tabWidth = 100
        local tabHeight = 30
        local spacing = 240 
        local tabClicked = false
        
        for i, tab in ipairs(tabs) do
            local x = startX + (i-1) * (spacing)
            local y = startY
            local isCurrentTab = (tab.name == currentTab)
            
            
            local mouseOver = mouseX >= x and mouseX <= x + tabWidth and mouseY >= y and mouseY <= y + tabHeight

            local font = isCurrentTab and "Countach Regular biggerxsel" or "Countach Regular biggerx"
            local textColor = isCurrentTab and Color(255, 165, 0, 255) or Color(200, 200, 200, 255)
            
            draw.SimpleText(tab.name, font, x, y, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if isCurrentTab then
               local colorTop = Color(255, 165, 0, 0)
               local colorBottom = Color(255, 165, 0, 25)
               drawVerticalGradient(
               x + tab.gradientXOffset, 
               y - 5, 
               tabWidth + tab.gradientWidthOffset, 
               50, 
               colorTop, 
               colorBottom
            )
            end

            if mouseOver and input.IsMouseDown(MOUSE_LEFT) and not tabClicked then
                selectTab(tab.name)
                tabClicked = true
            end
        end
    end
end)

function drawmainmenuinfo()
    local ply = LocalPlayer()
    if not ply or table.IsEmpty(playerData) then return end
    local credits = playerData.Credits or "Ukn" 
    local name = ply:Nick() 
    local money = playerData.Money or "Ukn" 
    local level = playerData.Level or "Ukn"

    local textFont = "Countach Regular" 
    surface.SetFont(textFont)

    local textCreditsSize = surface.GetTextSize(credits)
    local textNameSize = surface.GetTextSize(name)
    local textMoneySize = surface.GetTextSize(money)
    local textLevelSize = surface.GetTextSize(level)

    local avatarSize = 64
    local spacing = 10 
    local totalWidth = textCreditsSize + textNameSize + textMoneySize + textLevelSize + avatarSize + spacing * 4 

    local startX = ScrW() - totalWidth + 50
    local startY = 10

    draw.SimpleText(credits, textFont, startX, startY, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    draw.SimpleText(name, textFont, startX + textCreditsSize + spacing, startY, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    draw.SimpleText(money, textFont, startX, startY + 33, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    draw.SimpleText(level, textFont, startX + textMoneySize + spacing, startY + 33, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        
    local avatarX, avatarY = ScrW() - 74, 10
    local localPlayerID = LocalPlayer():SteamID64()
    
    if triggerinput then
        
    if not triggerinput then
        playerAvatar:Remove()
    end

    if not IsValid(playerAvatar) or currentAvatarPlayerID ~= localPlayerID then
        if IsValid(playerAvatar) then
            playerAvatar:Remove()
        end
        
        playerAvatar = vgui.Create("AvatarImage")
        playerAvatar:SetSize(avatarSize, avatarSize)
        playerAvatar:SetPos(avatarX, avatarY)
        playerAvatar:SetPlayer(LocalPlayer(), 64)
        currentAvatarPlayerID = localPlayerID
    else
        playerAvatar:SetPos(avatarX, avatarY) 
    end
end

end

hook.Add("HUDPaint", "drawmissionpanel", function()
    local ply = LocalPlayer()
    if ply:GetNWBool("InMenuState") then
    if currentTab == "Deploy" then
        local screenWidth, screenHeight = ScrW(), ScrH()

        local square1Height = 150
        local square2Height = square1Height * 2.5
        local squareWidth = 325
        local titleHeight = 40
        local spacingFromRight = 100

        local xPosition = screenWidth - squareWidth - spacingFromRight

        local square1YPosition = screenHeight / 2 - square1Height - 250
        local square2YPosition = screenHeight / 2 - 200

        draw.RoundedBox(0, xPosition, square1YPosition, squareWidth, square1Height, Color(40, 40, 40, 200))
        draw.RoundedBox(0, xPosition, square1YPosition, squareWidth, titleHeight, Color(40, 40, 40, 200))
        draw.RoundedBox(0, xPosition, square2YPosition, squareWidth, square2Height, Color(40, 40, 40, 200))
        draw.RoundedBox(0, xPosition, square2YPosition, squareWidth, titleHeight, Color(40, 40, 40, 200))


        local gradientStartColor = Color(80, 80, 90, 255)
        local gradientEndColor = Color(200, 200, 200, 0) 

        drawHorizontalGradient(xPosition, square1YPosition + titleHeight, squareWidth, 2, gradientStartColor, gradientEndColor)
        drawHorizontalGradient(xPosition, square2YPosition + titleHeight, squareWidth, 2, gradientStartColor, gradientEndColor)
        end
    end
end)

local buttons = {
    {
        img = Material("uielements/button_unselected.png"),
        imgToggled = Material("uielements/button_selected.png"),
        text = "Quit",
        x = 100,
        y = 400,
        w = 430 * 0.9,
        h = 131 * 0.9,
        action = function()
            print("Quit")
            timer.Simple( 0.1, function()
            toggledButton = nil
            end)
        end,
        font = "Countach Regular biggerx",
        fontToggled = "Countach Regular biggerxsel", 
        textColor = Color(200, 200, 200, 255),
        textColorToggled = Color(255, 165, 0, 255) 
    },
    {
        img = Material("uielements/button_unselected.png"),
        imgToggled = Material("uielements/button_selected.png"),
        text = "Settings",
        x = 100,
        y = 600,
        w = 430 * 0.9,
        h = 131 * 0.9,
        action = function()
            print("Settings")
        timer.Simple( 0.1, function()
            toggledButton = nil
        end)
        end,
        font = "Countach Regular biggerx",
        fontToggled = "Countach Regular biggerxsel",
        textColor = Color(200, 200, 200, 255),
        textColorToggled = Color(255, 165, 0, 255)
    },
    {
        img = Material("uielements/button_unselected.png"),
        imgToggled = Material("uielements/button_selected.png"),
        text = "Deploy",
        x = 100,
        y = 800,
        w = 430 * 0.9,
        h = 131 * 0.9,
        action = function()
            print("Deploy")
            timer.Simple( 0.1, function()
              toggledButton = nil
            end)
        end,
        font = "Countach Regular biggerx",
        fontToggled = "Countach Regular biggerxsel",
        textColor = Color(200, 200, 200, 255),
        textColorToggled = Color(255, 165, 0, 255)
    },
}

toggledButton = nil

hook.Add("HUDPaint", "DrawMenuButtons", function()
    ply = LocalPlayer()
    if ply:GetNWBool("InMenuState") then
    if currentTab == "Deploy" then
    for i, button in ipairs(buttons) do
        surface.SetDrawColor(255, 255, 255, 255)
        if toggledButton == i then
            surface.SetMaterial(button.imgToggled)
        else
            surface.SetMaterial(button.img)
        end
        surface.DrawTexturedRect(button.x, button.y, button.w, button.h)

        local font = toggledButton == i and button.fontToggled or button.font
        local textColor = toggledButton == i and button.textColorToggled or button.textColor
        draw.SimpleText(button.text, font, button.x + button.w / 2, button.y + button.h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        end
    end
end)

hook.Add("Think", "CheckMenuButtonClicks", function()
    if input.IsMouseDown(MOUSE_LEFT) then
        local mouseX, mouseY = gui.MousePos()
        for i, button in ipairs(buttons) do
            if mouseX >= button.x and mouseX <= button.x + button.w and mouseY >= button.y and mouseY <= button.y + button.h then
                toggledButton = (toggledButton == i) and nil or i
                button.action()
                break
            end
        end
    end
end)

notificationData = nil

net.Receive("Sendnotif", function()
    local title = net.ReadString()
    local lines = {net.ReadString(), net.ReadString(), net.ReadString(), net.ReadString(), net.ReadString()}
    notificationData = {title = title, lines = lines, show = true}
end)

local btnNormal = Material("uielements/button_unselected.png")
local btnHover = Material("uielements/button_selected.png")

hook.Add("HUDPaint", "DrawNotif", function()
    if notificationData and notificationData.show then
        local bgMaterial = Material("uielements/popup_background.png")
        local scrW, scrH = ScrW(), ScrH()
        local bgWidth, bgHeight = 1740 * 0.5, 815 * 0.5
        local bgX, bgY = (scrW - bgWidth) / 2, (scrH - bgHeight) / 2

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(bgMaterial)
        surface.DrawTexturedRect(bgX, bgY, bgWidth, bgHeight)

        draw.SimpleText(notificationData.title, "Countach Regular biggerx", scrW / 2, bgY + 20, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
        local lineY = bgY + 80
        for _, line in ipairs(notificationData.lines) do
            draw.SimpleText(line, "Countach Regular bigger", scrW / 2, lineY, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
            lineY = lineY + 40
        end

        local btnWidth, btnHeight = 430 * 0.5, 131 * 0.5
        local btnX, btnY = (scrW - btnWidth) / 2, bgY + bgHeight + 10
        local mouseX, mouseY = gui.MousePos()
        local isHovering = mouseX >= btnX and mouseX <= btnX + btnWidth and mouseY >= btnY and mouseY <= btnY + btnHeight

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(isHovering and btnHover or btnNormal)
        surface.DrawTexturedRect(btnX, btnY, btnWidth, btnHeight)

        local textColor = isHovering and Color(255, 165, 0, 255) or Color(200, 200, 200, 255)
        local textFont = isHovering and "Countach Regular biggerxsel" or "Countach Regular biggerx"

        draw.SimpleText("Done", textFont, scrW / 2, btnY + btnHeight / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if input.IsMouseDown(MOUSE_LEFT) and isHovering then
            notificationData.show = false
        end
    end
end)