-- MissionBorrow
-- @goal to provide fieldwork items with your mission machiery that needs to be filled
-- @author GMNGjoy
-- @copyright 11/15/2024
-- @contact https://github.com/GMNGjoy/FS25_ContractBoost
-- @license CC0 1.0 Universal

MissionBorrow = {}
MissionBorrow.pallets = {
    bigBagPallet_fertilizer = true,
    herbicideTank = true,
    bigBagPallet_seeds = true,
}
MissionBorrow.fillMissionTypes = {
    "fertilizeMission",
    "herbicideMission",
    "sowMission",
}
MissionBorrow.palletFilenames = {
    fertilizeMission = 'data/objects/bigBagPallet/fertilizer/bigBagPallet_fertilizer.xml',
    herbicideMission = 'data/objects/pallets/liquidTank/herbicideTank.xml',
    sowMission = 'data/objects/bigBagPallet/seeds/bigBagPallet_seeds.xml',
}

MissionBorrow.fillItemsAdded = false

-- When a "vehicle" is spawned if it's a pallet, ignore the wear and operating time functions.
function MissionBorrow:onSpawnedVehicle(superFunc, vehicle, ...)
    if not g_currentMission.contractBoostSettings.enableFieldworkToolFillItems then
        superFunc(self, vehicle, ...)
    end

    if vehicle ~= nil then
        local configNameClean = vehicle[1].configFileNameClean

        if ContractBoost.debug then
            Logging.info(MOD_NAME..':BORROW :: onSpawnedVehicle %s | isPallet %s', vehicle[1].configFileNameClean, MissionBorrow.pallets[configNameClean] and "yes" or "no")
        end

        if MissionBorrow.pallets[configNameClean] then
            vehicle[1].addWearAmount = function() return true end
            vehicle[1].setOperatingTime = function() return true end
        end

        superFunc(self, vehicle, ...)
    end
end


-- Adds fill items to the mission tools for each type of mission where needed.
function MissionBorrow:addFillItemsToMissionTools()
    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: addFillItemsToMissionTools') end

    if self.fillItemsAdded then
        return
    end

    for _, fillMissionType in pairs(self.fillMissionTypes) do
        if g_missionManager.missionVehicles[fillMissionType] ~= nil then
            for size, vehicles in pairs(g_missionManager.missionVehicles[fillMissionType]) do
                for v, vehicle in pairs(vehicles) do

                    if fillMissionType == 'fertilizeMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })

                        if size ~= "small" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                    elseif fillMissionType == 'herbicideMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })

                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end
                    
                    elseif fillMissionType == 'sowMission' then

                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })
                        table.insert(vehicle.vehicles, {
                            filename = self.palletFilenames[fillMissionType]
                        })
                        if size == "large" then
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                            table.insert(vehicle.vehicles, {
                                filename = self.palletFilenames[fillMissionType]
                            })
                        end

                    end
                end
            end
        end
    end

    -- prevent from being added again
    self.fillItemsAdded = true

    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: addFillItemsToMissionTools complete') end
end



function MissionBorrow:removeFillItemsToMissionTools()
    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: removeFillItemsToMissionTools') end

    if not self.fillItemsAdded then
        return
    end

    for _, fillMissionType in pairs(self.fillMissionTypes) do
        if g_missionManager.missionVehicles[fillMissionType] ~= nil then
            for size, vehicles in pairs(g_missionManager.missionVehicles[fillMissionType]) do
                for v, vehicle in pairs(vehicles) do
                    for v2, spawnVehicle in pairs(vehicle.vehicles) do
                        if spawnVehicle.filename == self.palletFilenames.fertilizeMission or spawnVehicle.filename == self.palletFilenames.herbicideMission or spawnVehicle.filename == self.palletFilenames.sowMission then
                            table.remove(vehicle.vehicles, v2)
                        end
                    end
                end
            end
        end
    end

    -- prevent from being added again
    self.fillItemsAdded = false

    if ContractBoost.debug then Logging.info(MOD_NAME..':BORROW :: removeFillItemsToMissionTools complete') end
end