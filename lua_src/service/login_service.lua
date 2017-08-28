local skynet = require "skynet"
require("utils.utils")

local args = table.pack(...)
local data_accessor_service = args[1]

function createUser(request)
    skynet.call(data_accessor_service, "lua", "user", "createUser", request.name, request.password)
end

function getUser(request)  
    return skynet.call(data_accessor_service, "lua", "user", "getUser", request.name, request.password)
end

function auth(request)
    return true
end

skynet.start(function ()
	skynet.dispatch("lua", function(session, source, cmd, ...)
        local ret = _G[cmd](...)
		skynet.ret(skynet.pack(ret))
	end)
end)
