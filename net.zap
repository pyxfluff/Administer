opt server_output = "src/Server/Core/Libraries/Networking.luau"
opt client_output = "src/Client/Client/Libraries/Networking.luau"

type StatusCode = enum {
    Success, Failure
}

funct SendLocale = {
    call: Async,
    args: (Locale: string),
    rets: (struct {
        StatusCode: StatusCode,
        Message: string
    })
}

funct Ping = {
    call: Async,
    args: (),
    rets: (string)
}
