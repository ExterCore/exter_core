RegisterNetEvent("exter_core:Client:HandleCallback")
AddEventHandler("exter_core:Client:HandleCallback", function(name, data) 
    if Exter.Callbacks[name] then
        Exter.Callbacks[name](data) 
        Exter.Callbacks[name] = nil 
    end
end)

RegisterNetEvent("exter_core:getSharedObject")
AddEventHandler("exter_core:getSharedObject", function(cb)
    if cb and type(cb) == 'function' then 
        cb(Exter)
    end 
end)
