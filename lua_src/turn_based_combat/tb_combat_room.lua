require("turn_based_combat.unit.tb_combat_unit_base")

local skynet = require "skynet"

TBCombatRoomStatus =
{
    Invalid = 1,
    Start = 2,
    Fight = 3,
    Playing = 4,
    End = 5,
    Destory = 6,
}

TBCombatRoom = TBCombatRoom or class()

function TBCombatRoom:ctor()
    self.units = {}
    self.status = TBCombatRoomStatus.Invalid
    self.turnCount = 0

    self.onceStartCallFlag = false
    self.oncePlayingCallFlag = false

    self.timeOutTime = nil
    self.readyOverTime = 30
    self.playingOverTime = 60
end

function TBCombatRoom:dtor()
end

function TBCombatRoom:setStatus(status)
    self.status = status
end

function TBCombatRoom:update()
    if not self:isHavePlayer() then
        TBCombatRoomManager.getInstance():destoryRoom(self)
    end

    if self.status == TBCombatRoomStatus.Start then
        self.turnCount = self.turnCount + 1
        if not self.onceStartCallFlag then
            self:sendAll("combat_turn_start", {turn_count=self.turnCount})
            
            for i, unit in ipairs(self.units) do
                unit:onTurnStart(self.turnCount)
            end

            self.timeOutTime = skynet.time()
            
            self.onceStartCallFlag = true
        end

        --玩家选择技能和目标完毕，进入下一阶段
        if self:checkPlayerSetTarget() then
            self.status = TBCombatRoomStatus.Fight
        end
        --超时检测
        if skynet.time() - self.timeOutTime >= self.readyOverTime then
            self.status = TBCombatRoomStatus.Fight
        end
    elseif self.status == TBCombatRoomStatus.Fight then
        self:performOneTurn()
        self.status = TBCombatRoomStatus.Playing
    elseif self.status == TBCombatRoomStatus.Playing then --客户端播放完毕，协议回来直接切到End
        if not self.oncePlayingCallFlag then
            self.timeOutTime = skynet.time()
            self.oncePlayingCallFlag = true
        end 

        --超时检测
        if skynet.time() - self.timeOutTime >= self.playingOverTime then
            self.status = TBCombatRoomStatus.End
        end
    elseif self.status == TBCombatRoomStatus.End then
        for i, unit in ipairs(self.units) do
            unit:onTurnEnd(self.turnCount)
        end
        --有一方队伍团灭，战斗结束
        local result, ace_team = self:checkACE()
        if result then
            if ace_team == 1 then
                self.winTeam = 2
            elseif ace_team == 2 then
                self.winTeam = 1
            end
            self.status = TBCombatRoomStatus.Destory
        else
            self.status = TBCombatRoomStatus.Start
        end

        self.onceStartCallFlag = false
        self.oncePlayingCallFlag = false
    elseif self.status == TBCombatRoomStatus.Destory then
        self:sendAll("combat_turn_end", {win_team=self.winTeam})
        TBCombatRoomManager.getInstance():destoryRoom(self, self:getCombatPlayerIds())
    end
end

--玩家选择攻击目标完毕
function TBCombatRoom:checkPlayerSetTarget()
    for i, unit in ipairs(self.units) do
        if unit.type == TBCombatUnitType.Player or unit.type == TBCombatUnitType.Pet then
            if not unit:isSetTarget() then
                return false
            end
        end
    end

    return true
end

