require("scene.scene")

local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

SceneManager = SceneManager or class()

function SceneManager.getInstance()
	if SceneManager.instance == nil then
		SceneManager.new()
	end

	return SceneManager.instance
end

function SceneManager:ctor()
	if SceneManager.instance then 
		error( "SceneManager instance is existed" )
	end

	SceneManager.instance = self
end

function SceneManager:dtor()
	SceneManager.instance = nil
end

function SceneManager:init()
	print("SceneManager:init")

	self.scenes = {}

	local scene_config = sharedata.query("scene_config")
	for i, sceneInfo in ipairs(scene_config) do
		table.insert(self.scenes, Scene.new(sceneInfo))
	end

	self.onlinePlayers = {}
end

function SceneManager:getScene(id)
	return self.scenes[id]
end

function SceneManager:update()
	for k, scene in pairs(self.scenes) do
		scene:update()
	end
end

function SceneManager:addOnlinePlayer(player)
	assert(player.player_id)
	self.onlinePlayers[player.player_id] = player
end

function SceneManager:getOnlinePlayer(player_id)
	return self.onlinePlayers[player_id]
end

function SceneManager:getOnlinePlayers()
	return self.onlinePlayers
end

function SceneManager:removeOnlinePlayer(player_id)
	self.onlinePlayers[player_id] = nil
end
