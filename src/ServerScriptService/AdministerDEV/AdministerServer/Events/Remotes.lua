-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- // Modules
local Utils = require(script.Parent.Parent.Utils);

-- // Types

-- // Initialization
local Remotes = {};

local administerRemotesFolder: Folder = Instance.new("Folder");
administerRemotesFolder.Name, administerRemotesFolder.Parent = "AdministerRemotes", ReplicatedStorage;

local function updateHomePage(player: Player, homePageData: any)
    Utils.isAdmin(player):andThen(function(isAdmin: boolean)
        if (isAdmin) then
            if (next(homePageData) == nil) then return {}; end;

            if (#homePageData.Boxes ~= 2) then
                return {
                    UserFacingMessage = "Bad data was sent, report this or try again.";
                    Result = "fail";
                };
            elseif (#homePageData.SmallLabels > 6) then
                return {
                    UserFacingMessage = "Too many items in your small text feed! Try again later.";
                    Result = "fail";
                };
            end;

            Utils.setAsync(player, homePageData);
        else
            return {
                UserFacingMessage = "Something went wrong.";
                Result = "fail";
		    };
        end;
    end);
end;

function onServerEvent(player: Player, methodType: string, ...: any)
    
end;

function onServerFunction(player: Player, methodType: string, ...: any)
    if (methodType == "") then
        
    elseif (methodType == "GetPasses") then
        return Utils.resolvePasses(player);;
    elseif (methodType == "UpdateHomePage") then
        return updateHomePage(player, { ... });
    end;
    return;
end;

local function createRemote(remoteType: string, name: string, parent: Folder?)
    local remote = Instance.new(remoteType);
    remote.Name = name;
    remote.Parent = parent or administerRemotesFolder;

    return remote;
end

function Remotes.init()
    local self = {
        administerRemoteEvent = createRemote("RemoteEvent", "AdministerRemote");
        administerRemoteFunction = createRemote("RemoteFunction", "AdministerFunction");
    };

    self.administerRemoteEvent.OnServerEvent:Connect(onServerEvent);
    self.administerRemoteFunction.OnServerInvoke = onServerFunction;

    Players.PlayerAdded:Connect(function(player)
        Utils.isAdmin(player):andThen(function(isAdmin)
            warn(isAdmin)
        end)
    end)

    warn(`Remotes initalized`);
    return setmetatable(self, Remotes);
end

return Remotes;
