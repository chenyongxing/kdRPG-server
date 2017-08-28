require("turn_based_combat.tb_combat_room")
require("turn_based_combat.tb_combat_skill_manager")
require("turn_based_combat.unit.tb_combat_unit_base")
require("turn_based_combat.unit.tb_combat_unit_player")
require("turn_based_combat.unit.tb_combat_unit_pet")
require("turn_based_combat.unit.tb_combat_unit_monster")

TBCombatRoomManager = TBCombatRoomManager or class()

function TBCombatRoomManager.getInstance()
    if TBCombatRoomManager.instance == nil then
        TBCombatRoomManager.new()
    end

    return TBCombatRoomManager.instance
end

function TBCombatRoomManager:ctor()
    if TBCombatRoomManager.instance then 
        error( "TBCombatRoomManager instance is existed" )
    end

    TBCombatRoomManager.instance = self

    self:init()
end

function TBCombatRoomManager:dtor()
    TBCombatRoomManager.instance = nil
end

function TBCombatRoomManager:init()
    self.rooms = {}

    self.playerRoomDictionary = {}
end

function TBCombatRoomManager:update()
    for k, room in pairs(self.rooms) do
        room:update()
    end
end

function TBCombatRoomManager:createRoom(playerId, monsterId)
    assert(playerId)
    assert(monsterId)

    local playerAttribute = require("turn_based_combat.config.player").player
    local petAttribute = require("turn_based_combat.config.player").pet

    local monsters = {}
    for i, v in ipairs(require("turn_based_combat.config.pve")[monsterId]) do
        local monsterInfo = {}
        monsterInfo.attribute = require("turn_based_combat.config.monster")[v.monster_id]
        monsterInfo.monster_id = v.monster_id
        monsterInfo.pos_index = v.pos_index
        table.insert(monsters, monsterInfo)
    end

    local room = TBCombatRoom.new()
    
    local player = TBCombatUnitPlayer.new(playerAttribute, 3, 1, playerId)
    room:addUnit(player)

    -- local pet = TBCombatUnitPet.new(petAttribute, 2, 1, playerId)
    -- room:addUnit(pet)

    for i, monsterInfo in ipairs(monsters) do
        local monster = TBCombatUnitMonster.new(monsterInfo.attribute, monsterInfo.pos_index, 2, monsterInfo.monster_id)
        room:addUnit(monster)
    end

    self.playerRoomDictionary[playerId] = room
    table.insert(self.rooms, room)
    return room
end

function TBCombatRoomManager:setPlayerSkillCast(playerId, skillIndex, targetId)
    local room = self:getRoomByPlayer(playerId)
    local player = room:getCombatPlayer(playerId)
    player:setSkillCast(skillIndex, targetId)
end

function TBCombatRoomManager:setPetSkillCast(playerId, skillIndex, targetId)
    local room = self:getRoomByPlayer(playerId)
    local pet = room:getCombatPet(playerId)
    pet:setSkillCast(skillIndex, targetId)
end

function TBCombatRoomManager:destoryRoom(room, playerIds)
    if playerIds then
        for i, playerId in ipairs(playerIds) do
            self.playerRoomDictionary[playerId] = nil
        end
    end

    TableRemoveValue(self.rooms, room)
end

function TBCombatRoomManager:getRoomByPlayer(playerId)
    return self.playerRoomDictionary[playerId]
end

function TBCombatRoomManager:removePlayer(playerId)
    local room = self.playerRoomDictionary[playerId]
    if room == nil then
        return
    end

    for i, unit in ipairs(room:getCombatUnits()) do
        if unit.type == TBCombatUnitType.Player and unit.playerId == playerId then
            room:removeUnit(unit)
            return
        end
    end

    self.playerRoomDictionary[playerId] = nil
end
