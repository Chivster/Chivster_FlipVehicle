RegisterNetEvent('rrp_vehicleflip:attemptFlip', function(netVeh)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if not DoesEntityExist(veh) then return end

    local ped = GetPlayerPed(src)
    if #(GetEntityCoords(ped) - GetEntityCoords(veh)) > 5.0 then return end

    SetEntityRotation(veh, 0.0, 0.0, GetEntityHeading(veh), 2, true)
    Wait(100)
    SetVehicleOnGroundProperly(veh)
end)
