local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

local function handler(session, protoName, request)
    local playerInfo = skynet.call(DataAccessorService, "lua", "player", "getPlayerById", session:get("player_id"))
	playerInfo.socket_id = session:get("socket_id")
	
	--读配置，计算血量
	local career_config = sharedata.query("career_config")[playerInfo.carrer]
	playerInfo.max_hp = GetPlayerMaxHp(career_config, playerInfo.level)
	playerInfo.max_mp = GetPlayerMaxMp(career_config, playerInfo.level)
	playerInfo.move_speed = career_config.move_speed
	
	local scene
	--last_scene_id = nil表示新角色，放到初始场景
	if playerInfo.last_scene_id == nil then
		scene = SceneManager.getInstance():getScene(1)
		
		playerInfo.hp = playerInfo.max_hp
		playerInfo.mp = playerInfo.max_mp

		playerInfo.x = scene.spawnPoint.x
		playerInfo.y = scene.spawnPoint.y
	else
		scene = SceneManager.getInstance():getScene(playerInfo.last_scene_id)
	end

	local player = scene:createPlayer(playerInfo)
	SceneManager.getInstance():addOnlinePlayer(player)
	playerInfo.entity_id = player.entity_id
	player:onLogin()

	skynet.error("玩家进入游戏...名字:", playerInfo.name)
	
	local monstersInfo = {}
	for i, monster in ipairs(scene:getAllMonsters()) do
		table.insert(monstersInfo, {entity_id=monster.entity_id, monster_id=monster.monster_id, x=monster.position.x, y=monster.position.y, name=monster.name})
	end
	
	local npcsInfo = {}
	for i, npc in ipairs(scene:getAllNpcs()) do
		table.insert(npcsInfo, {entity_id=npc.entity_id, npc_id=npc.npc_id, x=npc.position.x, y=npc.position.y, name=npc.name})
	end

	local returnTable = {}
	returnTable.scene_id = scene.scene_id
	returnTable.map = {width=scene.width, height=scene.height, cs_scale=scene.csScale}
	returnTable.player=playerInfo
	returnTable.monsters=monstersInfo
	returnTable.npcs=npcsInfo

	return returnTable
end

return handler