--计算一个回合战斗，并发送数据给客户端表现
function TBCombatRoom:performOneTurn()
    local data = {}
    data.major_action_list = {}
    data.cd_skill_list = {}
    data.buff_list = {}
    data.combat_unit_attribute_list = {}

    --attribute change sync
    for i, unit in ipairs(self.units) do
        table.insert(data.combat_unit_attribute_list, {unit_id = i, 
            hp = unit.attribute.hp, max_hp = unit.attribute.max_hp, 
            mp = unit.attribute.mp, max_mp = unit.attribute.max_mp,})
    end 

    --buff handle  buff.unit_id  buff.attribute_change  buff.turn_number

    --skill handle
    local allSkills = {}
    for i, unit in ipairs(self.units) do
        if not unit:isDead() then
            local skill = unit:getCurrentSkill()
            if skill:getCoolDownTurn() <= 0 then
                table.insert(allSkills, skill)
            end
        end
    end
    --skill order
    table.sort(allSkills, function (a, b) return a:getOrder() > b:getOrder() end)
    for i, skill in ipairs(allSkills) do
        skill:doPerform()
        table.insert(data.major_action_list, skill:getResultData())
    end

    --cd skill
    for i, unit in ipairs(self.units) do
        for i, skill in ipairs(unit:getSkills()) do
            if skill:getCoolDownTurn() > 0 then
                table.insert(data.cd_skill_list, skill:getSkillId())
                skill:setCoolDownTurn(skill:getCoolDownTurn() - 1)
            end
        end
    end

    --PrintTable(data)
    self:sendAll("combat_turn_play", data)
end

--检查是否有一队团灭。战斗结束判断
function TBCombatRoom:checkACE()
    local team1ACE = true
    local team2ACE = true

    for i, unit in ipairs(self.units) do
        if unit.team == 1 and not unit:isDead() then
            team1ACE = false
            break
        end
    end

    for i, unit in ipairs(self.units) do
        if unit.team == 2 and not unit:isDead() then
            team2ACE = false
            break
        end
    end

    if team2ACE then
        return true, 2
    elseif team1ACE then
        return true, 1
    end

    return false
end

function TBCombatRoom:getCombatUnits()
    return self.units
end

function TBCombatRoom:getUnit(unit_id)
    return self.units[unit_id]
end

function TBCombatRoom:addUnit(unit)
    unit:setUnitId(#self.units+1)
    unit:setRoom(self)

    unit:onEnterRoom()
    for i, unit in ipairs(self.units) do
        unit:onOtherEnterRoom(unit)
    end
    
    table.insert(self.units, unit)
end

function TBCombatRoom:removeUnitById(unit_id)
    for i = #self.units, 1, -1 do
		if i == unit_id then
			table.remove(self.units, i)
            return
		end
	end
end

function TBCombatRoom:removeUnit(unit)
    TableRemoveValue(self.units, unit)
end

function TBCombatRoom:getCombatPlayerIds()
    local playerIds = {}
    for i, unit in ipairs(self.units) do
        if unit.type == TBCombatUnitType.Player then
            table.insert(playerIds, unit.playerId)
        end
    end

    return playerIds
end

function TBCombatRoom:getCombatPlayer(playerId)
    for i, unit in ipairs(self.units) do
        if unit.type == TBCombatUnitType.Player and unit.playerId == playerId then
            return unit
        end
    end
end

function TBCombatRoom:isHavePlayer()
    for i, unit in ipairs(self.units) do
        if unit.type == TBCombatUnitType.Player then
            return true
        end
    end

    return false
end

function TBCombatRoom:getCombatPet(playerId)
    for i, unit in ipairs(self.units) do
        if unit.type == TBCombatUnitType.Pet and unit.masterPlayerId == playerId then
            return unit
        end
    end
end

function TBCombatRoom:getEnemies(unit)
    local enemies = {}
    for i, v in ipairs(self.units) do
        if v.team ~= unit.team and not v:isDead() then
            table.insert(enemies, v)
        end
    end

    return enemies
end

function TBCombatRoom:getRandomEnemy(unit)
    local enemies = self:getEnemies(unit)
    return enemies[math.round(math.randomRange(1, #enemies))]
end

function TBCombatRoom:getRandomEnemy(unit)
    local enemies = self:getEnemies(unit)
    return enemies[math.round(math.randomRange(1, #enemies))]
end

function TBCombatRoom:sendAll(protoName, dataTable)
    for i, playerId in ipairs(self:getCombatPlayerIds()) do
        local player = SceneManager.getInstance():getOnlinePlayer(playerId)
        player:send(protoName, dataTable)
    end
end

