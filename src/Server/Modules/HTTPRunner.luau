--// Administer
--// (pyxfluff + FloofyPlasma) 2024 - 2025

local Root = script:FindFirstAncestor("Loader")
local Types = require(Root.Core.Types)
local Var = require(Root.Core.Variables)
local Config = require(Root.Core.Configuration)

local Http = {}

function Http.GetRoute(AppServer, Route, OnOK, OnError): Types.Response
	local ST = tick()

	local Response = Var.Services.HttpService:RequestAsync({
		Url = `{AppServer}{Route}`,
		Method = "GET",
		Headers = {
			--// TODO
			["X-Administer-Version"] = "0.0.0",
		},
	})

	if Response.StatusCode == 200 then
		return OnOK(Var.Services.HttpService:JSONDecode(Response.Body), {
			ProcTime = tick() - ST,
			RespMessage = Response.StatusMessage,
			Code = 200,
		})
	else
		--// Proposed
		--if AppServer == "https://administer.notpyx.me" then
		--	return Http.GetRoute("https://administer-bk2.notpyx.me", Route, OnOK, OnError)
		--end

		return OnError(Response.StatusCode)
	end
end

--<strong>WARNING: THIS DOES NOT ACTUALLY RETURN A { Response }, IT JUST SAYS THAT TO NOT HAVE THE TYPESOLVER COMPLAIN!</strong>
-- For more information on this API, please refer to the documentation: https://docs.administer.notpyx.me
function Http.PostRoute(
    AppServer: string,
    Route: string, 
    Body: {},
    OnOK: (any, {ProcTime: number, RespMessage: string, Code: number}) -> (any),
    OnError: (any) -> (any),
    MiscConfig: nil | {Headers: {}},
    DoAnyways: nil | (any) -> (any)
): Types.Response
	local ST = tick()
    local FinalHeaders = {}

    if MiscConfig ~= nil then
        for Key, Header in MiscConfig.Headers do
            FinalHeaders[Key] = Header
        end
    else
        FinalHeaders = {["X-Administer-Version"] = Config.VersData.String}
    end

	local Response = Var.Services.HttpService:RequestAsync({
		Url = `{AppServer}{Route}`,
		Method = "POST",
		Headers = FinalHeaders,
		Body = Var.Services.HttpService:JSONEncode(Body),
	})

    if DoAnyways ~= nil then
        DoAnyways(Response)
    end

	if string.sub(tostring(Response.StatusCode), 0, 1) == '2' then
		return OnOK(Var.Services.HttpService:JSONDecode(Response.Body), {
			ProcTime = tick() - ST,
			RespMessage = Response.StatusMessage,
			Code = Response.StatusMessage,
		})
	else
		return OnError(Response.StatusCode :: number)
	end
end

return Http
