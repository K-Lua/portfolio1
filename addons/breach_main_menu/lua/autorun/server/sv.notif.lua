util.AddNetworkString("SendNotification")
util.AddNetworkString("NoClipNotif")

local function sendCustomNotification(ply)
    net.Start("SendNotification")
    net.Send(ply)
end