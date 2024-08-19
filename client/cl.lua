local inMission = 0
local G_propCoords
local brickProp
--[[
    0 = not in mission
    1 = going to plane
    2 = in plane
    3 = brick collected
]]

local plane

local planeBlip, cokeBlip, hangarBlip

-- Mission Timer
local API_ProgressBar = exports["clm_ProgressBar"]:GetAPI()

local bar_TextTimerBar

function startTimerHud()
    print("Gets here")
    local minutes = math.floor(Config.missionTime)
    local seconds = math.floor((Config.missionTime - minutes) * 60)
    if seconds < 10 then
        seconds = "0"..seconds
    end
    if minutes < 10 then
        minutes = "0"..minutes
    end

    local timeStr = minutes..":"..seconds

    bar_TextTimerBar = API_ProgressBar.add("TextTimerBar", "GET THE DRUGS", timeStr)

    bar_TextTimerBar.Func.setTitleColor({255, 255, 255, 255})
    bar_TextTimerBar.Func.setHighlightColor({102, 102, 102, 255})

    bar_TextTimerBar.Func.lib.TextTimerBar.setText(timeStr)
    bar_TextTimerBar.Func.lib.TextTimerBar.setTextColor({255, 255, 255, 255})

    Citizen.CreateThread(function()
        while inMission > 0 do
            Citizen.Wait(1000)
            seconds = tonumber(seconds) - 1
            if seconds < 0 then
                seconds = 59
                minutes = tonumber(minutes) - 1
            end
            if seconds < 10 then
                seconds = "0"..seconds
            end

            timeStr = minutes..":"..seconds
            bar_TextTimerBar.Func.lib.TextTimerBar.setText(timeStr)

        end
    end)
end

--[[===================================================================================================================
================================                    FUNCTIONS                  ========================================
===================================================================================================================--]]

