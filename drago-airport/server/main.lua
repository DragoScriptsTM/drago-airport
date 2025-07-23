local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

-- Verboden items die niet mee mogen op vlucht
local forbiddenItems = {
    "weedplant_packedweed", "cokebaggy", "coke_brick", "weapon_assaultrifle"
}

-- Check op verboden items
local function HasIllegalItems(player)
    for _, item in ipairs(forbiddenItems) do
        local found = player.Functions.GetItemByName(item)
        if found and found.amount > 0 then
            return true, item
        end
    end
    return false
end

-- Dispatch melding bij illegale spullen op vliegveld
local function AirportDrugDetected(coords)
    local dispatchData = {
        message = "Passagier met verboden middelen op vliegveld.",
        codeName = "airport_drug_detected",
        code = "10-71A",
        icon = "fas fa-plane-departure",
        priority = 2,
        coords = coords,
        jobs = { "leo" }
    }
    TriggerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('AirportDrugDetected', AirportDrugDetected)

-- Ticket kopen event
RegisterNetEvent('drago-airport:buyTicket', function(destination, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Cooldown van 8 minuten
    local lastFly = cooldowns[src]
    local now = os.time()
    if lastFly and (now - lastFly) < 480 then
        local waitTime = 480 - (now - lastFly)
        TriggerClientEvent('QBCore:Notify', src, 'Je kunt pas over ' .. waitTime .. ' seconden weer vliegen.', 'error')
        return
    end

    -- Check bestemming geldig
    local config = Config.Airports[destination]
    if not config then
        TriggerClientEvent('QBCore:Notify', src, 'Ongeldige bestemming.', 'error')
        return
    end

    -- Zoek vluchtprijs
    local price = nil
    for _, airport in pairs(Config.Airports) do
        for _, flight in pairs(airport.flights) do
            if flight.to == destination then
                price = flight.price
                break
            end
        end
        if price then break end
    end

    if not price then
        TriggerClientEvent('QBCore:Notify', src, 'Kan prijs niet vinden.', 'error')
        return
    end

    -- Check op illegale spullen
    local hasIllegal, itemName = HasIllegalItems(Player)
    if hasIllegal then
        AirportDrugDetected(coords or Player.PlayerData.position)
        TriggerClientEvent('QBCore:Notify', src, 'Je hebt verboden spullen bij je. De politie is gewaarschuwd.', 'error')
        return
    end

    -- Betalen en ticket accepteren
    if Player.Functions.RemoveMoney('bank', price) then
        cooldowns[src] = now
        TriggerClientEvent('drago-airport:ticketAccepted', src, destination)
        TriggerClientEvent('QBCore:Notify', src, 'Ticket gekocht voor €' .. price, 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Je hebt niet genoeg geld op je bank.', 'error')
    end
end)
