TBCombatUnitType =
{
	Invalid = 1,
    Player = 2,
    Pet = 3,
    Monster = 4,
}

TBCombatUnitBase = TBCombatUnitBase or class()

function TBCombatUnitBase:ctor(attribute, pos_index, team)
	self.type = TBCombatUnitType.Invalid
    self.attribute = attribute
    self.pos_index = pos_index
    self.team = team

    self.is_dead = false

    self.skills = nil
    self.currentSkillIndex = 1 --1为普攻

    --buff伤害倍数
    self.buffDamgeRatio = 1
end

function TBCombatUnitBase:dtor()
end

function TBCombatUnitBase:setBuffDamgeRatio(ratio)
    self.buffDamgeRatio = ratio
end

function TBCombatUnitBase:reduceHp(value)
    self.attribute.hp = math.max(0, self.attribute.hp - self.buffDamgeRatio * value)

    if self.attribute.hp <= 0 then
        self:setDead(true)
    end
end

function TBCombatUnitBase:setRoom(room)
    self.room = room
end

function TBCombatUnitBase:getRoom()
    return self.room
end

function TBCombatUnitBase:setUnitId(unitId)
    self.unitId = unitId
end

function TBCombatUnitBase:getUnitId()
    return self.unitId
end

function TBCombatUnitBase:setDead(dead)
    self.is_dead = dead
end

function TBCombatUnitBase:isDead()
    return self.is_dead
end

function TBCombatUnitBase:onEnterRoom()
    self.skills = self:initSkills()
end

function TBCombatUnitBase:onLeaveRoom()
end

function TBCombatUnitBase:onOtherEnterRoom(otherUnit)
end

function TBCombatUnitBase:onLeaveEnterRoom(otherUnit)
end

function TBCombatUnitBase:onTurnStart(turnCount)
end

function TBCombatUnitBase:onTurnEnd(turnCount)
    --重置技能目标
    self.skills[self.currentSkillIndex]:setTarget(nil)
end

--必须重写
function TBCombatUnitBase:initSkills()
end

function TBCombatUnitBase:getSkills()
    return self.skills
end

function TBCombatUnitBase:resetCurrentSkill()
	self.currentSkillIndex = 1
end

function TBCombatUnitBase:getCurrentSkill()
	return self.skills[self.currentSkillIndex]
end

function TBCombatUnitBase:isSetTarget()
    if self.skills[self.currentSkillIndex]:getTarget() ~= nil then
        return true
    else
        return false
    end
end

function TBCombatUnitBase:setSkillCast(skillIndex, targetId)
    assert(skillIndex)

	self.currentSkillIndex = skillIndex
	local skill = self.skills[skillIndex]
	skill:setTarget(targetId)
end
