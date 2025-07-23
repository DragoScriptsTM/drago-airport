local QBCore = exports['qb-core']:GetCoreObject()
local inAirportMenu = false

-- Menu openen via ped of target
RegisterNetEvent('drago-airport:openMenu', function(airportKey)
    if inAirportMenu then return end
    inAirportMenu = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', airport = airportKey })
end)

-- Menu sluiten vanuit NUI
RegisterNUICallback('close', function(_, cb)
    if not inAirportMenu then cb(true) return end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    inAirportMenu = false
    cb(true)
end)

-- Vlucht selecteren en ticket kopen
RegisterNUICallback('selectFlight', function(data, cb)
    if not data.to then cb(false) return end

    -- Pak coords van speler mee voor dispatch melding
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Stuur event met bestemming en coords naar server
    TriggerServerEvent('drago-airport:buyTicket', data.to, coords)

    cb(true)
end)

-- Teleporteren na goedkeuring server
RegisterNetEvent('drago-airport:ticketAccepted', function(destination)
    local target = Config.Airports[destination]
    if not target then return end

    DoScreenFadeOut(1000)
    Wait(1500)

    local teleportCoords = target.exitCoords or target.coords
    SetEntityCoords(PlayerPedId(), teleportCoords.x, teleportCoords.y, teleportCoords.z)
    Wait(1000)
    DoScreenFadeIn(1000)

    -- Sluit menu netjes af
    if inAirportMenu then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })
        inAirportMenu = false
    end
end)

-- Vlucht geweigerd (bijv. illegale items)
RegisterNetEvent('drago-airport:flightDenied', function(reason)
    if inAirportMenu then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })
        inAirportMenu = false
    end
    if reason then
        QBCore.Functions.Notify(reason, 'error')
    end
end)

-- qb-target voor vaste locatie (zoals LSIA)
CreateThread(function()
    local lsia = Config.Airports["lsia"]
    if lsia then
        exports['qb-target']:AddBoxZone("airport_menu_lsia", lsia.coords, 2, 2, {
            name = "airport_lsia",
            heading = 0,
            debugPoly = false,
            minZ = lsia.coords.z - 1,
            maxZ = lsia.coords.z + 1,
        }, {
            options = {
                {
                    label = "Bekijk vluchten",
                    icon = "fas fa-plane-departure",
                    action = function()
                        TriggerEvent('drago-airport:openMenu', "lsia")
                    end
                }
            },
            distance = 2.0
        })
    end
end)

-- Spawn airport peds + interactie via qb-target
CreateThread(function()
    for id, airport in pairs(Config.Airports) do
        RequestModel(airport.ped.model)
        while not HasModelLoaded(airport.ped.model) do Wait(0) end

        local ped = CreatePed(0, airport.ped.model, airport.coords.x, airport.coords.y, airport.coords.z - 1, airport.ped.heading, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    label = "Bekijk vluchten",
                    icon = "fas fa-plane-departure",
                    action = function()
                        TriggerEvent('drago-airport:openMenu', id)
                    end
                }
            },
            distance = 2.5
        })
    end
end)

-- Blips voor alle airports
CreateThread(function()
    for _, airport in pairs(Config.Airports) do
        local blip = AddBlipForCoord(airport.coords.x, airport.coords.y, airport.coords.z)
        SetBlipSprite(blip, 90)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 41)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(airport.label)
        EndTextCommandSetBlipName(blip)
    end
end)
