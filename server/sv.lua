--[[===================================================================================================================
==========================         HERE YOU CAN CHANGE THE DRUG BAGGING        ========================================
====================================================================================================================]]
ESX.RegisterUsableItem(Config.items.brick, function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    -- Get how many Config.items.bag the player has
    local bagAmount = xPlayer.getInventoryItem(Config.items.bag).count
    if bagAmount >= Config.items.bagAmount then
        TriggerClientEvent("cokeRun:packBrick", playerId)
    else
        -- Show notification to the player
        TriggerClientEvent("esx:showNotification", playerId, Config.messages.noEnoughBags)
    end

end)


--[[===================================================================================================================
======================================         DONT CHANGE        =====================================================
====================================================================================================================]]
local missionInProgress = false

ESX.RegisterServerCallback("cokeRun:checkIfHasKey", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasKey = xPlayer.getInventoryItem(Config.items.planeKey).count
    if hasKey > 0 then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("cokeRun:getBlackMoney", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount("black_money").money
    cb(blackMoney)
end)

ESX.RegisterServerCallback("cokeRun:getMissionInProgress", function(source, cb)
    cb(missionInProgress)
end)

RegisterServerEvent("cokeRun:removeBlackMoney")
AddEventHandler("cokeRun:removeBlackMoney", function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeAccountMoney("black_money", amount)
end)

RegisterServerEvent("cokeRun:giveBrick")
AddEventHandler("cokeRun:giveBrick", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(Config.items.brick, math.random(Config.cokeBrickAmount.min, Config.cokeBrickAmount.max))
end)

RegisterServerEvent("cokeRun:missionStarted")
AddEventHandler("cokeRun:missionStarted", function(bool)
    missionInProgress = bool
end)

RegisterServerEvent("cokeRun:finishPacking")
AddEventHandler("cokeRun:finishPacking", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Remove the Config.items.brick from the player
    xPlayer.removeInventoryItem(Config.items.brick, 1)

    -- Remove the Config.items.bag from the player
    xPlayer.removeInventoryItem(Config.items.bag, Config.items.bagAmount)

    -- Add the Config.items.baggy to the player
    xPlayer.addInventoryItem(Config.items.baggy, Config.items.bagAmount)

    -- Show notification to the player
    TriggerClientEvent("esx:showNotification", playerId, Config.messages.packedSuccessfully)
end)

RegisterServerEvent("cokeRun:giveBlackMoney")
AddEventHandler("cokeRun:giveBlackMoney", function(amount, inMission)
    local xPlayer = ESX.GetPlayerFromId(source)
    if inMission == 3 then
        xPlayer.addAccountMoney("black_money", amount)
    end
end)

RegisterServerEvent("cokeRun:givePlaneKey")
AddEventHandler("cokeRun:givePlaneKey", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    print("Giving plane key")
    xPlayer.addInventoryItem(Config.items.planeKey, 1)
end)