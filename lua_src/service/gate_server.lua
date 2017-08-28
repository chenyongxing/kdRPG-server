local skynet = require "skynet"
local socket = require "skynet.socket"
local sharedata = require "skynet.sharedata"
local sprotoloader = require "sprotoloader"

require("utils.utils")

local args = table.pack(...)
local login_service = args[1]
local data_accessor_service = args[2]

local protoHandler

--负载均衡，轮询分配不同服
local loginCount = 0
local function autoGetGameServer()
    loginCount = loginCount + 1
	
	local game_servers = sharedata.query("server_config").game_server
    local gameServerCount = 0
	for k, v in pairs(game_servers) do
		gameServerCount = gameServerCount + 1
	end

	local index = loginCount % gameServerCount
	
    if loginCount % gameServerCount == 0 then
		index = gameServerCount
    end
    
	local tempCount = 0
	for k, v in pairs(game_servers) do
		tempCount = tempCount + 1
		if tempCount == index then
			return game_servers[k]
		end
	end
end

--返回true，断开连接
local function messageHandle(socketId, protoName, request, response)
	if protoName == "get_servers" then
        --没有用户直接创建。验证永远为true
		local userInfo = skynet.call(login_service, "lua", "getUser", request)
		if userInfo == nil then
			skynet.call(login_service, "lua", "createUser", request)
			userInfo = skynet.call(login_service, "lua", "getUser", request)
			skynet.error("创建新用户", userInfo.name)
		else
			local result = skynet.call(login_service, "lua", "auth", request)
			if not result then
				socket.close(socketId)
				return
			end
		end
		
		local resp = {}
		resp.servers = {}
		local game_servers = sharedata.query("server_config").game_server
		for k, serverInfo in pairs(game_servers) do
			--TODO: 查找此角色在此服的player发给客户端
			table.insert(resp.servers, serverInfo)
		end

		local last_server_id = skynet.call(data_accessor_service, "lua", "user", "getLastServer", userInfo.id)
		if last_server_id then
			resp.auto_select = last_server_id
		else
			resp.auto_select = autoGetGameServer().id
		end

		resp.user_id = userInfo.id
        SocketSend(socketId, response(resp))
	else
		--skynet.error("GateServer收到未知协议")
		socket.close(socketId)
		return
	end
end

local function messageLoop(id)
	socket.start(id)
	while true do
		local req = SocketReceive(id)
		if req then		
			local type, name, request, response = protoHandler:dispatch(req)
			if type == "REQUEST" then
			    messageHandle(id, name, request, response)
            else
                --不能解析数据包
                socket.close(id)
			    return
            end
		else
			socket.close(id)
			return
		end

		--note: 需要在skynet.socket 加入socket.isclosed判断
		if socket.isclosed(id) then
			return
		end
	end
end

skynet.start(function ()
	local gate_server = sharedata.query("server_config").gate_server
	local id = socket.listen(gate_server.ip, gate_server.port)
	skynet.error("GateServer启动...地址+端口:", gate_server.ip, gate_server.port)
	protoHandler = sprotoloader.load(1):host("package")

	socket.start(id, function (id, addr)
		messageLoop(id)
	end)
end)
