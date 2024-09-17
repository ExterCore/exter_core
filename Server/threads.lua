Citizen.CreateThread(function() 
    while Exter.Framework == nil do
        if Config.Framework then 
            Exter.Framework = Config.Framework.GetFramework()
        end

        Citizen.Wait(1)
    end
end)