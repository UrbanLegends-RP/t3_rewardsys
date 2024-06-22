-- Configuration File for t3_rewardsys
Config = {}

-- Harbor Coin Item Name
Config.HarborCoin = "harbor_coin"

-- NPC Configuration
Config.NPC = {
    model = "a_m_y_business_01", -- NPC model
    location = vector3(63.95, 7198.45, 2.98) -- NPC location
}

-- Quests Configuration
Config.Quests = {
    {
        id = 1,
        name = "Collect 10 Seeds",
        description = "Collect 10 seeds around town.",
        reward = 5, -- Harbor Coins
        type = "collect",
        targetItem = "drug_lsd",
        targetCount = 10,
        collectionLocation = vector3(66.98, 7195.61, 1.65),
        npcLocation = Config.NPC.location,
        returnItem = "drug_lsd", -- Item to be returned to the NPC
        returnCount = 5 -- Number of items to be returned to receive the reward
    },
    {
        id = 2,
        name = "Deliver Package",
        description = "Deliver the package to the specified location.",
        reward = 10, -- Harbor Coins
        type = "delivery",
        packageItem = "package",
        collectionLocation = vector3(321.4, 654.7, 987.0),
        npcLocation = Config.NPC.location,
        returnItem = "drug_lsd",
        returnCount = 3
    }
    -- Add more quests as needed
}
