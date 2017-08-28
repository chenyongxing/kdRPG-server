TBCombatSkillBase = TBCombatSkillBase or class()

function TBCombatSkillBase:ctor(skillId, skillLevel, casterUnit)
    assert(skillId)
    assert(skillLevel)
    assert(casterUnit)

    self.skillId = skillId
    self.skillLevel = skillLevel
    --释放此技能的单位
    self.casterUnit = casterUnit

    --先手
    self.order = 0
	--冷却回合
    self.coolDownTurn = 0
end

function TBCombatSkillBase:setTarget(unitId)
	self.targetId = unitId
end

function TBCombatSkillBase:getTarget()
	return self.targetId
end

function TBCombatSkillBase:getTargetUnit()
	return self.casterUnit:getRoom():getUnit(self.targetId)
end

function TBCombatSkillBase:isTargetDead()
	return self:getTargetUnit():isDead()
end

function TBCombatSkillBase:getUnit(unitId)
	return self.casterUnit:getRoom():getUnit(unitId)
end

function TBCombatSkillBase:isUnitDead(unitId)
	return self:getUnit(unitId):isDead()
end

function TBCombatSkillBase:autoSetTarget()
end

function TBCombatSkillBase:setCoolDownTurn(turn)
	turn = math.max(0, turn)
	self.coolDownTurn = turn
end

function TBCombatSkillBase:getCoolDownTurn()
	return self.coolDownTurn
end

function TBCombatSkillBase:getOrder()
	return self.order
end

function TBCombatSkillBase:getSkillId()
	return self.skillId
end

function TBCombatSkillBase:doPerform()
	if self.targetId == nil then
		self:autoSetTarget()
	end

	if self.targetId == nil then
		return
	end

	self.data = {}
	self.data.caster_id = self.casterUnit:getUnitId()
	self.data.skill_id = self.skillId
	self.data.skill_level = self.skillLevel

	self.data.secondary_action_list = {}

	self:perform()
end

--重写，技能处理
function TBCombatSkillBase:perform()
end

function TBCombatSkillBase:addAttack(hitList)
	assert(hitList[1].target_id)

	local attribute_change_action_list = {}
	attribute_change_action_list.attribute_change_action_list = hitList
	table.insert(self.data.secondary_action_list, attribute_change_action_list)
end

function TBCombatSkillBase:createHitTarget(target_id, target_hp_change, target_mp_change)
	target_hp_change = target_hp_change or 0
	target_mp_change = target_mp_change or 0

	local hit = {}
	hit.target_id = target_id
	hit.hp_change = target_hp_change
	hit.mp_change = target_mp_change
	return hit
end

function TBCombatSkillBase:getResultData()
	return self.data
end