require "utils.utils"
require "math.math"
require "pathfinding.astar_pathfinding"

local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

local mapInfoFilePath = "../map_info/"

--[[
	地图格式:
	缩放系数(服务端坐标*缩放系数=客户端坐标)

	地图宽度 - 4字节整数
	地图高度 - 4字节整数
	
	出生点
	X - 4字节整数
	Y - 4字节整数
	
	阻挡格数量 - 4字节整数
	重复阻挡格
	阻挡格X - 4字节整数
	阻挡格Y - 4字节整数
	
	数量 - 4字节整数
	重复怪物信息
	id - 4字节整数
	X - 4字节整数
	Y - 4字节整数
	
	数量 - 4字节整数
	重复npc信息
	id - 4字节整数
	X - 4字节整数
	Y - 4字节整数
]]
local function parseMapInfoFile(fileName)
    local mapInfo = {}
	--原点都统一到0,0
    mapInfo.origin_point = SerializableVector2Make(0, 0)
    mapInfo.obstruct_info = {}
	mapInfo.monster_info = {}
	mapInfo.npc_info = {}

    local path = mapInfoFilePath..fileName
    local file = assert(io.open(path, "rb"))
	
	--缩放系数服务端无用
	mapInfo.cs_scale = string.unpack("f", file:read(4))

	mapInfo.width = string.unpack("i4", file:read(4))
	mapInfo.height = string.unpack("i4", file:read(4))

	local spwanPointX = string.unpack("i4", file:read(4))
	local spwanPointY = string.unpack("i4", file:read(4))
	mapInfo.spawn_point = SerializableVector2Make(spwanPointX, spwanPointY)
	
	local obstructGridNum = string.unpack("i4", file:read(4))
	
	for i = 1, obstructGridNum do
		local x = string.unpack("i4", file:read(4))
		local y = string.unpack("i4", file:read(4))
		table.insert(mapInfo.obstruct_info, SerializableVector2Make(x, y))
	end

	local monsterNum = string.unpack("i4", file:read(4))
	for i = 1, monsterNum do
		local config_id = string.unpack("i4", file:read(4))
		local x = string.unpack("i4", file:read(4))
		local y = string.unpack("i4", file:read(4))
		local info = {config_id=config_id, position=SerializableVector2Make(x, y)}
		table.insert(mapInfo.monster_info, info)
	end

	local npcNum = string.unpack("i4", file:read(4))
	for i = 1, npcNum do
		local config_id = string.unpack("i4", file:read(4))
		local x = string.unpack("i4", file:read(4))
		local y = string.unpack("i4", file:read(4))
		local info = {config_id=config_id, position=SerializableVector2Make(x, y)}
		table.insert(mapInfo.npc_info, info)
	end

	file:close()

    return mapInfo
end

local maps = {}

local function parseMaps()
    local scene_config = sharedata.query("scene_config")
	for i, sceneInfo in ipairs(scene_config) do
        table.insert(maps, parseMapInfoFile(sceneInfo.map_info_file))
	end
end

local CMD = {}

function CMD.getOriginPoint(scene_id)
    return maps[scene_id].origin_point
end

function CMD.getWidth(scene_id)
    return maps[scene_id].width
end

function CMD.getHeight(scene_id)
    return maps[scene_id].height
end

function CMD.getCsScale(scene_id)
    return maps[scene_id].cs_scale
end

function CMD.getSpawnPoint(scene_id)
    return maps[scene_id].spawn_point
end

function CMD.getMonsterInfo(scene_id)
    return maps[scene_id].monster_info
end

function CMD.getNpcInfo(scene_id)
    return maps[scene_id].npc_info
end

function CMD.getObstructInfo(scene_id)
    return maps[scene_id].obstruct_info
end

local pathfinding = AstarPathfinding.new()
function CMD.findPath(scene_id, startPos, targetPos)
	--TODO: 缓存

	local map_info = maps[scene_id]
    pathfinding:setMapInfo(map_info.width, map_info.height, map_info.obstruct_info)
	print("------findPath-----", Vector2Unserialize(startPos), Vector2Unserialize(targetPos))
	local successed, path = pathfinding:find(Vector2Unserialize(startPos), Vector2Unserialize(targetPos))
	return path
end

skynet.start(function ()
    parseMaps()

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local ret = CMD[cmd](...)
		skynet.ret(skynet.pack(ret))
	end)
end)
