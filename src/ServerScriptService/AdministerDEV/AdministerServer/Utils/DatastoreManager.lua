-- // Services
local DataStoreService = game:GetService("DataStoreService");

-- // Datastores
local homeScreenDatastore = DataStoreService:GetDataStore("Administer_HomeScreenStore");

local DatastoreManager = {};
DatastoreManager.__index = DatastoreManager;

function DatastoreManager.saveHomeScreen(player: Player, homeScreenData: any)
    local success, err = pcall(function()
        return homeScreenDatastore:SetAsync(player.UserId, homeScreenData);
    end);
    if (not success) then
        warn(`[AdministerUtils]: Failed to Save Data for {player}`, err);
    end;
    warn('[DatastoreManager]: Data saved successfully');
end;

return DatastoreManager;
