local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

local function handler(session, protoName, request)
    local data_accessor_service = skynet.queryservice("data_accessor_service")
    assert(request.name)
    assert(request.carrer)

    if request.name == "" then
        return {error="name is null"}
    end

    local x = 0
    local y = 0
    local level = 1
    local hp = 0
    local mp = 0

    local user_id = session:get("user_id")
    local server_id = session:get("server_id")
    assert(user_id)
    assert(server_id)

	local res = skynet.call(data_accessor_service, "lua", "player", "createPlayer",
        user_id, server_id, request.name, x, y, request.carrer,level,0,hp,mp)

    return {error=res.err}
end

return handler