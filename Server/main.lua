Exter = {}
Exter.Callbacks = {}
Exter.Players = {}
Exter.Framework = nil
Exter.Functions = ExterShared.Functions
Exter.Types = ExterShared.Types
Exter.Vehicles = nil
Exter.Config = Config
Exter.MySQL = {
    Async = {},
    Sync = {}
}

Exter.RegisterServerCallback = function(name, func) 
    Exter.Callbacks[name] = func
end

Exter.TriggerCallback = function(name, source, payload, cb) 
    if not cb then 
        cb = function() end
    end

    if Exter.Callbacks[name] then 
        Exter.Callbacks[name](source, payload, cb)
    end
end

Exter.MySQL.Async.Fetch = function(query, variables, cb) 
    if not cb or type(cb) ~= 'function' then 
        cb = function() end
    end

    if Config.Database.Name == "MYSQL-ASYNC" then
        return exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.Database.Name == "OXMYSQL" then
        return exports["oxmysql"]:prepare(query, variables, cb) 
    end
end

Exter.MySQL.Sync.Fetch = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.Database.Name == "MYSQL-ASYNC" then
        exports["mysql-async"]:mysql_fetch_all(query, variables, cb) 
    elseif Config.Database.Name == "OXMYSQL" then
        exports["oxmysql"]:execute(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end

    return result
end

Exter.MySQL.Async.Execute = function(query, variables, cb) 
    if Config.Database.Name == "MYSQL-ASYNC" then
        return exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.Database.Name == "OXMYSQL" then
        return exports["oxmysql"]:update(query, variables, cb)
    end
end

Exter.MySQL.Sync.Execute = function(query, variables) 
    local result = {}
    local finishedQuery = false
    local cb = function(r) 
        result = r
        finishedQuery = true
    end

    if Config.Database.Name == "MYSQL-ASYNC" then
        exports["mysql-async"]:mysql_execute(query, variables, cb) 
    elseif Config.Database.Name == "OXMYSQL" then
        exports["oxmysql"]:execute(query, variables, cb)
    end

    while not finishedQuery do
        Citizen.Wait(0)
    end
    
    return result
end

Exter.IsPlayerAvailable = function(source) 
    local available = false

    if type(source) == 'number' then 
        if Config.Framework.Name == "ESX" then
            available = Exter.Framework.GetPlayerFromId(source) ~= nil
        elseif Config.Framework.Name == "QBCore" then
            available = Exter.Framework.Functions.GetPlayer(source) ~= nil
        end
    elseif type(source) == 'string' then
        if Config.Framework.Name == "ESX" then
            available = Exter.Framework.GetPlayerFromIdentifier(identifier) ~= nil
        elseif Config.Framework.Name == "QBCore" then
            available = Exter.Framework.Functions.GetSource(identifier) ~= nil
        end
    end

    return available
end

Exter.GetPlayerIdentifier = function(source)
    if Exter.IsPlayerAvailable(source) then
        if Config.Framework.Name == "ESX" then
            local xPlayer = Exter.Framework.GetPlayerFromId(source)
            return xPlayer.getIdentifier()
        elseif Config.Framework.Name == "QBCore" then
            return Exter.Framework.Functions.GetIdentifier(source, 'license')
        end
    else
        return nil
    end
end

Exter.GetCharacterIdentifier = function(source)
    if Exter.IsPlayerAvailable(source) then
        if Config.Framework.Name == "ESX" then
            local xPlayer = Exter.Framework.GetPlayerFromId(source)
            return xPlayer.identifier
        elseif Config.Framework.Name == "QBCore" then
            return Exter.Framework.Functions.GetPlayer(source).PlayerData.citizenid
        end
    else
        return nil
    end
end

Exter.CreatePlayer = function(xPlayer) 
    local player = {}

    if not xPlayer then 
        return nil
    end

    if Config.Framework.Name == "ESX" then 
        player.name = xPlayer.getName()
        player.accounts = {}
        for _,v in ipairs(xPlayer.getAccounts()) do 
            if v.name == 'bank' then 
                player.accounts["bank"] = v.money
            elseif v.name == 'money' then
                player.accounts["cash"] = v.money
            end
        end
        if xPlayer.variables.sex == 'm' then 
            player.gender = 'male' 
        else
            player.gender = 'female'
        end
        player.job = {
            name = xPlayer.getJob().name,
            label = xPlayer.getJob().label
        }
        player.birth = xPlayer.variables.dateofbirth

        player.getBank = function() 
            return xPlayer.getAccount("bank").money 
        end
        player.getMoney = xPlayer.getMoney
        player.addBank = function(amount) 
            xPlayer.addAccountMoney('bank', tonumber(amount)) 
        end
        player.addMoney = function(amount)
            xPlayer.addMoney(tonumber(amount))
        end
        player.removeBank = function(amount) 
            xPlayer.removeAccountMoney('bank', tonumber(amount)) 
        end
        player.removeMoney = function(amount) 
            xPlayer.removeMoney(tonumber(amount))
        end
    elseif Config.Framework.Name == "QBCore" then
        player.name = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
        player.accounts = {
            bank =  xPlayer.PlayerData.money.bank,
            cash = xPlayer.PlayerData.money.cash
        }
        if xPlayer.PlayerData.charinfo.gender == 0 then 
            player.gender = 'male'
        else
            player.gender = 'female'
        end
        player.job = {
            name = xPlayer.PlayerData.job.name,
            label = xPlayer.PlayerData.job.label
        }
        player.birth = xPlayer.PlayerData.charinfo.birthdate

        player.getBank = function() 
            return xPlayer.Functions.GetMoney("bank")
        end
        player.getMoney = function()
            return xPlayer.Functions.GetMoney("cash") 
        end
        player.addBank = function(amount)
            return xPlayer.Functions.AddMoney("bank", amount, "") 
        end
        player.addMoney = function(amount)
            return xPlayer.Functions.AddMoney("cash", amount, "") 
        end
        player.removeBank = function(amount) 
            return xPlayer.Functions.RemoveMoney("bank", amount, "")
        end
        player.removeMoney = function(amount) 
            return xPlayer.Functions.RemoveMoney("cash", amount, "")
        end
    end

    return player
end

Exter.GetPlayer = function(source)
    if Exter.IsPlayerAvailable(source) then 
        local xPlayer = nil

        if Config.Framework.Name == "ESX" then
            xPlayer = Exter.Framework.GetPlayerFromId(source)
        elseif Config.Framework.Name == "QBCore" then
            xPlayer = Exter.Framework.Functions.GetPlayer(source)
        end

        return Exter.CreatePlayer(xPlayer)
    else
        return nil
    end
end

Exter.GetPlayerFromIdentifier = function(identifier) 
    if Exter.IsPlayerAvailable(identifier) then 
        local xPlayer = nil

        if Config.Framework.Name == "ESX" then
            xPlayer = Exter.Framework.GetPlayerFromIdentifier(identifier)
        elseif Config.Framework.Name == "QBCore" then
            xPlayer = Exter.Framework.Functions.GetPlayer(Exter.Framework.Functions.GetSource(identifier))
        end

        return Exter.CreatePlayer(xPlayer)
    else
        return nil
    end
end

Exter.GetPlayerFromCharacterIdentifier = function(charIdentifier)
    local xPlayer = nil 
    if Config.Framework.Name == "ESX" then
        for _, player in ipairs(Exter.Framework.GetExtendedPlayers()) do 
            if player.identifier == charIdentifier then
                xPlayer = player 
                break
            end
        end
    elseif Config.Framework.Name == "QBCore" then
        for _, player in ipairs(Exter.Framework.Functions.GetPlayers()) do 
            player = Exter.Framework.Functions.GetPlayer(player)
            if player.PlayerData.citizenid == charIdentifier then 
                xPlayer = player
            end
        end

    end

    return Exter.CreatePlayer(xPlayer)
end 

Exter.GetAllVehicles = function(force)
    if Exter.Vehicles and not force then 
        return Exter.Vehicles
    end

    local vehicles = {}

    if Config.Framework.Name == "ESX" then
        local data = Exter.MySQL.Sync.Fetch("SELECT * FROM vehicles", {})

        for k, v in ipairs(data) do 
            vehicles[v.model] = {
                model = v.model,
                name = v.name,
                category = v.category,
                price = v.price
            }
        end
        
    elseif Config.Framework.Name == "QBCore" then 
        for k,v in pairs(Exter.Framework.Shared.Vehicles) do
            vehicles[k] = {
                model = k,
                name = v.name,
                category = v.category,
                price = v.price
            } 
        end
    end

    Exter.Vehicles = vehicles

    return vehicles
end

Exter.GetVehicleByName = function(name) 
    local vehicles = Exter.GetAllVehicles(false)
    local targetVehicle = nil

    for k,v in pairs(vehicles) do
        if v.name == name then 
            targetVehicle = v
            break
        end
    end 

    return targetVehicle
end

Exter.GetVehicleByHash = function(hash) 
    local vehicles = Exter.GetAllVehicles(false)
    local targetVehicle = nil

    for k,v in pairs(vehicles) do
        if GetHashKey(v.model) == hash then 
            targetVehicle = v
            break
        end
    end

    return targetVehicle
end

Exter.GetPlayerVehicles = function(source) 
    local identifier = Exter.GetPlayerIdentifier(source)

    if identifier then 
        local vehicles = Exter.GetAllVehicles(false)
        local playerVehicles = {}

        if Config.Framework.Name == "ESX" then
            local data = Exter.MySQL.Sync.Fetch("SELECT * FROM owned_vehicles WHERE owner = @identifier", { ["@identifier"] = identifier })

            for k,v in ipairs(data) do
                local vehicleDetails = Exter.GetVehicleByHash(json.decode(v.vehicle).model)

                if not vehicleDetails then 
                    vehicleDetails = {
                        name = nil,
                        model = json.decode(v.vehicle).model,
                        category = nil,
                        price = nil
                    }
                end

                table.insert(playerVehicles, {
                    name = vehicleDetails.name,
                    model = vehicleDetails.model,
                    category = vehicleDetails.category,
                    plate = v.plate,
                    fuel = v.fuel or 100,
                    price = vehicleDetails.price,
                    properties = json.decode(v.vehicle),
                    stored = v.stored,
                    garage = v.garage or nil
                })
            end
        elseif Config.Framework.Name == "QBCore"  then
            local data = Exter.MySQL.Sync.Fetch("SELECT * FROM player_vehicles WHERE license = @identifier", { ["@identifier"] = identifier })

            for k,v in ipairs(data) do
                if v.stored == 1 then
                    v.stored = true
                else
                    v.stored = false 
                end

                table.insert(playerVehicles, {
                    name = vehicles[v.vehicle].name,
                    model = vehicles[v.vehicle].model,
                    category = vehicles[v.vehicle].category,
                    plate = v.plate,
                    fuel = v.fuel,
                    price = vehicles[v.vehicle].price or -1,
                    properties = json.decode(v.mods),
                    stored = v.stored,
                    garage = v.garage
                })
            end
        end

        return playerVehicles
    else
        return nil
    end
end

Exter.UpdatePlayerVehicle = function(source, plate, vehicleData) 
    local identifier = Exter.GetPlayerIdentifier(source)

    if identifier then 
        local playerVehicles = Exter.GetPlayerVehicles(source)
        local targetVehicle = nil

        for k,v in ipairs(playerVehicles) do
             if v.plate == plate then
                targetVehicle = v 
            end
        end

        if not targetVehicle then 
            return false
        end

        local query = nil
        if Config.Framework.Name == "ESX" then
            query = "UPDATE owned_vehicles SET vehicle = @props, stored = @stored, garage = @garage WHERE owner = @identifier AND plate = @plate"
        elseif Config.Framework.Name == "QBCore" then
            query = "UPDATE player_vehicles SET mods = @props, stored = @stored, garage = @garage WHERE license = @identifier AND plate = @plate"
        end

        if query then 
            Exter.MySQL.Sync.Execute(query, {
            ["@props"] = json.encode(vehicleData.properties or targetVehicle.properties),
            ["@stored"] = vehicleData.stored,
            ["@garage"] = vehicleData.garage,
            ["@identifier"] = identifier,
            ["@plate"] = plate
            })

            return true
        else
            return false
        end

    else
        return false
    end
end

Exter.UpdateVehicleOwner = function(plate, target) 
    local identifier = Exter.GetPlayerIdentifier(target)

    if not identifier then 
        return false
    end

    local query = nil
    if Config.Framework.Name == "ESX" then
        query = "UPDATE owned_vehicles SET owner = @newOwner WHERE plate = @plate" 
    elseif Config.Framework.Name == "QBCore" then
        query = "UPDATE player_vehicles SET license = @newOwner WHERE plate = @plate"
    end

    if query then 
        Exter.MySQL.Sync.Execute(query, { ["@newOwner"] = identifier, ["@plate"] = plate })

        return true
    else
        return false
    end
end

Exter.RegisterUsableItem = function(name, action) 
    if Config.Framework.Name == "ESX" then 
        Exter.Framework.RegisterUsableItem(name, function(source)
            local xPlayer = Exter.Framework.GetPlayerFromId(source)
            action(Exter.CreatePlayer(xPlayer), source)
        end)
    elseif Config.Framework.Name == 'QBCore' then
        Exter.Framework.Functions.CreateUseableItem(name, function(source)
            local xPlayer = Exter.Framework.Functions.GetPlayer(source)
            action(Exter.CreatePlayer(xPlayer), source)
        end)
    end
end

exports("getSharedObject", function() 
    return Exter
end)
