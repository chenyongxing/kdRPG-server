require "scene.entity.character"

local sharedata = require "skynet.sharedata"

Npc = Npc or class(Character)

function Npc:ctor()
    self.type = EntityType.Npc
end

function Npc:dtor()
end

function Npc:initData(npcInfo)
    self.npc_id = npcInfo.config_id
    self.position = Vector2.new(npcInfo.position.x, npcInfo.position.y)
    
    local data = sharedata.query("npc_config")[self.npc_id]
    self.name = data.name
end

function Npc:reset()
    Character.reset(self)
end