function draw3DText(text, coords)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z+1)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    local scale = 0.35
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function spawnNPCs()
    for i = 1, #Config.rentPlane do
        -- Request the model
        RequestModel(GetHashKey(Config.rentPlane[i].model))
        while not HasModelLoaded(GetHashKey(Config.rentPlane[i].model)) do
            Citizen.Wait(0)
        end
        -- Create the ped
        local npc = CreatePed(4, GetHashKey(Config.rentPlane[i].model), Config.rentPlane[i].npcCoords.x, Config.rentPlane[i].npcCoords.y, Config.rentPlane[i].npcCoords.z-1, Config.rentPlane[i].npcCoords.h, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        -- Make the ped do some scenario
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SMOKING", 0, true)
    end

    for i = 1, #Config.buyKey do
        -- Request the model
        RequestModel(GetHashKey(Config.buyKey[i].model))
        while not HasModelLoaded(GetHashKey(Config.buyKey[i].model)) do
            Citizen.Wait(0)
        end
        -- Create the ped
        local npc = CreatePed(4, GetHashKey(Config.buyKey[i].model), Config.buyKey[i].npcCoords.x, Config.buyKey[i].npcCoords.y, Config.buyKey[i].npcCoords.z-1, Config.buyKey[i].npcCoords.h, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        -- Make the ped do some scenario
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SMOKING", 0, true)
    end
end

function animationAproach(coords)

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local npcCoords = coords

    while GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, npcCoords.x, npcCoords.y, npcCoords.z, true) > 1.0 do
        TaskGoStraightToCoord(ped, npcCoords.x, npcCoords.y, npcCoords.z, 1.0, 1000, pedHeading, 0.5)
        Citizen.Wait(1)
        pedCoords = GetEntityCoords(ped)
    end

    TaskTurnPedToFaceCoord(ped, npcCoords.x, npcCoords.y, npcCoords.z, 1000)
end

function startMission(mission)
    inMission = 1
    startTimerHud()
    TriggerServerEvent("cokeRun:missionStarted", true)
    
    planeBlip = AddBlipForCoord(mission.spawnPlaneCoords.x, mission.spawnPlaneCoords.y, mission.spawnPlaneCoords.z)
    --SetNewWaypoint(mission.spawnPlaneCoords.x, mission.spawnPlaneCoords.y)

    -- Set a mission waypoint (the yellow one)
    SetBlipRoute(planeBlip, true)

    SetBlipSprite(planeBlip, 423)
    SetBlipDisplay(planeBlip, 2)
    SetBlipColour(planeBlip, 5)
    SetBlipScale(planeBlip, 1.0)
    SetBlipAsShortRange(planeBlip, false)

    Citizen.CreateThread(function()
        while GetDistanceBetweenCoords(mission.spawnPlaneCoords.x, mission.spawnPlaneCoords.y, mission.spawnPlaneCoords.z, GetEntityCoords(PlayerPedId()), true) > 5.0 do
            Citizen.Wait(0)
        end
        RemoveBlip(planeBlip)
        if inMission > 0 then
            inMission = 2
            local propCoords = Config.cokeBrickSpawnLocations[math.random(1, #Config.cokeBrickSpawnLocations)]

            brickProp = CreateObject(GetHashKey(Config.cokeBrickProp), propCoords, true, true, true)
            FreezeEntityPosition(brickProp, false)
        
            G_propCoords = GetEntityCoords(brickProp)
        
            cokeBlip = AddBlipForCoord(G_propCoords)
            SetBlipSprite(cokeBlip, 501)
            SetBlipRoute(cokeBlip, true)
            SetBlipDisplay(cokeBlip, 2)
            SetBlipColour(cokeBlip, 5)
            SetBlipScale(cokeBlip, 1.0)
            SetBlipAsShortRange(cokeBlip, false)
            SetBlipFlashes(cokeBlip, true)
        end
    end)
end


--[[=================================================================================================================
================================                     LOOPS                    =======================================
=================================================================================================================--]]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for i = 1, #Config.buyKey do
            local coords = Config.buyKey[i].npcCoords
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, pedCoords, true)
    
            if distance <= 1.2 and not IsPedInAnyVehicle(ped, false) then
                draw3DText(Config.messages.getKeyText..Config.buyKey[i].price, coords)
                if IsControlJustPressed(0, 38) then
                    ESX.TriggerServerCallback("cokeRun:getBlackMoney", function(blackMoney)
                        if tonumber(blackMoney) >= Config.buyKey[i].price then
                            TriggerServerEvent("cokeRun:removeBlackMoney", Config.buyKey[i].price)
                            animationAproach(coords)
                            ESX.ShowNotification("You paid "..Config.buyKey[i].price.." dirty money for the plane key")
                            TriggerServerEvent("cokeRun:givePlaneKey")
                        else
                            ESX.ShowNotification(Config.messages.notEnoughMoney)
                        end
                    end)
                end
            end
        end
    end
end)


local missionIndex
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inMission == 0 then
            for i = 1, #Config.rentPlane do
                local coords = Config.rentPlane[i].npcCoords
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, pedCoords, true)
    
                if distance <= 1.2 and not IsPedInAnyVehicle(ped, false) then
                    draw3DText(Config.messages.getPlaneText..Config.rentPlane[i].price, coords)
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback("cokeRun:getBlackMoney", function(blackMoney)
                            if tonumber(blackMoney) >= Config.rentPlane[i].price then
                                ESX.TriggerServerCallback("cokeRun:checkIfHasKey", function(hasKey)
                                    if hasKey then
                                        ESX.TriggerServerCallback("cokeRun:getMissionInProgress", function(missionInProgress)
                                            if missionInProgress then
                                                ESX.ShowNotification(Config.messages.missionAlreadyInProgress)
                                                return
                                            else
                                                missionIndex = i
                                                if ESX.Game.IsSpawnPointClear(vector3(Config.rentPlane[missionIndex].spawnPlaneCoords.x, Config.rentPlane[missionIndex].spawnPlaneCoords.y, Config.rentPlane[missionIndex].spawnPlaneCoords.z), 10) then
                                                    TriggerServerEvent("cokeRun:removeBlackMoney", Config.rentPlane[i].price)
                                                    animationAproach(coords)
                                                    ESX.ShowNotification("You paid "..Config.rentPlane[i].price.." dirty money, go to your plane")
                                                    startMission(Config.rentPlane[i])
                                                else
                                                    ESX.ShowNotification(Config.messages.cantSpawnPlane)
                                                    return
                                                end
                                                
                                            end
                                        end)
                                    else
                                        ESX.ShowNotification(Config.messages.planeKeyNeeded)
                                    end
                                end)
                            else
                                ESX.ShowNotification(Config.messages.notEnoughMoney)
                            end
                        end)
                    end
                end
            end
        elseif inMission == 1 then
            if Config.spawnPlaneAutomatically then
                ESX.Game.SpawnVehicle('dodo', vector3(Config.rentPlane[missionIndex].spawnPlaneCoords.x, Config.rentPlane[missionIndex].spawnPlaneCoords.y, Config.rentPlane[missionIndex].spawnPlaneCoords.z), Config.rentPlane[missionIndex].spawnPlaneCoords.h, function(vehicle)
                    SetPedIntoVehicle(ped, vehicle, -1)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                    SetVehicleNeedsToBeHotwired(vehicle, false)
                    SetModelAsNoLongerNeeded(vehicle)
                    SetVehicleDirtLevel(vehicle, 0.0)
                    SetVehicleLivery(vehicle, 0)
                    SetVehicleEngineOn(vehicle, true, true, false)
                    SetVehicleFuelLevel(vehicle, 100.0)

                    -- Task warp ped into vehicle
                    TaskWarpPedIntoVehicle(ped, vehicle, -1)
                end)
                inMission = 1.5
            else
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local distance = GetDistanceBetweenCoords(Config.rentPlane[missionIndex].spawnPlaneCoords.x, Config.rentPlane[missionIndex].spawnPlaneCoords.y, Config.rentPlane[missionIndex].spawnPlaneCoords.z, pedCoords, true)

                if distance <= 5.0 then
                    draw3DText(Config.messages.getPlane, Config.rentPlane[missionIndex].spawnPlaneCoords)
                    if IsControlJustPressed(0, 38) then
                        ESX.Game.SpawnVehicle('dodo', vector3(Config.rentPlane[missionIndex].spawnPlaneCoords.x, Config.rentPlane[missionIndex].spawnPlaneCoords.y, Config.rentPlane[missionIndex].spawnPlaneCoords.z), Config.rentPlane[missionIndex].spawnPlaneCoords.h, function(vehicle)
                            plane = vehicle
                            SetPedIntoVehicle(ped, vehicle, -1)
                            SetEntityAsMissionEntity(vehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                            SetVehicleNeedsToBeHotwired(vehicle, false)
                            SetModelAsNoLongerNeeded(vehicle)
                            SetVehicleDirtLevel(vehicle, 0.0)
                            SetVehicleLivery(vehicle, 0)
                            SetVehicleEngineOn(vehicle, true, true, false)
                            SetVehicleFuelLevel(vehicle, 100.0)
                        
                            -- Task warp ped into vehicle
                            TaskWarpPedIntoVehicle(ped, vehicle, -1)
                        end)
                    end
                end
            end

        elseif inMission == 2 then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            
            if GetDistanceBetweenCoords(pedCoords, G_propCoords, true) <= 6.0 then
                RemoveBlip(cokeBlip)
                draw3DText(Config.messages.collectBrick, G_propCoords)
                if IsControlJustPressed(0, 38) then
                    print("Control pressed")
                    ESX.Progressbar(Config.messages.collectingDrugs, 5000,{
                        onFinish = function()
                            DeleteEntity(brickProp)
                            inMission = 3
                            ESX.ShowNotification(Config.messages.returnPlane)
                            hangarBlip = AddBlipForCoord(Config.returnPlaneCoords[1], Config.returnPlaneCoords[2], Config.returnPlaneCoords[3])
                            SetBlipSprite(hangarBlip, 359)
                            SetBlipRoute(hangarBlip, true)
                            SetBlipDisplay(hangarBlip, 2)
                            SetBlipColour(hangarBlip, 5)
                            SetBlipScale(hangarBlip, 1.0)
                            SetBlipAsShortRange(hangarBlip, false)
                            SetBlipFlashes(hangarBlip, true)
                            while GetDistanceBetweenCoords(Config.returnPlaneCoords, GetEntityCoords(GetVehiclePedIsIn(ped, false)), true) > 6.0 do
                                Citizen.Wait(0)
                            end
                            RemoveBlip(hangarBlip)
                        end
                    })
                end
            end
        elseif inMission == 3 then
            if IsPedInAnyVehicle(PlayerPedId(), false) and GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)) == GetHashKey("dodo") then
                local ped = PlayerPedId()
                local planeCoords = GetEntityCoords(GetVehiclePedIsIn(ped, false))
                local distance = GetDistanceBetweenCoords(Config.returnPlaneCoords, planeCoords, true)
                if distance <= 6.0 then
                    draw3DText(Config.messages.returnPlaneInteraction, planeCoords)
                    if IsControlJustPressed(0, 38) then
                        ESX.ShowNotification("You returned the plane")
                        DeleteEntity(GetVehiclePedIsIn(ped, false))
                        inMission = 3
                        TriggerServerEvent("cokeRun:giveBlackMoney", Config.returnPlanePay, inMission)
                        TriggerServerEvent("cokeRun:giveBrick")
                        inMission = 0
                        TriggerServerEvent("cokeRun:missionStarted", false)
                        API_ProgressBar.remove(bar_TextTimerBar._id)
                    end
                end
            end
        end
    end
