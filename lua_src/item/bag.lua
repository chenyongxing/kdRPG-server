local json = require("third_libs.json")

Bag = Bag or class()

function Bag:ctor(player)
    self.player = player
end

function Bag:parse(jsonData)
    local data = json.decode(jsonData)
    self.bag_id = data.bag_id
    self.max_number = data.max_number
    self.unlock_number = data.max_number.unlock_number
    
    for i, item in ipairs(data.items) do
        -- item.item_id
        -- item.bag_pos
    end
    
    self.items = {}
end