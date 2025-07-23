local function AirportDrugDetected()
    local coords = GetEntityCoords(cache.ped)

    local dispatchData = {
        message = locale('airport_drug_detected'),  -- Add to locale in your language
        codeName = 'airport_drug_detected',         
        code = '10-71A',                            
        icon = 'fas fa-plane-departure',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
        heading = GetPlayerHeading(),
        jobs = { 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('AirportDrugDetected', AirportDrugDetected)