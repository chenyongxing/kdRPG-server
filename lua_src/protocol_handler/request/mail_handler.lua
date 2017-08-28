local skynet = require "skynet"

local function handler(session, protoName, request)
    local player = SceneManager.getInstance():getOnlinePlayer(session:get("player_id"))
    local playerMail = skynet.call(DataAccessorService, "lua", "mail", "getPlayerMail", player.name)
	return {mail_list=playerMail}
end

return handler