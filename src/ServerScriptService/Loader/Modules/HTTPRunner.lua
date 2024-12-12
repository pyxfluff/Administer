--// pyxfluff 2024

local Utils = require(script.Parent.Utilities)
local Var = require(script.Parent.Parent.Core.Variables)
local Config = require(script.Parent.Parent.Core.Configuration)

local Http = {}

function Http.GetRoute(AppServer, Route, OnOK, OnError)
	local ST = tick()
	
	local Response = Var.Services.HttpService:RequestAsync({
		Url = `{AppServer}/{Route}`,
		Method = "GET",
		Headers = {
			--// TODO
			["X-Administer-Version"] = "0.0.0"
		}
	})
	
	if Response.StatusCode == 200 then
		OnOK(Var.Services.HttpService:JSONDecode(Response.Body), {
			ProcTime = tick() - ST,
			RespMessage = Response.StatusMessage,
			Code = 200
		})
	else
		OnError(Response.StatusCode)
	end
end

function Http.PostRoute(AppServer, Route, Body, OnOK, OnError)
	local ST = tick()

	local Response = Var.Services.HttpService:RequestAsync({
		Url = `{AppServer}/{Route}`,
		Method = "POST",
		Headers = {
			--// TODO
			["X-Administer-Version"] = "0.0.0"
		},
		Body = Var.Services.HttpService:JSONEncode(Body)
	})

	if Response.StatusCode == 200 then
		OnOK(Var.Services.HttpService:JSONDecode(Response.Body), {
			ProcTime = tick() - ST,
			RespMessage = Response.StatusMessage,
			Code = 200
		})
	else
		OnError(Response.StatusCode)
	end
end

return Http