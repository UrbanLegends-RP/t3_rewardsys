local QBCore = exports['qb-core']:GetCoreObject()

-- Function to give Harbor Coins
function GiveHarborCoins(player, amount)
    local Player = QBCore.Functions.GetPlayer(player)
    if Player then
        Player.Functions.AddItem(Config.HarborCoin, amount)
        TriggerClientEvent('QBCore:Notify', player, 'You received ' .. amount .. ' Harbor Coins')
    end
end

-- Event to handle item collection
RegisterServerEvent('t3_rewardsys:collectedItems')
AddEventHandler('t3_rewardsys:collectedItems', function(questId, item, itemCount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        print("Adding item to inventory:", item, itemCount) -- Debugging statement
        local success = Player.Functions.AddItem(item, itemCount)
        if success then
            TriggerClientEvent('t3_rewardsys:collectedItems', src)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to add item to inventory', 'error')
        end
    else
        print("Player not found") -- Debugging statement
    end
end)

-- Event to handle returning items to NPC
RegisterServerEvent('t3_rewardsys:returnItems')
AddEventHandler('t3_rewardsys:returnItems', function(questId, returnItem, returnCount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        print("Removing item from inventory:", returnItem, returnCount) -- Debugging statement
        if Player.Functions.RemoveItem(returnItem, returnCount) then
            local quest = Config.Quests[questId]
            if quest then
                GiveHarborCoins(src, quest.reward)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You do not have the required items', 'error')
        end
    else
        print("Player not found") -- Debugging statement
    end
end)
