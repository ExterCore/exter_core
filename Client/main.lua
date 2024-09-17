Exter = {}
Exter.Callbacks = {}
Exter.Framework = nil
Exter.Game = {}
Exter.Functions = ExterShared.Functions
Exter.Types = ExterShared.Types
Exter.Config = Config

Exter.TriggerServerCallback = function(name, payload, func) 
    if not func then 
        func = function() end
    end

    Exter.Callbacks[name] = func

    TriggerServerEvent("exter_core:Server:HandleCallback", name, payload)
end

Exter.Game.GetVehicleProperties = function(vehicle)
    if Config.Framework == "ESX" then
        return Exter.Framework.Game.GetVehicleProperties(vehicle)
    elseif Config.Framework == "QBCore" then
        return Exter.Framework.Functions.GetVehicleProperties(vehicle)
    end
end

Exter.Game.SetVehicleProperties = function(vehicle, props) 
    if Config.Framework == "ESX" then
        return Exter.Framework.Game.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == "QBCore" then
        return Exter.Framework.Functions.SetVehicleProperties(vehicle, props)
    end
end

Exter.Draw3DText = function(x, y, z, scale, text, hideBox) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.40, 0.40)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)

    if not hideBox then 
        local factor = (string.len(text)) / 350

        DrawRect(_x,_y+0.0140, 0.025+ factor, 0.03, 0, 0, 0, 105)
    end
end

exports("getSharedObject", function() 
    return Exter
end)