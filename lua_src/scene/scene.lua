require "base.object_pool"
require "math.math"
require "scene.entity.entity"
require "scene.entity.character"
require "scene.entity.monster"
require "scene.entity.npc"
require "scene.entity.player"
require "aoi.aoi_space"
require "pathfinding.astar_pathfinding"

local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

Scene = Scene or class()

function Scene:ctor(info)
	self.scene_id = info.id
	self.name = info.name
	local map_info_file = info.map_info_file
	local playerPoolSize = info.playerPoolSize

	self.entities = {}

	local enterCallback = function ( ... )
		self:onEnterAOI(...)
	end
	local leaveCallback = function ( ... )
		self:onLeaveAOI(...)
	end
	self.aoiSpace = AoiSpace.new(10, enterCallback, leaveCallback)
	
	self.playerPool = ObjectPool.new(Player, ObjectPoolPreCreatedType.Immediately, playerPoolSize)

	self:setMapInfo()
end

function Scene:dtor()
	for k, entity in pairs(self.entities) do
		entity:delete()
	end
end

function Scene:setMapInfo()
	local _op = skynet.call(MapPathfindingService, "lua", "getOriginPoint", self.scene_id)
	self.originPoint = Vector2.new(_op.x, _op.y)
	
	self.width = skynet.call(MapPathfindingService, "lua", "getWidth", self.scene_id)
	self.height = skynet.call(MapPathfindingService, "lua", "getHeight", self.scene_id)

	self.csScale = skynet.call(MapPathfindingService, "lua", "getCsScale", self.scene_id)

	local _sp = skynet.call(MapPathfindingService, "lua", "getSpawnPoint", self.scene_id)
	self.spawnPoint = Vector2.new(_sp.x, _sp.y)
	
	local monsters = skynet.call(MapPathfindingService, "lua", "getMonsterInfo", self.scene_id)
	for i, v in ipairs(monsters) do
		local monster = Monster.new()
		monster:initData(v)
		self:addEntity(monster)
	end

	local npcs = skynet.call(MapPathfindingService, "lua", "getNpcInfo", self.scene_id)
	for i, v in ipairs(npcs) do
		local npc = Npc.new()
		npc:initData(v)
		self:addEntity(npc)
	end
end

function Scene:update()
	for id, entity in pairs(self.entities) do
		if entity.update then
			entity:update()
		end
		
		self.aoiSpace:update(id, "wm", entity:getPosition())
	end
	
	self.aoiSpace:message()
end

function Scene:createPlayer(playerInfo)
	local player = self.playerPool:get()
	player:initData(playerInfo)
	self:addEntity(player)

	return player
end

function Scene:getPlayer(player_id)
	assert(player_id)

	for i, entity in ipairs(self.entities) do
		if entity.player_id == playe_id then
			return entity
		end
	end
end

function Scene:removePlayer(entityId)
	assert(entityId)

	local player = self:removeEntity(entityId)
	self.playerPool:release(player)
end

function Scene:addEntity(entity)
	local id = #self.entities + 1
	table.insert(self.entities, entity)

	self.aoiSpace:update(id, "wm", entity:getPosition())

	entity:setEntityId(id)
	entity:setScene(self)
	entity:onEnterScene(self)
	return id
end

function Scene:removeEntity(entityId)
	local entity = nil
	local removeIndex = nil

	for k, v in ipairs(self.entities) do
		if v.entity_id == entityId then
			entity = v
			removeIndex = k
		end
	end
	
	if removeIndex ~= nil then
		table.remove(self.entities, removeIndex)
		self.aoiSpace:update(removeIndex, "d", entity:getPosition())
		entity:onLeaveScene(self)
	end

	return entity
end

function Scene:getEntity(entityId)
	return self.entities[entityId]
end

function Scene:getAllEntities()
	return self.entities
end

function Scene:getAllMonsters()
	local monsters = {}
	for k, v in ipairs(self.entities) do
		if v.type == EntityType.Monster then
			table.insert(monsters, v)
		end
	end
	return monsters
end

function Scene:getAllNpcs()
	local npcs = {}
	for k, v in ipairs(self.entities) do
		if v.type == EntityType.Npc then
			table.insert(npcs, v)
		end
	end
	return npcs
end

function Scene:getAllPlayers()
	local players = {}
	for k, v in ipairs(self.entities) do
		if v.type == EntityType.Player then
			table.insert(players, v)
		end
	end
	return players
end

function Scene:onEnterAOI(watcherId, markerId)
	print(watcherId, " 看见 ", markerId)

	local watcher = self.entities[watcherId]
	local marker = self.entities[markerId]
end

function Scene:onLeaveAOI(watcherId, markerId)
	print(watcherId, " 丢失 ", markerId)

	local watcher = self.entities[watcherId]
	local marker = self.entities[markerId]
end