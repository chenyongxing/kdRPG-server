local skynet = require "skynet"
local socket = require "skynet.socket"
local sharedata = require "skynet.sharedata"
local sprotoloader = require "sprotoloader"

require("base.class")
require("utils.utils")
require("session.session_manager")
require("scene.scene_manager")
require("turn_based_combat.tb_combat_room_manager")

local args = table.pack(...)
--全局
DataAccessorService = args[1]
MapPathfindingService = args[2]
ServerID = nil

local CMD = {}

local protoHandler
local protoSender

--------------request handler---------------
local get_player_handler = require("protocol_handler.request.get_player_handler")
local create_player_handler = require("protocol_handler.request.create_player_handler")
local enter_scene_handler = require("protocol_handler.request.enter_scene_handler")
local move_handler = require("protocol_handler.request.move_handler")
local combat_enter_room_handler = require("protocol_handler.request.combat_enter_room_handler")
local combat_client_ready_handler = require("protocol_handler.request.combat_client_ready_handler")
local combat_client_timeout_handler = require("protocol_handler.request.combat_client_timeout_handler")
local combat_skill_cast_handler = require("protocol_handler.request.combat_skill_cast_handler")
local combat_client_play_end_handler = require("protocol_handler.request.combat_client_play_end_handler")
local mail_handler = require("protocol_handler.request.mail_handler")
local mail_receive_handler = require("protocol_handler.request.mail_receive_handler")

--------------response handler---------------

--每个连接用户都一个rpc会话表
-- local rpcSession = 0
-- local rpcSessionHandlerMap = {}
function SendToClient(socketId, protoName, dataTable)
	assert(socketId)

	local session = SessionManager.getInstance():get(socketId)

	local rpcSession = session:get("rpc_session")
	if rpcSession == nil then
		rpcSession = 1
	else
		rpcSession = rpcSession + 1
	end
	session:set("rpc_session", rpcSession)

	--response handler
	-- if protoName == "entity_enter_aoi" then
	-- 	rpcSessionHandlerMap[rpcSession] = 
	-- end

	local request = protoSender(protoName, dataTable, rpcSession)

	SocketSend(socketId, request)
end

local function dispatchMsgHandle(socketId, protoName, request, response)
	--每一个连接的用户，都有一个会话信息
	local session = SessionManager.getInstance():get(socketId)

	----------------------进入游戏开始，生成会话------------------------------
	if protoName == "get_player" then
		if session ~= nil then
			return
		end

		--验证用户
		local result = skynet.call(skynet.queryservice("login_service"), "lua", "auth", request)
		if not result then
			socket.close(socketId)
			return
		end

		local resp, user_id = get_player_handler(session, protoName, request)
		
		session = SessionManager.getInstance():bind(socketId)
		session:set("socket_id", socketId)
		session:set("user_id", user_id)
		session:set("server_id", ServerID)
		
		if resp.player then
			session:set("player_id", resp.player.id)
		end
		
		SocketSend(socketId, response(resp))
		return
	end
	
	---------------没有角色，创建创建成功后，设置会话player_id------------------------------	
	if protoName == "create_player" then
		if session == nil or session:get("player_id") ~= nil then
			return
		end

		local resp = create_player_handler(session, protoName, request)

		--有角色，设置会话
		if not resp.error then
			local playerInfo = skynet.call(data_accessor_service, "lua", "player", "getPlayerByName", request.name)
			session:set("player_id", playerInfo.id)
		end

		SocketSend(socketId, response(resp))
		return
	end

	----------------保证后续的请求是有会话信息的----------------
	if session == nil or session:get("player_id") == nil then
		return
	end

	local resp
	if protoName == "enter_scene" then
		resp = enter_scene_handler(session, protoName, request)
	elseif protoName == "move" then
		resp = move_handler(session, protoName, request)
	elseif protoName == "combat_enter_room" then
		resp = combat_enter_room_handler(session, protoName, request)
	elseif protoName == "combat_client_ready" then
		resp = combat_client_ready_handler(session, protoName, request)
	elseif protoName == "combat_skill_cast" then
		resp = combat_skill_cast_handler(session, protoName, request)
	elseif protoName == "combat_client_timeout" then
		resp = combat_client_timeout_handler(session, protoName, request)
	elseif protoName == "combat_client_play_end" then
		resp = combat_client_play_end_handler(session, protoName, request)
	elseif protoName == "mail" then 
		resp = mail_handler(session, protoName, request)
	elseif protoName == "mail_receive" then
		resp = mail_receive_handler(session, protoName, request)
	else
		socket.close(id)
		skynet.error("GameServer收到未知协议")
		return
	end
	
	if resp then
		SocketSend(socketId, response(resp))
	else
		--保证回应
		SocketSend(socketId, response({}))
	end
end

local function onDisconnect(socketId)
	local session = SessionManager.getInstance():get(socketId)
	if session == nil or session:get("player_id") ~= nil then
		local player = SceneManager.getInstance():getOnlinePlayer(session:get("player_id"))
		if player then
			player:onQuit()
		end
		SessionManager.getInstance():remove(socketId)
	end
end

local function socketReceiveLoop(id)
	socket.start(id)

	while true do
		local req = SocketReceive(id)
		if req then		
			local type, ret1, ret2, ret3 = protoHandler:dispatch(req)
			if type == "REQUEST" then
				local name = ret1
				local request = ret2
				local response = ret3
			    dispatchMsgHandle(id, name, request, response)
            elseif type == "RESPONSE" then
				local session = ret1
				local response = ret2
				-- local responseHandler = rpcSessionHandlerMap[session]
				-- if responseHandler then
				-- 	responseHandler(response)
				-- 	rpcSessionHandlerMap[session] = nil
				-- end
			else
                --不能解析数据包
                socket.close(id)
			end
		else
			socket.close(id)
		end

		--note: 需要在skynet.socket 加入socket.isclosed判断
		if socket.isclosed(id) then
			onDisconnect(id)
			return
		end
	end
end

local function gameLoop()
	while true do
		skynet.sleep(2) -- 1/100 秒

		SceneManager.getInstance():update()	
		TBCombatRoomManager.getInstance():update()
	end
end

function CMD.startServer(game_server_info)
	ServerID = game_server_info.id
	
	local id = socket.listen(game_server_info.ip, game_server_info.port)
	skynet.error(game_server_info.id, "服启动...地址+端口:", game_server_info.ip, game_server_info.port)

	protoHandler = sprotoloader.load(3):host("package")
	protoSender = protoHandler:attach(sprotoloader.load(4))

	socket.start(id, function (id, addr)
		skynet.error(ServerID, "服 connect from ", addr)
		socketReceiveLoop(id)
	end)

	SceneManager.getInstance():init()
	skynet.fork(gameLoop)
end

skynet.start(function ()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local ret = CMD[cmd](...)
		skynet.ret(skynet.pack(ret))
	end)
end)
