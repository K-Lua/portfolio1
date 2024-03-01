if CLIENT then

    local breachCMenu
    local breachMenuOpen = false

    hook.Add("OnContextMenuOpen", "breachDisableDefaultCMenu", function()
        return false
    end)

    hook.Add("Think", "breachContextMenuToggle", function()
        if input.IsKeyDown(KEY_C) and not breachMenuOpen and not gui.IsConsoleVisible() and not gui.IsGameUIVisible() then
            if not IsValid(breachCMenu) then
                breachCMenu = vgui.Create("PIXEL.Frame")
                breachCMenu:SetSize(ScrW() * 0.2, ScrH())
                breachCMenu:SetPos(-breachCMenu:GetWide(), 0)
                breachCMenu:SetTitle("C Menu")
                breachCMenu:SetVisible(false)

                local settingsButton = vgui.Create("PIXEL.TextButton", breachCMenu)
                settingsButton:SetText("Settings")
                settingsButton:Dock(TOP)
                settingsButton:DockMargin(5, 5, 5, 0)
                settingsButton.DoClick = function()
                end

                local pacButton = vgui.Create("PIXEL.TextButton", breachCMenu)
                pacButton:SetText("PAC")
                pacButton:Dock(TOP)
                pacButton:DockMargin(5, 5, 5, 0)
                pacButton.DoClick = function()
                    RunConsoleCommand("pac_editor")
                    closebreachMenu()
                end

                local ulxButton = vgui.Create("PIXEL.TextButton", breachCMenu)
                ulxButton:SetText("SAM Menu")
                ulxButton:Dock(TOP)
                ulxButton:DockMargin(5, 5, 5, 0)
                ulxButton.DoClick = function()
                    LocalPlayer():ConCommand("say !menu")
                    closebreachMenu()
                end
            end

            breachCMenu:SetVisible(true)
            breachCMenu:MoveTo(0, 0, 0.2, 0, -1)
            gui.EnableScreenClicker(true)
            breachMenuOpen = true
        elseif not input.IsKeyDown(KEY_C) and breachMenuOpen then
            closebreachMenu()
        end
    end)

    function closebreachMenu()
        if IsValid(breachCMenu) then
            breachCMenu:MoveTo(-breachCMenu:GetWide(), 0, 0.2, 0, -1, function()
                timer.Simple(0.4, function()
                    if IsValid(breachCMenu) then
                        breachCMenu:Remove()
                        breachCMenu = nil
                    end
                end)
            end)
            breachMenuOpen = false
            gui.EnableScreenClicker(false)
        end
    end

end