RegisterNetEvent("exter_core:Server:HandleCallback")
AddEventHandler("exter_core:Server:HandleCallback", function(name, payload)
    local source = source

    if Exter.Callbacks[name] then
        Exter.Callbacks[name](source, payload, function(cb) 
            TriggerClientEvent("exter_core:Client:HandleCallback", source, name, cb)
        end)
    end 
end)
