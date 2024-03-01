local playerAvatar
local currentAvatarPlayerID
local waveAmplitude = 30 
local waveFrequency = 1 
local waveSpeed = 1       
local waveWidth = 30  
local heartMonitorXOffset = 0
local lineThickness = 2
local dots = {}
local maxDots = 0
local pushDistance = 0
local dotRadius = 0
local maxSpeed = 0

local function createDots(hudX, hudY, hudWidth, hudHeight)
    dots = {}
    for i = 1, maxDots do
        table.insert(dots, {
            x = math.random(hudX + 5, hudX + 5 + hudWidth - 275),
            y = math.random(hudY + 9, hudY + 9 + hudHeight - 4),
            vx = math.random(-50, 50) / 100,
            vy = math.random(-50, 50) / 100
        })
    end
end

local function limitSpeed(vx, vy, maxSpeed)
    local speed = math.sqrt(vx * vx + vy * vy)
    if speed > maxSpeed then
        local ratio = maxSpeed / speed
        vx = vx * ratio
        vy = vy * ratio
    end
    return vx, vy
end

local function updateDots(dt, hudX, hudY, hudWidth, hudHeight)
    for i, dot in ipairs(dots) do
        dot.x = dot.x + dot.vx * dt
        dot.y = dot.y + dot.vy * dt

        dot.vx, dot.vy = limitSpeed(dot.vx, dot.vy, maxSpeed)

        if dot.x < hudX + 5 or dot.x > hudX + 5 + hudWidth - 275 then
            dot.vx = -dot.vx
        end
        if dot.y < hudY + 9 or dot.y > hudY + 9 + hudHeight - 4 then
            dot.vy = -dot.vy
        end

        for j, other in ipairs(dots) do
            if i ~= j then
                local dx = other.x - dot.x
                local dy = other.y - dot.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < pushDistance then
                    surface.SetDrawColor(0, 0, 0, 255)  
                    surface.DrawLine(dot.x, dot.y, other.x, other.y)
                    dot.vx = dot.vx + dx / dist
                    dot.vy = dot.vy + dy / dist
                end
            end
        end
    end
end

local function drawDots()
    for _, dot in ipairs(dots) do
        surface.SetDrawColor(0, 0, 0, 255) 
        surface.DrawCircle(dot.x, dot.y, dotRadius, Color(0, 0, 0))
    end
end

local function drawRhombus(x, y, width, height, color, outlineColor)
    local halfWidth = width / 2
    local halfHeight = height / 2

    surface.SetDrawColor(color)
    surface.DrawPoly({
        { x = x, y = y + halfHeight },
        { x = x + halfWidth, y = y },
        { x = x + width, y = y + halfHeight },
        { x = x + halfWidth, y = y + height }
    })

    if outlineColor then
        surface.SetDrawColor(outlineColor)
        surface.DrawLine(x, y + halfHeight, x + halfWidth, y)
        surface.DrawLine(x + halfWidth, y, x + width, y + halfHeight)
        surface.DrawLine(x + width, y + halfHeight, x + halfWidth, y + height)
        surface.DrawLine(x + halfWidth, y + height, x, y + halfHeight)
    end
end

local function drawAmmoCounter()
    local weapon = LocalPlayer():GetActiveWeapon()
    if not IsValid(weapon) then return end

    local magAmmo = weapon:Clip1()
    local reserveAmmo = LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType())
    local ammoText = magAmmo .. " / " .. reserveAmmo

    local scrW, scrH = ScrW(), ScrH()
    local hudX, hudY = scrW - 250, scrH - 150 
    local hudWidth, hudHeight = 200, 40 

    local rombusColor = Color(80, 80, 80, 220) 
    local textColor = Color(255, 255, 255, 255) 

    surface.SetFont("DermaDefault")

    draw.RoundedBox(0, hudX, hudY, hudWidth, hudHeight, rombusColor)

    local textWidth, textHeight = surface.GetTextSize(ammoText)

    surface.SetTextPos(hudX + (hudWidth - textWidth) / 2, hudY + (hudHeight - textHeight) / 2)
    surface.SetTextColor(textColor)
    surface.DrawText(ammoText)
end

