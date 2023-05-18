local QBCore = exports['qb-core']:GetCoreObject()

local pedSpawn = false

local function buyoutMenu(officer, citizen, vehicle, plate, price, impoundTime)

    local buyoutMenu = {{
        --header = "Impounded by",
        header = Lang:t("menu.buyout_iby"),
        txt = officer,
        isMenuHeader = true
    }, {
        --header = "Owned by",
        header = Lang:t("menu.buyout_oby"),
        txt = citizen,
        isMenuHeader = true
    }, {
        --header = "Vehicle",
        header = Lang:t("menu.buyout_veh"),
        txt = vehicle,
        isMenuHeader = true
    }, {
        --header = "Plate",
        header = Lang:t("menu.buyout_plate"),
        txt = plate,
        isMenuHeader = true
    }, {
        --header = "Buyout price",
        header = Lang:t("menu.buyout_boprice"),
        txt = price,
        isMenuHeader = true
    }, {
        --header = "Impound time",
        header = Lang:t("menu.buyout_time"),
        --txt = impoundTime .. " minutes",
        txt = Lang:t("menu.buyout_itime", {itime = impoundTime}),
        isMenuHeader = true
    }, {
        --header = "Un-impound",
        header = Lang:t("menu.buyout_uni"),
        --txt = "Un-impound impounded vehicle!",
        txt = Lang:t("menu.buyout_uni_txt"),
        params = {
            event = "cx-impound:client:buyoutVehicle"
        }
    }, {
        --header = "⬅ Back",
        header = Lang:t("menu.menu_back"),
        txt = "",
        params = {
            event = "qb-menu:closeMenu"
        }
    }}

    exports['qb-menu']:openMenu(buyoutMenu)
end

local function impoundedVehicles(vehicles)
    local allVehicles = {{
        --header = "Impounded Vehicles",
        header = Lang:t("info.menu_label"),
        isMenuHeader = true
    }}

    if vehicles ~= nil and vehicles then
        for _, v in pairs(vehicles) do
            --print(QBCore.Shared.Vehicles[v.vehicle].name .. " " .. QBCore.Shared.Vehicles[v.vehicle].brand .. "\n\n\n")
            table.insert(allVehicles, {
                header = QBCore.Shared.Vehicles[v.vehicle].name .. " " .. QBCore.Shared.Vehicles[v.vehicle].brand,
                txt = v.plate,
                params = {
                    isServer = true,
                    event = "cx-impound:server:menuBuyOut",
                    args = {
                        plate = v.plate,
                    }
                }
            })
        end
    end

    allVehicles[#allVehicles + 1] = {
        --header = "⬅ Back",
        header = Lang:t("menu.menu_back"),
        txt = "",
        params = {
            event = "qb-menu:closeMenu"
        }
    }

    exports['qb-menu']:openMenu(allVehicles)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()

    TriggerServerEvent('cx-impound:server:spawnVehicles')

    Wait(1000)
    if not pedSpawn then
        exports['qb-target']:SpawnPed({
            model = 'cs_casey',
            coords = Config.PedLocation,
            minusOne = true,
            freeze = true,
            invincible = true,
            blockevents = true,
            animDict = 'abigail_mcs_1_concat-0',
            anim = 'csb_abigail_dual-0',
            flag = 1,
            scenario = 'WORLD_HUMAN_AA_COFFEE',
            target = {
                options = {{
                    type = "server",
                    event = "cx-impound:server:impoundedVehicles",
                    icon = 'fas fa-car',
                    --label = 'Impounded Vehicles'
                    label = Lang:t("info.ped_label")
                }},
                distance = 2.5
            }
        })
        pedSpawn = true
        Citizen.Trace("Ped Spawnato dal OnPlayerLoaded \n")
    end
end)

RegisterNetEvent('cx-impound:client:impoundedVehicles', function(vehicles)
    impoundedVehicles(vehicles)
end)

RegisterNetEvent('cx-impound:client:checkVehicle', function()
    local closestVehicle = QBCore.Functions.GetClosestVehicle();
    local vehicleHash = GetEntityModel(closestVehicle)
    local modelName = string.lower(GetDisplayNameFromVehicleModel(vehicleHash))
    local plate = GetVehicleNumberPlateText(closestVehicle)
    local vehicle = QBCore.Shared.Vehicles[modelName]

    if vehicle ~= 0 and vehicle then
        local player = PlayerPedId()
        local playerPos = GetEntityCoords(player)
        local vehiclePos = GetEntityCoords(closestVehicle)
        if #(playerPos - vehiclePos) < 3.0 and not IsPedInAnyVehicle(player) then
            TriggerServerEvent('cx-impound:server:checkVehicle', vehicle, plate)
        else
            --TriggerEvent('DoLongHudText',
            --    "You are not allowed to be in vehicle or maybe there is no vehicle close to you!", 2)
            TriggerEvent('QBCore:Notify', Lang:t("error.no_veh"), "error")
        end
    end
end)

