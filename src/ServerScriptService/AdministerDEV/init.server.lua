local RunService = game:GetService("RunService")

if (RunService:IsServer()) then
    return require(script.AdministerServer).administrate();
else
    if (script:FindFirstChild("AdministerServer")) then
        script:FindFirstChild("AdministerServer"):Destroy();
    end;
    return require(script.AdministerClient);
end