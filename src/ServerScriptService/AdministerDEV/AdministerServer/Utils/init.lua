local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- // Modules
local Promise = require(script.Promise);
local Admins = require(script.Parent.Admins);
local DatastoreManager = require(script.DatastoreManager);

-- // Constants
local Utils = {};

local function IsAdmin(player: Player)
    return Promise.new(function(r, rej)
        -- // Check if they were server set
        if (table.find(Admins.InGameAdmins, player)) then
            r(true);
        end;

        -- // Check if they were set dynamically
        for _, ID in ipairs(Admins.Admins) do
            if (player.UserId == ID) then r(true); end;
        end;

        for groupId, groupRank in ipairs(Admins.Groups) do
            groupId = (groupId > 999) and groupId or nil;
            if (groupId and groupRank) then
                if (player:IsInGroup(groupId) and player:GetRankInGroup(groupId) >= groupRank) then
                    r(true);
                end;
            else
                if (player:IsInGroup(groupId)) then r(true); end;
            end;
        end;

        r(false);
    end);
end;

local function ResolvePasses(_player: Player)
    local attempts, content = 0, "";

    return Promise.new(function(r, rej)
        repeat
            local success, err = pcall(function()
                attempts += 1;
                content = HttpService:GetAsync(`https://rblxproxy.darkpixlz.com/games/v1/games/3331848462/game-passes?sortOrder=Asc&limit=50`, true);
            end);
        until success or attempts > 5;

        if (content) then r(content) else
            local decodedData = HttpService:JSONDecode({
                data = {
                    {
                        price = "Failed to load passes";
                        id = 0;
                    };
                };
            });
            r(decodedData);
        end;
    end);
end;

Utils.resolvePasses = function(player: Player)
    return ResolvePasses(player);
end;

Utils.setAsync = function(player: Player, ...: any) -- legacy | DatastoreManager
    return DatastoreManager.saveHomeScreen(player, ...);
end;

Utils.isAdmin = function(player: Player)
    return IsAdmin(player);
end;

return Utils;
