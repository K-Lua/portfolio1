if CLIENT then
    local charCreationMenu

    function openCharCreationMenu()

        local charCreateMenu = vgui.Create("PIXEL.Frame")
        charCreateMenu:SetSize(ScrW() * 0.5, ScrH() * 0.5)
        charCreateMenu:Center()
        charCreateMenu:SetTitle("Create Character")
        charCreateMenu:MakePopup()

        local nameLabel = vgui.Create("PIXEL.Label", charCreateMenu)
        nameLabel:SetText("Name:")
        nameLabel:SetFont("DermaLarge")  
        nameLabel:SetSize(200, 30)
        nameLabel:SetPos(50, 50)

        local nameEntry = vgui.Create("PIXEL.TextEntry", charCreateMenu)
        nameEntry:SetSize(400, 30)
        nameEntry:SetPos(50, 75)
        nameEntry:SetPlaceholderText("Enter name (max 16 characters)")

        local descLabel = vgui.Create("PIXEL.Label", charCreateMenu)
        descLabel:SetText("Description:")
        descLabel:SetFont("DermaLarge")  
        descLabel:SetSize(200, 30)  
        descLabel:SetPos(50, 115)

        local descEntry = vgui.Create("PIXEL.TextEntry", charCreateMenu)
        descEntry:SetSize(400, 30)
        descEntry:SetPos(50, 140)
        descEntry:SetPlaceholderText("Enter description (max 128 characters)")

        local factionComboBox = vgui.Create("PIXEL.ComboBox", charCreateMenu)
        factionComboBox:SetPos(50, 180)
        factionComboBox:SetSize(200, 30)
        factionComboBox:SetValue("Select Faction")
        factionComboBox:AddChoice("SCP Foundation")
        factionComboBox:AddChoice("Civilian")
        factionComboBox:AddChoice("Chaos Insurgency")
        factionComboBox:AddChoice("GOI")
        factionComboBox.OnSelect = function(index, value)
            selectedFaction = value 
        end

        local finishBtn = vgui.Create("PIXEL.TextButton", charCreateMenu)
        finishBtn:SetText("Finish")
        finishBtn:SetSize(100, 30)
        finishBtn:SetPos(50, 220)
        finishBtn.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            local name = nameEntry:GetValue()
            local description = descEntry:GetValue()
            local faction = selectedFaction

            net.Start("CharacterCreationData")
            net.WriteString(name)
            net.WriteString(description)
            net.WriteString(faction or "")
            net.SendToServer()

            charCreateMenu:Close()
        end

        local backBtn = vgui.Create("PIXEL.TextButton", charCreateMenu)
        backBtn:SetText("Back")
        backBtn:SetSize(100, 30)
        backBtn:SetPos(160, 220)
        backBtn.DoClick = function(self)
            surface.PlaySound(self.ClickSound)
            charCreateMenu:Close()
        end
    end

    concommand.Add("open_character_crea", openCharCreationMenu)
end