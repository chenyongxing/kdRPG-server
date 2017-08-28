require "scene.entity.character"
require "item.bag"

local skynet = require "skynet"

Player = Player or class(Character)

function Player:ctor()
    self.type = EntityType.Player
    self.bag = Bag.new(self)
end

function Player:dtor()
end

function Player:initData(playerInfo)
    self.user_id = playerInfo.user_id
    self.socket_id = playerInfo.socket_id
    self.player_id = playerInfo.id
    self.server_id = playerInfo.server_id
    self.carrer_id = playerInfo.carrer
    self.name = playerInfo.name
    self.position = Vector2.new(playerInfo.x, playerInfo.y)
    self.level = playerInfo.level
    self.experience = playerInfo.experience
    self.max_hp = playerInfo.max_hp
    self.hp = playerInfo.hp
    self.max_mp = playerInfo.max_mp
    self.mp = playerInfo.mp
    self.move_speed = playerInfo.move_speed

    --self.bag:parse(playerInfo.bag)
    
    --PrintTable(self)
end

function Player:reset()
    Character.reset(self)
end

function Player:changeScene(scene_id)
end

function Player:send(protoName, dataTable)
    SendToClient(self.socket_id, protoName, dataTable)
end

function Player:onEnterScene(scene)
end

function Player:onLeaveScene(scene)
end

function Player:onLogin()
end

function Player:onQuit()
    print("Player:onQuit()")
    skynet.call(DataAccessorService, "lua", "user", "saveUserInfo", self.user_id, self.server_id)
    
    skynet.call(DataAccessorService, "lua", "player", "savePlayerInfo", self.player_id, self.scene.scene_id, self.position.x, self.position.y,
        self.level, self.experience, self.hp, self.mp)
    
    self.scene:removePlayer(self.entity_id)

    TBCombatRoomManager.getInstance():removePlayer(self.player_id)
end

function Player:addItem(itemId, itemNum)
    print("addItem", itemId, itemNum)
end