end)

--[[=================================================================================================================
================================                     EVENTS                   =======================================
=================================================================================================================--]]


AddEventHandler("esx:playerLoaded", function()
    spawnNPCs()
end)

-- If the resource is started spawnNPCs
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        spawnNPCs()
    end
end)

RegisterNetEvent("cokeRun:packBrick")
AddEventHandler("cokeRun:packBrick", function()
    -- Put a bag prop on the player hand
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local bagProp = CreateObject(GetHashKey("bkr_prop_meth_openbag_01a"), pedCoords, true, true, true)
    AttachEntityToEntity(bagProp, ped, GetPedBoneIndex(ped, 57005), 0.1, 0.0, 0.0, 225.0, 0.0, 0.0, true, true, true, true, 1, true)

    ESX.Progressbar(Config.messages.packing, Config.items.packingSeconds*1000,{
        FreezePlayer = true, 
        animation ={
            type = "Scenario",
            Scenario = "PROP_HUMAN_BUM_BIN", 
        },  
        onFinish = function()
            DeleteEntity(bagProp)
            TriggerServerEvent("cokeRun:finishPacking")
        end
    })
end)

RegisterNetEvent("cokeRun:missionFailed")
AddEventHandler("cokeRun:missionFailed", function()
    inMission = 0
    if DoesEntityExist(brickProp) then
        DeleteEntity(brickProp)
        G_propCoords = nil
    end
    API_ProgressBar.remove(bar_TextTimerBar._id)
    TriggerServerEvent("cokeRun:missionStarted", false)
    ESX.ShowNotification(Config.messages.runOutOfTime)

    if DoesBlipExist(planeBlip) then
        RemoveBlip(planeBlip)
    end
    if DoesBlipExist(cokeBlip) then
        RemoveBlip(cokeBlip)
    end
    if DoesBlipExist(hangarBlip) then
        RemoveBlip(hangarBlip)
    end
end)