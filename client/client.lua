local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local radioActive = false
local hunger = 50
local thirst = 50
local oxygen = 0
local hp = 100
local seatbeltOn = false
local speedMultiplier = Config.MPH and 2.23694 or 3.6
local playerLoaded = false
local gear = 1
local directions = {
    N = 360, 0,
    NE = 315,
    E = 270,
    SE = 225,
    S = 180,
    SW = 135,
    W = 90,
    NW = 45,
  }
-- Base Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    PlayerData = QBCore.Functions.GetPlayerData()
    playerLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    playerLoaded = false
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData ~= nil then
        playerLoaded = true
    end
end)

-- Radio

AddEventHandler('pma-voice:radioActive', function(data)
    radioActive = data
end)

-- Needsy

RegisterNetEvent(Config.NeedsUpdate, function(newHunger, newThirst) -- Triggered in qb-core
    hunger = newHunger
    thirst = newThirst
end)

-- Pasy
if Config.OtherTriggerSeatbelt then
    RegisterNetEvent(Config.CustomSeatbeltTrigger, function()
        seatbeltOn = not seatbeltOn
    end)
else
    RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
        seatbeltOn = not seatbeltOn
    end)
end


local prevPlayerStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil , nil }

local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevPlayerStats = data
    if shouldUpdate then
        local activerad = false
        if data[7] ~= 0 then activerad = true else activerad = false end 
        SendNUIMessage({
            action = 'hudtick',
            show = data[1],
            health = data[2],
            armor = data[3],
            thirst = data[4],
            hunger = data[5],
            voice = data[6],
            radio = data[7],
            talking = data[8],
            oxygen = data[9],
            speed = data[10],
            engine = data[11],
            radioActive = activerad,
            isVeh = data[13],
            pid = data[14],
            idlogo = Config.IDLogo,
        })
    end
end

local prevVehicleStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updateVehicleHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevVehicleStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'car',
            showcar = data[1],
            speed = data[2],
            fuel = data[3],
            navigation = data[4],
            streetLabel = data[5],
            gear = data[6],
            isVeh = data[7],
            seatbelt = data[8],
        })
    end
end

local lastFuelUpdate = 0
local lastFuelCheck = {}

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end
    return lastFuelCheck
end

CreateThread(function()
    local wasInVehicle = false
    while true do
        Wait(50)
        if LocalPlayer.state.isLoggedIn then
            
            local crds = GetEntityCoords(GetPlayerPed(-1))
            local pid = GetPlayerServerId(PlayerId())
            local show = true
            local player = PlayerPedId()
            local playerId = PlayerId()
            local weapon = GetSelectedPedWeapon(player)
            local playerhealth = GetEntityHealth(player) - 100
            -- Player hud
            playerDead = IsEntityDead(player) or PlayerData.metadata['inlaststand'] or PlayerData.metadata['isdead'] or false
            --parachute = GetPedParachuteState(player)
            if playerDead then
                playerhealth = 0
            end
            -- Stamina
            if not IsEntityInWater(player) then
                oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId)
            end

            -- Oxygen
            if IsEntityInWater(player) then
                oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
            end

            -- Player hud
            local talking = NetworkIsPlayerTalking(playerId)
            local voice = 0
            if LocalPlayer.state['proximity'] then
                voice = LocalPlayer.state['proximity'].distance
            end
            if IsPauseMenuActive() then
                show = false
            end

            local vehicle = GetVehiclePedIsIn(player)
            if not (IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle)) then
                DisplayRadar(false)
                updatePlayerHud({
                    show,
                    playerhealth,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    oxygen,
                    -1,
                    -1,
                    radioActive,
                    false,
                    pid,
                })
            end

            -- Vehicle hud
            if IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                local coords = GetEntityCoords(player);
                local zone = GetNameOfZone(coords.x, coords.y, coords.z);
        
                local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
                local hash1 = GetStreetNameFromHashKey(var1);
                local hash2 = GetStreetNameFromHashKey(var2);
                local heading = GetEntityHeading(PlayerPedId());
                    
                for k, v in pairs(directions) do
                    if (math.abs(heading - v) < 22.5) then
                        heading = k;
                    
                        if (heading == 1) then
                        heading = 'N';
                        break;
                        end
                
                        break;
                    end
                end

                local street2 = ""
                if (hash2 == '') then
                    street2 = GetLabelText(zone)
                else
                    street2 = hash2..', '..GetLabelText(zone)
                end

                if not wasInVehicle then
                    DisplayRadar(true)
                end
                wasInVehicle = true
                gear = GetVehicleCurrentGear(vehicle)
                if gear == 0 then
                    gear = "R"
                end
                updatePlayerHud({
                    show,
                    GetEntityHealth(player) - 100,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    oxygen,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    (GetVehicleEngineHealth(vehicle) / 10),
                    radioActive,
                    true,
                    pid,
                })
                
                updateVehicleHud({
                    show,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    getFuelLevel(vehicle),
                    heading,
                    hash1,
                    gear,
                    true,
                    seatbeltOn,
                })
            else
                if wasInVehicle then
                    wasInVehicle = false
                    SendNUIMessage({
                        action = 'car',
                        showcar = false,
                    })
                end
                DisplayRadar(false)
            end
        else
            SendNUIMessage({
                action = 'hudtick',
                show = false
            })
        end
    end
end)


-- NUI Callbacks

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)