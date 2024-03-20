-- Modules
local Signal = require(script.Utils.Signal);

local Administer = {
    setupComplete = Signal.new();
};
Administer.__index = Administer;

function executeModules(parent: Folder): boolean
    for _, module in ipairs(parent:GetChildren()) do
        if (module:IsA("ModuleScript")) then
            local success, returnedModule = pcall(function()
                return require(module);
            end);
            if (not success) then
                warn(returnedModule);
                continue;
            else
                if (not returnedModule.init) then warn(`{module.Name} failed to initialize`) continue; end;
                returnedModule.init();
            end;
        end;
    end;

    Administer.setupComplete:Fire();
    return true;
end;

function Administer.administrate()
    local self = {};
    executeModules(script.Events);

    return setmetatable(self, Administer);
end;

return Administer;