RegisterNetEvent('cx-impound:client:impoundVehicle', function(vehicle, hash, plate, depot_price)
    local dialog = exports['qb-input']:ShowInput({
        --header = "Impound Vehicle",
        header = Lang:t("menu.input_header"),
        --submitText = "Submit",
        submitText = Lang:t("menu.input_submit"),
        inputs = {{
            type = 'number',
            isRequired = true,
            name = 'impoundTime',
            --text = 'Impound time in minutes.'
            text = Lang:t("menu.input_time_txt")
        }, {
            type = 'number',
            isRequired = true,
            name = 'depotPrice',
            --text = 'Depot price without decimals.'
            text = Lang:t("menu.input_dprice_txt")
        }}
    })
    if dialog then
        if not dialog then
            return
        end
        local closestVehicle = QBCore.Functions.GetClosestVehicle()
        QBCore.Functions.DeleteVehicle(closestVehicle)
        Wait(2000)
        TriggerServerEvent('cx-impound:server:impoundVehicle', vehicle, hash, plate, dialog.depotPrice,
            dialog.impoundTime)
    end
end)

RegisterNetEvent('cx-impound:client:setVehProperties', function(net, vehicleData)
    local veh = NetworkGetEntityFromNetworkId(net)
    QBCore.Functions.SetVehicleProperties(veh, vehicleData.mods)

    SetEntityCanBeDamaged(veh, false)
    SetEntityInvincible(veh, true)
    FreezeEntityPosition(veh, true)
    SetVehicleDoorsLocked(veh, 2)
    SetVehicleNumberPlateText(veh, vehicleData.plate)
    SetVehicleOnGroundProperly(veh)
end)

RegisterNetEvent('cx-impound:client:buyoutVehicle', function()
    local closestVehicle = QBCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(closestVehicle)
    local closestPlayer, distance = QBCore.Functions.GetClosestPlayer()
    Citizen.Trace("client:buyoutVehicle plate: " .. tostring(plate) .. " closePl: " .. tostring(closestPlayer) .. "\n")

    if (distance ~= -1 and distance < 3.0) then
        Citizen.Trace("chiamta a cx-impound:server:buyoutVehicle \n")
        TriggerServerEvent('cx-impound:server:buyoutVehicle', plate, GetPlayerServerId(closestPlayer))
    else
        --TriggerEvent('DoLongHudText', "There are no citizens near by!", 2)
        TriggerEvent('QBCore:Notify', Lang:t("error.no_cid"), "error")
    end
end)

RegisterNetEvent('cx-impound:client:buyOutData', function()
    local closestVehicle = QBCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(closestVehicle)

    TriggerServerEvent('cx-impound:server:buyOutData', plate)
end)

RegisterNetEvent('cx-impound:client:openMenu', function(officer, owner, vehicle, plate, buyOutPrice, impoundTime)
    buyoutMenu(officer, owner, vehicle, plate, buyOutPrice, impoundTime)
end)

RegisterNetEvent('cx-impound:client:successfulBuyout', function(vehPlate)
    for k, v in pairs(Config.VehicleSpawns) do
        local closestVeh = GetClosestVehicle(v.x, v.y, v.z, 2.5, 0, 70)
        local plate = QBCore.Functions.GetPlate(closestVeh)
        if plate == vehPlate then
            SetEntityCanBeDamaged(closestVeh, true)
            SetEntityInvincible(closestVeh, false)
            FreezeEntityPosition(closestVeh, false)
            TriggerServerEvent('cx-impound:server:spawnVehicles', k)
            break
        end
    end
end)

-- adds keys to target player
RegisterNetEvent('cx-impound:client:addKeys', function(vehPlate)
    for _, v in pairs(Config.VehicleSpawns) do
        local closestVeh = GetClosestVehicle(v.x, v.y, v.z, 2.5, 0, 70)
        local plate = QBCore.Functions.GetPlate(closestVeh)
        if plate == vehPlate then
            --TriggerEvent("keys:addNew", plate)
            TriggerServerEvent("cx-impound:server:addKeys", plate)
            break
        end
    end
end)

-- Thread
CreateThread(function()
    if not pedSpawn then
        exports['qb-target']:SpawnPed({
            model = 'cs_casey',
            coords = Config.PedLocation,
            minusOne = true,
            freeze = true,
            invincible = true,
            blockevents = true,
            animDict = 'abigail_mcs_1_concat-0',
            anim = 'csb_abigail_dual-0',
            flag = 1,
            scenario = 'WORLD_HUMAN_AA_COFFEE',
            target = {
                options = {{
                    type = "server",
                    event = "cx-impound:server:impoundedVehicles",
                    icon = 'fas fa-car',
                    --label = 'Impounded Vehicles'
                    label = Lang:t("info.ped_label")
                }},
                distance = 2.5
            }
        })
        pedSpawn = true
        Citizen.Trace("Ped Spawnato dal Thread \n")
    end
end)