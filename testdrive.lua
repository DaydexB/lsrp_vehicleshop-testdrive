local mapper = require('shared.modules.configMapper')
local testdrive = {}

local function teleportPlayerIntoVehicle(vehicle)
    local playerPed = PlayerPedId()
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end

testdrive.initiate = function(shopIndex, selected, scrollIndex, testOptions)
    local CFG_VEH_DATA = mapper.getVehicle(shopIndex, selected, scrollIndex)
    local CFG_SHOP_DATA = mapper.getShop(shopIndex)
    if lib.alertDialog({
        header = ('%s - %s'):format(CFG_SHOP_DATA.SHOP_LABEL, locale('testdrive')),
        content = ('You are about to test drive %s at %s'):format(CFG_VEH_DATA.label, testOptions[1]),
        centered = true,
        cancel = true
    }) == 'confirm' then
        local vehicleModel = CFG_VEH_DATA.VEHICLE_MODEL
        local coords = Config.TestDriveSpawnVehicleLocation
        local heading = Config.TestDriveSpawnHeading
        local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, heading, true, false)
        if vehicle ~= 0 then
            teleportPlayerIntoVehicle(vehicle)
            testdrive.startTestDrive(vehicle)
            return true
        else
            ESX.ShowNotification('Failed to create vehicle!')
            return false
        end
    else
        return false
    end
end

function testdrive.startTestDrive(vehicle)
    local ped = PlayerPedId()
    SetEntityVisible(ped, true)
    local coords = Config.TestDriveFinishedLocation
    local heading = Config.TestDriveFinishedHeading
    local duration = Config.TestDriveTime

    Citizen.CreateThread(function()
        while duration > 0 do
            Citizen.Wait(100)
            duration = duration - 0.1 
        end
        DisableControlAction(1, 23, true)
        if duration <= 0 then
            DeleteEntity(vehicle)
            SetEntityCoords(ped, coords.x, coords.y, coords.z, true, false, false, false)
        end
    end)
end

return testdrive
