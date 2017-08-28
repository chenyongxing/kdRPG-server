local skynet = require "skynet"

local function handler(session, protoName, request)
    local data_accessor_service = skynet.queryservice("data_accessor_service")

	local userInfo = skynet.call(data_accessor_service, "lua", "user", "getUser", request.name, request.password)
	assert(userInfo.id)
	
	local player = skynet.call(data_accessor_service, "lua", "player", "getPlayer", userInfo.id, ServerID)
	return {player=player}, userInfo.id
end

return handler