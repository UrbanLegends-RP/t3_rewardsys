local QBCore = exports['qb-core']:GetCoreObject()
local currentBlip = nil
local target = exports['qb-target']
local npcPed = nil

-- Function to display the quest menu
function OpenQuestMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        quests = Config.Quests
    })
end

-- Function to start a quest
function StartQuest(quest)
    QBCore.Functions.Notify('You started the quest: ' .. quest.name)
    SetQuestBlip(quest.collectionLocation)
    SetQuestTarget(quest, quest.collectionLocation)
end

-- Function to set a blip for the quest location
function SetQuestBlip(location)
    if currentBlip then
        RemoveBlip(currentBlip)
    end
    currentBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(currentBlip, 1)
    SetBlipDisplay(currentBlip, 4)
    SetBlipScale(currentBlip, 1.0)
    SetBlipColour(currentBlip, 5)
    SetBlipAsShortRange(currentBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Quest Location")
    EndTextCommandSetBlipName(currentBlip)
end

-- Function to set up the qb-target area for the quest location
function SetQuestTarget(quest, location)
    local zoneName = "questLocation" .. quest.id
    target:AddBoxZone(zoneName, location, 1.0, 1.0, {
        name = zoneName,
        heading = 0,
        debugPoly = false,
        minZ = location.z - 1,
        maxZ = location.z + 1
    }, {
        options = {
            {
                action = function(entity)
                    InteractQuest(quest)
                end,
                icon = 'fas fa-hand-paper',
                label = 'Collect ' .. quest.targetItem
            }
        },
        distance = 2.0
    })
end

-- Function to handle quest interaction
function InteractQuest(quest)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if quest.type == "collect" then
        if Vdist(playerCoords, quest.collectionLocation.x, quest.collectionLocation.y, quest.collectionLocation.z) < 2.0 then
            QBCore.Functions.Progressbar("collecting_items", "Collecting Items...", 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                print("Collected items:", quest.targetItem, quest.targetCount) -- Debugging statement
                TriggerServerEvent('t3_rewardsys:collectedItems', quest.id, quest.targetItem, quest.targetCount)
                SetQuestBlip(quest.npcLocation)
                target:RemoveZone("questLocation" .. quest.id)
                SetNPCTarget(quest)
            end, function() -- Cancel
                QBCore.Functions.Notify("You canceled the quest", "error")
            end)
        end
    end
end

-- Function to set up the qb-target area for the NPC
function SetNPCTarget(quest)
    local zoneName = "npcLocation" .. quest.id
    target:AddTargetEntity(npcPed, {
        options = {
            {
                action = function(entity)
                    ReturnItemsToNPC(quest)
                end,
                icon = 'fas fa-hand-paper',
                label = 'Return Items'
            }
        },
        distance = 2.0
    })
end

-- Function to return items to the NPC
function ReturnItemsToNPC(quest)
    TriggerServerEvent('t3_rewardsys:returnItems', quest.id, quest.returnItem, quest.returnCount)
    QBCore.Functions.Notify('You returned the items to the NPC')
    RemoveBlip(currentBlip)
    target:RemoveZone("npcLocation" .. quest.id)
end

-- Function to spawn the NPC
function SpawnNPC()
    local hash = GetHashKey(Config.NPC.model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end
    npcPed = CreatePed(4, hash, Config.NPC.location.x, Config.NPC.location.y, Config.NPC.location.z, 0.0, false, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    FreezeEntityPosition(npcPed, true) -- Ensure the NPC does not move
    SetNPCTarget({ id = 0 }) -- Initialize the NPC target zone
end

-- Event to handle quest collection
RegisterNetEvent('t3_rewardsys:collectedItems')
AddEventHandler('t3_rewardsys:collectedItems', function()
    QBCore.Functions.Notify('You collected the items, return to the NPC')
end)

-- Register a command to open the quest menu
RegisterCommand('rewardmenu', function()
    OpenQuestMenu()
end)

-- NUI callback to start a quest
RegisterNUICallback('startQuest', function(data, cb)
    StartQuest(data.quest)
    cb('ok')
end)

-- NUI callback to close the menu
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({type = 'close'})
    cb('ok')
end)

-- Spawn the NPC on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SpawnNPC()
    end
end)
