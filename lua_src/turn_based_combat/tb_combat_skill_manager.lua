require("turn_based_combat.skill.tb_combat_skill_once_single")
require("turn_based_combat.skill.tb_combat_skill_multiple")
require("turn_based_combat.skill.tb_combat_skill_once_aoe")
require("turn_based_combat.skill.tb_combat_skill_revive")

TBCombatSkillManager = TBCombatSkillManager or class()

function TBCombatSkillManager.getInstance()
    if TBCombatSkillManager.instance == nil then
        TBCombatSkillManager.new()
    end

    return TBCombatSkillManager.instance
end

function TBCombatSkillManager:ctor()
    if TBCombatSkillManager.instance then 
        error( "TBCombatSkillManager instance is existed" )
    end

    TBCombatSkillManager.instance = self

    self:init()
end

function TBCombatSkillManager:dtor()
    TBCombatSkillManager.instance = nil
end

function TBCombatSkillManager:init()
    self.skillDictionary = {}

    self:registerSkill(1, TBCombatSkillOnceSingle)
    self:registerSkill(2, TBCombatSkillOnceAOE)
    self:registerSkill(3, TBCombatSkillMultiple)
    self:registerSkill(4, TBCombatSkillOnceSingle)
    self:registerSkill(5, TBCombatSkillRevive)

    self:registerSkill(6, TBCombatSkillOnceSingle)
    self:registerSkill(7, TBCombatSkillOnceAOE)
    self:registerSkill(8, TBCombatSkillMultiple)
    self:registerSkill(9, TBCombatSkillOnceSingle)
    self:registerSkill(10, TBCombatSkillRevive)
end

function TBCombatSkillManager:registerSkill(id, skillClassTable)
    assert(skillClassTable)

    self.skillDictionary[id] = skillClassTable
end

function TBCombatSkillManager:getSkillByCareer(casterUnit, careerId, unitLevel)
    local skills = {}
    
    local data = require("turn_based_combat.config.skill").career[careerId]

    for i, config in ipairs(data) do
        local skillLevel = 0
        if unitLevel >= config.level1 and unitLevel < config.level2 then
            skillLevel = 1
        end
        local skill = self.skillDictionary[config.skill_id].new(config.skill_id, skillLevel, casterUnit)
        table.insert(skills, skill)
    end

    return skills
end

function TBCombatSkillManager:getSkillByMonster(casterUnit, monsterId)
    local skills = {}
    
    local data = require("turn_based_combat.config.skill").monster[monsterId]

    for i, config in ipairs(data) do
        local skill = self.skillDictionary[config.skill_id].new(config.skill_id, 1, casterUnit)
        table.insert(skills, skill)
    end

    return skills
end