hook.Add("HUDPaint", "breachPixelHUDPaint", function()
    if not IsValid(LocalPlayer()) then return end

    local playerHealth = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()
    local playerAlive = playerHealth > 0

    local scrW, scrH = ScrW(), ScrH()
    local hudX, hudY = 10, scrH - 150
    local hudWidth, hudHeight = 300, 100

    createDots(hudX, hudY, hudWidth, hudHeight)

    -- outline
    local outlineColor = Color(50, 50, 50, 255) 
    local outlineThickness = 4 
    PIXEL.DrawRoundedBox(8, hudX + 5 - outlineThickness, hudY + 5 - outlineThickness, hudWidth + outlineThickness * 2, hudHeight + outlineThickness * 2, outlineColor)

    -- background
    PIXEL.DrawRoundedBox(8, hudX + 5, hudY + 5, hudWidth, hudHeight, Color(80, 80, 80, 255))

    -- wave effect
    local time = CurTime() * waveSpeed
    for x = 0, hudWidth, 1 do
    local y = math.sin((x / hudWidth) * waveFrequency * math.pi * 2 + time) * waveAmplitude
    y = y + (hudY + hudHeight / 2) 

    surface.SetDrawColor(50, 50, 50, 255)  
    surface.DrawRect(hudX + 5 + x, y - waveWidth / 2, 1, waveWidth)
    end
    
    -- team colour bar
    local teamColor = team.GetColor(LocalPlayer():Team())
    PIXEL.DrawRoundedBox(8, hudX + 5, hudY + 9, hudWidth - 275, hudHeight - 4, teamColor)


    local dt = FrameTime()
    updateDots(dt, hudX, hudY, hudWidth, hudHeight)
    drawDots()

    -- Health Bar
    local hpBarWidth, hpBarHeight = 180, 20
    local hpBarX, hpBarY = hudX + 110, hudY + 70
    local playerHealth = math.Clamp(LocalPlayer():Health(), 0, LocalPlayer():GetMaxHealth()) / LocalPlayer():GetMaxHealth()
    PIXEL.DrawRoundedBox(4, hpBarX, hpBarY, hpBarWidth, hpBarHeight, Color(255, 0, 0, 200))
    PIXEL.DrawRoundedBox(4, hpBarX, hpBarY, hpBarWidth * playerHealth, hpBarHeight, Color(0, 255, 0, 200))

    local monitorX, monitorY = hudX + 110, hudY + 70
    local monitorWidth, monitorHeight = 180, 20
    local heartMonitorSpeed = (maxHealth - playerHealth) / maxHealth * 5  
    heartMonitorXOffset = (heartMonitorXOffset + heartMonitorSpeed * FrameTime()) % monitorWidth

    if playerAlive then
        local oldY = monitorY
        for x = 0, monitorWidth, 2 do
            local y = math.sin((x + heartMonitorXOffset) / monitorWidth * math.pi * 8) * 5 + monitorY + monitorHeight / 2
            surface.SetDrawColor(80, 80, 80, 255)  
            for i = 0, lineThickness - 1 do
            surface.DrawLine(monitorX + x - 1, oldY + i, monitorX + x, y + i)
            end
            oldY = y
        end
    else
        surface.SetDrawColor(0, 0, 0, 255) 
    for i = 0, lineThickness - 1 do
        surface.DrawLine(monitorX, monitorY + monitorHeight / 2 + i, monitorX + monitorWidth, monitorY + monitorHeight / 2 + i)
    end
end

    -- Armor Bar
    local armorBarWidth, armorBarHeight = hpBarWidth, 10
    local armorBarX, armorBarY = hpBarX, hpBarY + hpBarHeight - 0
    local playerArmor = math.Clamp(LocalPlayer():Armor(), 0, 100) / 100
    PIXEL.DrawRoundedBox(2, armorBarX, armorBarY, armorBarWidth, armorBarHeight, Color(50, 50, 50, 200))
    PIXEL.DrawRoundedBox(2, armorBarX, armorBarY, armorBarWidth * playerArmor, armorBarHeight, Color(0, 0, 255, 200))

    -- Player's Name
    local nameX, nameY = hpBarX, hudY + 10
    PIXEL.DrawText(LocalPlayer():Nick(), "UI.FrameTitle", nameX, nameY, Color(192, 192, 192), TEXT_ALIGN_LEFT)

    -- Player's Avatar
    local avatarSize = 64
    local avatarX, avatarY = hudX + 40, hudY + 10
    local localPlayerID = LocalPlayer():SteamID64()

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

    local jobName = LocalPlayer():getDarkRPVar("job") or ""
    local money = LocalPlayer():getDarkRPVar("money") or 0
    local moneyText = "$" .. string.Comma(money)
    local jobAndMoneyYOffset = 20

    --Job Name
    local jobNameX, jobNameY = nameX, nameY + jobAndMoneyYOffset
    PIXEL.DrawText(jobName, "UI.FrameTitle", jobNameX, jobNameY, teamColor, TEXT_ALIGN_LEFT)

    --Money
    local moneyX, moneyY = jobNameX, jobNameY + jobAndMoneyYOffset
    PIXEL.DrawText(moneyText, "UI.FrameTitle", moneyX, moneyY, Color(214, 174, 34), TEXT_ALIGN_LEFT) 

    drawAmmoCounter(hudX, hudY, hudWidth, hudHeight)

end)



local function hideDefaultHUD(name)
    local elementsToHide = {
        ["CHudHealth"] = true,
        ["CHudBattery"] = true,
        ["CHudAmmo"] = true,
        ["CHudSecondaryAmmo"] = true
    }

    if elementsToHide[name] then
        return false
    end
end
hook.Add("HUDShouldDraw", "HideDefaultHUD", hideDefaultHUD)