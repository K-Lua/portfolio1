if CLIENT then

factionModels = {
    [1] = "models/player/kerry/class_d_1.mdl",  -- SCP Foundation
    [2] = "models/Humans/Group01/Female_01.mdl", -- Civilian
    [3] = "models/scp_mtf_russian/mtf_rus_02.mdl", -- Chaos Insurgency
    [4] = "models/ninja/mw3/delta/delta4_masked.mdl", -- Group of Interest (GOI)
}

factionNames = {
    [1] = "SCP Foundation",
    [2] = "Civilian",
    [3] = "Chaos Insurgency",
    [4] = "Group of Interest (GOI)",
}

    local characterMenu
    local characterData = {}
    
net.Receive("SendCharacterData", function()
    characterData = net.ReadTable()
    print("Received character data:", characterData)
    hasReceivedCharacterData = true
    if IsValid(characterMenu) then
        print("Debug: Character menu is valid, updating character slots.")
    local checkDataInterval = 0.5 
    local maxWaitTime = 10
    local timerName = "WaitForCharacterData"

    timer.Create(timerName, checkDataInterval, maxWaitTime / checkDataInterval, function()
        if characterData and table.Count(characterData) > 0 then
            print("Character data received, updating character slots.")
            updateCharacterSlots()
            timer.Remove(timerName)
        else
            print("Waiting for character data...")
        end
    end)
end

end

function updateCharacterSlots()
    if not IsValid(characterMenu) or not hasReceivedCharacterData or table.Count(characterData) == 0 then return
    end
        for i = 1, 4 do
            print("Debug: Processing slot", i)
            local slot = characterMenu.CharacterSlots[i]
            local data = characterData[i]

            if slot and data then
                print("Debug: Updating slot", i)
                if slot.NameLabel then
                    slot.NameLabel:SetText(data.name or "Character " .. i)
                end
                if slot.FactionLabel then
                    slot.FactionLabel:SetText(factionNames[tonumber(data.faction)] or "Unknown Faction")
                end

                local factionModel = factionModels[tonumber(data.faction)] or "models/Humans/Group02/male_09.mdl"
                if slot.ModelPanel then
                    slot.ModelPanel:SetModel(factionModel)
                end

                if slot.LoadButton then
                    slot.LoadButton:SetVisible(true)
                end

                if slot.MenuButton then
                    slot.MenuButton:SetVisible(true)
                end
            elseif slot then
                print("Debug: Slot", i, "is empty.")
                if slot.NameLabel then
                    slot.NameLabel:SetText("Empty Slot")
                end
                if slot.ModelPanel then
                    slot.ModelPanel:SetModel("")
                end
                if slot.LoadButton then
                    slot.LoadButton:SetVisible(false)
                end
                if slot.MenuButton then
                    slot.MenuButton:SetVisible(false)
                end
            end
        end
    end
    
function openCharacterMenu() 
        net.Start("RequestCharacterData")
        net.SendToServer()

        characterMenu = vgui.Create("DPanel")
        characterMenu:SetSize(ScrW(), ScrH())
        characterMenu:Center()
        characterMenu:MakePopup()
        characterMenu:SetBackgroundColor(Color(15, 15, 15, 200))

        local sidebarWidth = 200
        local sidebar = vgui.Create("DPanel", characterMenu)
        sidebar:SetSize(sidebarWidth, characterMenu:GetTall())
        sidebar:SetBackgroundColor(Color(30, 30, 30, 255))

        local serverNameLabel = vgui.Create("DLabel", sidebar)
        serverNameLabel:SetText("SCP Project")
        serverNameLabel:SetFont("DermaLarge")
        serverNameLabel:SizeToContents()
        serverNameLabel:SetPos(sidebar:GetWide() / 2 - serverNameLabel:GetWide() / 2, 30)

        local buttonHeight = 40
        local buttonMargin = 10
        local yPosition = 100

        local createCharButton = vgui.Create("PIXEL.TextButton", sidebar)
        createCharButton:SetText("Create Character")
        createCharButton:SetSize(sidebarWidth - 20, buttonHeight)
        createCharButton:SetPos(10, yPosition)
        yPosition = yPosition + buttonHeight + buttonMargin
        createCharButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            if IsValid(characterMenu) then
                openCharCreationMenu()
            end
        end

        local discordButton = vgui.Create("PIXEL.TextButton", sidebar)
        discordButton:SetText("Discord")
        discordButton:SetSize(sidebarWidth - 20, buttonHeight)
        discordButton:SetPos(10, yPosition)
        yPosition = yPosition + buttonHeight + buttonMargin
        discordButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            gui.OpenURL("https://discord.gg")
        end

        local forumsButton = vgui.Create("PIXEL.TextButton", sidebar)
        forumsButton:SetText("Forums")
        forumsButton:SetSize(sidebarWidth - 20, buttonHeight)
        forumsButton:SetPos(10, yPosition)
        yPosition = yPosition + buttonHeight + buttonMargin
        forumsButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            gui.OpenURL("https://")
        end
        
        local donationButton = vgui.Create("PIXEL.TextButton", sidebar)
        donationButton:SetText("Store")
        donationButton:SetSize(sidebarWidth - 20, buttonHeight)
        donationButton:SetPos(10, yPosition)
        yPosition = yPosition + buttonHeight + buttonMargin
        donationButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            gui.OpenURL("https://")
        end

        local contentpackButton = vgui.Create("PIXEL.TextButton", sidebar)
        contentpackButton:SetText("Content Pack")
        contentpackButton:SetSize(sidebarWidth - 20, buttonHeight)
        contentpackButton:SetPos(10, yPosition)
        yPosition = yPosition + buttonHeight + buttonMargin
        contentpackButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            gui.OpenURL("https://steamcommunity.com/")
        end

        local disconnectButton = vgui.Create("PIXEL.TextButton", sidebar)
        disconnectButton:SetText("Disconnect")
        disconnectButton:SetSize(sidebarWidth - 20, buttonHeight)
        disconnectButton:SetPos(10, yPosition)
        disconnectButton.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            local confirmDisconnect = vgui.Create("PIXEL.Frame")
            confirmDisconnect:SetTitle("Disconnect")
            confirmDisconnect:SetSize(300, 150)
            confirmDisconnect:Center()
            confirmDisconnect:MakePopup()

            local yesButton = vgui.Create("PIXEL.TextButton", confirmDisconnect)
            yesButton:SetText("Disconnect")
            yesButton:SetPos(75, 50)
            yesButton:SetSize(125, 30)
            yesButton.DoClick = function()
                RunConsoleCommand("disconnect")
            end

            local noButton = vgui.Create("PIXEL.TextButton", confirmDisconnect)
            noButton:SetText("Close")
            noButton:SetPos(75, 100)
            noButton:SetSize(125, 30)
            noButton.DoClick = function(self)
                surface.PlaySound(self.ClickSound)
                confirmDisconnect:Close()
            end
        end

        local charDisplayArea = vgui.Create("DPanel", characterMenu)
        charDisplayArea:SetSize(characterMenu:GetWide() - sidebarWidth, characterMenu:GetTall())
        charDisplayArea:SetPos(sidebarWidth, 0)
        charDisplayArea:SetBackgroundColor(Color(40, 40, 40, 255))

        characterMenu.CharacterSlots = {}
        
        print("Debug: Finished setting up character menu.")
        

for i = 1, 4 do
    local charSlot = vgui.Create("DPanel", charDisplayArea)
    charSlot:SetSize(200, 300)
    charSlot:SetPos(20 + (i - 1) * 220, 50)
    charSlot:SetBackgroundColor(Color(20, 20, 20, 200))

    local charName = vgui.Create("DLabel", charSlot)
    charName:SetText("Loading...")
    charName:SetFont("DermaLarge")
    charName:SizeToContents()
    charName:SetPos(10, 10)

    local factionName = vgui.Create("DLabel", charSlot)
    factionName:SetPos(10, charName:GetTall() + 15)
    factionName:SetFont("DermaDefault")
    factionName:SetSize(180, 20)
    factionName:SetText("Faction Name")

    local modelPanel = vgui.Create("DModelPanel", charSlot)
    modelPanel:SetSize(180, 180)
    modelPanel:SetModel("models/Humans/Group02/male_09.mdl")
    modelPanel:SetPos(10, 40)

    local loadCharButton = vgui.Create("PIXEL.TextButton", charSlot)
    loadCharButton:SetText("Load Character")
    loadCharButton:SetSize(150, 30)
    loadCharButton:SetPos(15, 230)
    loadCharButton:SetVisible(false)
    loadCharButton.DoClick = function(self)
    surface.PlaySound(self.ClickSound)
    net.Start("RequestLoadCharacter")
    net.WriteInt(i, 32) 
    net.SendToServer()
    print("Requesting to load character in slot " .. i)
    end

local menuButton = vgui.Create("PIXEL.TextButton", charSlot) 
menuButton:SetText("...")
menuButton:SetSize(20, 30) 
menuButton:SetPos(170, 230)
menuButton:SetVisible(false)
menuButton.DoClick = function()
    local x, y = charSlot:GetPos() 
    local optionsPanel = vgui.Create("PIXEL.Frame", characterMenu) 
    optionsPanel:SetSize(200, 300)
    optionsPanel:SetPos(x + 200, y) 
    optionsPanel:SetTitle("Options")
    optionsPanel:MakePopup()

    local renameButton = vgui.Create("PIXEL.TextButton", optionsPanel)
    renameButton:SetText("Rename Character")
    renameButton:SetSize(180, 30)
    renameButton:SetPos(10, 30)
    renameButton.DoClick = function()
        local renameFrame = vgui.Create("PIXEL.Frame")
        renameFrame:SetTitle("Rename Character")
        renameFrame:SetSize(300, 135)
        renameFrame:Center()
        renameFrame:MakePopup()

        local nameEntry = vgui.Create("PIXEL.TextEntry", renameFrame)
        nameEntry:SetPlaceholderText("Enter New Name")
        nameEntry:Dock(TOP)
        nameEntry:DockMargin(10, 5, 10, 0)
        nameEntry:SetTall(30)

        local confirmButton = vgui.Create("PIXEL.TextButton", renameFrame)
        confirmButton:SetText("Confirm")
        confirmButton:Dock(BOTTOM)
        confirmButton:DockMargin(10, 5, 10, 10)
        confirmButton:SetTall(30)
        confirmButton.DoClick = function()
            local charID = characterMenu.CharacterSlots[i].charID
            local newName = nameEntry:GetValue()
            if not newName or newName == "" then return end 

            net.Start("RenameCharacter")
            net.WriteInt(charID, 32) 
            net.WriteString(newName)
            net.SendToServer()

            renameFrame:Close()
        end
    end
end
   local deleteButton = vgui.Create("PIXEL.TextButton", optionsPanel)
   deleteButton:SetText("Delete Character")
   deleteButton:SetSize(180, 30)
   deleteButton:SetPos(10, 65)
   deleteButton.DoClick = function()
   local charID = characterMenu.CharacterSlots[i].charID
    net.Start("DeleteCharacter")
    net.WriteInt(charID, 32) 
    net.SendToServer()
end

end

end

if not characterMenu.CharacterSlots then
    characterMenu.CharacterSlots = {}
end

print("Index i:", i)

if i then
print("Index i:", i)
characterMenu.CharacterSlots[i] = {
    Panel = charSlot,
    NameLabel = charName,
    FactionLabel = factionName,
    ModelPanel = modelPanel,
    LoadButton = loadCharButton,
    MenuButton = menuButton,
}

else
    print("Index i:", i)
    print("slots are nil")
    
end

print("Index i:", i)
concommand.Add("open_character_menu", openCharacterMenu)
    
    net.Receive("CharacterLoaded", function()
    local characterName = net.ReadString()
    local fadePanel = vgui.Create("DPanel")
    fadePanel:SetSize(ScrW(), ScrH())
    fadePanel:SetBackgroundColor(Color(0, 0, 0, 0))
    fadePanel:AlphaTo(255, 1, 0, function()
        if IsValid(characterMenu) then
            characterMenu:Remove()
        end
        
        if characterName then
            LocalPlayer():ConCommand('say /name ' .. characterName)
        end
        
        scpbasenotif(3, Color(0, 200, 0), "Loaded Character!")

        fadePanel:AlphaTo(0, 1, 1, function()
            fadePanel:Remove() 
        end)
    end)
end)

end

end