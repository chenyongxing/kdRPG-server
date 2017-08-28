local skynet = require "skynet"

local function handler(session, protoName, request)
    local player = SceneManager.getInstance():getOnlinePlayer(session:get("player_id"))
    local playerMail = skynet.call(DataAccessorService, "lua", "mail", "getMail", request.mail_id)
    player:addItem(playerMail.item1_id, playerMail.item1_num)
end

return handler