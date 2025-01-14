--// Administer
--// (pyxfluff + FloofyPlasma) 2024 - 2025

local Root = script:FindFirstAncestor("Loader")
local Types = require(Root.Core.Types)
local Var = require(Root.Core.Variables)
local _Utils = require(Root.Modules.Utilities)

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

function Http.PostRoute(AppServer, Route, Body, OnOK, OnError): Types.Response
	local ST = tick()

	local Response = Var.Services.HttpService:RequestAsync({
		Url = `{AppServer}{Route}`,
		Method = "POST",
		Headers = {
			--// TODO
			["X-Administer-Version"] = "0.0.0",
		},
		Body = Var.Services.HttpService:JSONEncode(Body),
	})

	if Response.StatusCode == 200 then
		return OnOK(Var.Services.HttpService:JSONDecode(Response.Body), {
			ProcTime = tick() - ST,
			RespMessage = Response.StatusMessage,
			Code = 200,
		})
	else
		return OnError(Response.StatusCode)
	end
end

return Http
