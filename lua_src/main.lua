local skynet = require "skynet"
local sharedata = require "skynet.sharedata"
local sprotoloader = require "sprotoloader"
local sprotoparser = require "sprotoparser"

skynet.start(function()
	--协议多个虚拟机共享
	local proto = require("config.proto")
	sprotoloader.save(sprotoparser.parse(proto.gate_proto.client2server), 1)
	sprotoloader.save(sprotoparser.parse(proto.gate_proto.server2client), 2)
	sprotoloader.save(sprotoparser.parse(proto.game_proto.client2server), 3)
	sprotoloader.save(sprotoparser.parse(proto.game_proto.server2client), 4)

	--配置多个虚拟机共享
	local server_config = require("config.server_config")
	sharedata.new("server_config", server_config)
	loadConfig()

	--通过此服务访问数据库
	local data_accessor_service = skynet.uniqueservice("data_accessor_service")

	--登陆服务器。登陆校验，用户注册
	local login_service = skynet.uniqueservice("login_service", data_accessor_service)

	--网关。返回游戏服信息和对应服的角色信息给客户端
	local gate_server = skynet.uniqueservice("gate_server", login_service, data_accessor_service)

	--保存地图信息。计算寻路和缓存寻路
	local map_pathfinding_service = skynet.uniqueservice("map_pathfinding_service")

	--四叉树分割场景。获取场景实体周围一定范围内的实体和地图块
	--local scene_quadtree_service = skynet.uniqueservice("scene_quadtree_service")

	--聊天
	--local chat_service = skynet.uniqueservice("chat_service")

	--跨服服务
	--local cross_server_service = skynet.uniqueservice("cross_server_service")

	--多个游戏服
	for k, game_server_info in pairs(server_config.game_server) do
		local game_server = skynet.newservice("game_server", data_accessor_service, map_pathfinding_service)
		skynet.call(game_server, "lua", "startServer", game_server_info)
	end
end)

function loadConfig()
	sharedata.new("scene_config", require("config.scene_config"))
	sharedata.new("career_config", require("config.career_config"))
	sharedata.new("monster_config", require("config.monster_config"))
	sharedata.new("npc_config", require("config.npc_config"))
end