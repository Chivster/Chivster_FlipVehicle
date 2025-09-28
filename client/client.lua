local bl_ui = exports.bl_ui

local function IsVehicleUpsideDown(vehicle)
    return IsEntityUpsidedown(vehicle)
end

exports.ox_target:addGlobalVehicle({
    label = 'Flip Vehicle',
    icon = 'fa-solid fa-screwdriver-wrench',
    distance = 2.5,
    canInteract = function(entity, distance, coords, name, bone)
        if not IsEntityAVehicle(entity) then return false end
        if not IsVehicleUpsideDown(entity) then return false end
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) > 3.0 then return false end
        return true
    end,
    onSelect = function(data)
        local ped = PlayerPedId()
        local veh = data.entity
        local playerCoords = GetEntityCoords(ped)
        local vehicleCoords = GetEntityCoords(veh)

        if not IsVehicleUpsideDown(veh) then return end

        local dir = GetEntityForwardVector(veh)
        local toPlayer = playerCoords - vehicleCoords
        local sideDot = math.abs(dir.x * toPlayer.x + dir.y * toPlayer.y)
        if sideDot > 2.0 then
            lib.notify({
                description = "You need to position yourself better to flip the vehicle.",
                type = "error",
                position = "center-right"
            })
            return
        end

        local model = GetEntityModel(veh)
        local minDim, maxDim = GetModelDimensions(model)
        local vehClass = GetVehicleClass(veh)

        if (maxDim.x - minDim.x > 3.5 or maxDim.y - minDim.y > 7.0) or
           (vehClass == 15 or vehClass == 16 or vehClass == 19 or vehClass == 20 or vehClass == 21) then
            lib.notify({
                description = "This vehicle is too large or cannot be flipped manually.",
                type = "error",
                position = "center-right"
            })
            return
        end

        LocalPlayer.state.invBusy = true
        LocalPlayer.state.invHotkeys = false

        local dict = "missfinale_c2ig_11"
        local anim = "pushcar_offcliff_f"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)

        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.2)

        local timeout = false
        local cancelThread = CreateThread(function()
            Wait(20000)
            timeout = true
            ClearPedTasks(ped)
            StopGameplayCamShaking(true)
            LocalPlayer.state.invBusy = false
            LocalPlayer.state.invHotkeys = true
        end)

        local passed = bl_ui:KeySpam(5, 75)

        ClearPedTasks(ped)
        StopGameplayCamShaking(true)
        LocalPlayer.state.invBusy = false
        LocalPlayer.state.invHotkeys = true

        if not timeout then
            TerminateThread(cancelThread)
        end

        if not passed then
            lib.notify({
                description = "You struggled and failed to push the vehicle over.",
                type = "error",
                position = "center-right"
            })
            return
        end

        lib.notify({
            description = "With a burst of effort, you manage to push the vehicle upright.",
            type = "success",
            position = "center-right"
        })

        TriggerServerEvent('rrp_vehicleflip:attemptFlip', VehToNet(veh))
    end
})

-- RegisterCommand("spawnflipped", function()
--     local model = `blista`
--     RequestModel(model)
--     while not HasModelLoaded(model) do Wait(0) end

--     local player = PlayerPedId()
--     local coords = GetEntityCoords(player)
--     local forward = GetEntityForwardVector(player)
--     local spawnPos = coords + forward * 5.0

--     local vehicle = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z + 1.5, 0.0, true, false)
--     SetVehicleOnGroundProperly(vehicle)
--     FreezeEntityPosition(vehicle, true)
--     Wait(250)
--     SetEntityRotation(vehicle, 180.0, 0.0, GetEntityHeading(vehicle), 2, true)
--     FreezeEntityPosition(vehicle, false)

--     SetModelAsNoLongerNeeded(model)

--     lib.notify({
--         title = "Test Vehicle",
--         description = "A flipped vehicle has been spawned for testing.",
--         type = "inform",
--         position = "center-right"
--     })
-- end, false)
