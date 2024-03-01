function OpenSettingsMenu() -- unused at the moment
    local settingsMenu = vgui.Create("PIXEL.Frame")
    settingsMenu:SetSize(400, 600) 
    settingsMenu:Center()
    settingsMenu:SetTitle("Settings")

    settingsMenu:MakePopup() 
end
