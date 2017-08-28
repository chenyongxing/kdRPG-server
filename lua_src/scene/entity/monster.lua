require "scene.entity.character"

local sharedata = require "skynet.sharedata"

Monster = Monster or class(Character)

function Monster:ctor()
    self.type = EntityType.Monster
end

function Monster:dtor()
end

function Monster:initData(monsterInfo)
    self.monster_id = monsterInfo.config_id
    self.position = Vector2.new(monsterInfo.position.x, monsterInfo.position.y)
    
    local data = sharedata.query("monster_config")[self.monster_id]
    self.name = data.name
    self.level = data.level
    self.max_hp = data.max_hp
    self.max_mp = data.max_mp
end

function Monster:reset()
    Character.reset(self)
end