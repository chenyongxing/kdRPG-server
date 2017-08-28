require ("math.vector2")

local socket = require "skynet.socket"

function SocketReceive(fd)
	--前两个字节是长度，根据这个拆包。--最大65535
	local length = socket.read(fd, 2)
	
	if not length then
		return nil
	end 
	
	local size = length:byte(1) * 256 + length:byte(2)
	local msg = socket.read(fd, size)
	return msg
end

function SocketSend(fd, msg)
	--加两字节表示数据长度，在远端读这个拆包。--最大65535
	local pack = string.pack(">s2", msg)
	socket.write(fd, pack)
end

--等级属性计算公式  multiplier1 * (level-1)^ exponential + multiplier2 * (level-1) + base
function GetPlayerMaxHp(config, level)
	return math.floor(config.multiplier1_hp * (level-1)^ config.exponential_hp + config.multiplier2_hp * (level-1) + config.base_hp)
end 

function GetPlayerMaxMp(config, level)
	return math.floor(config.multiplier1_mp * (level-1)^ config.exponential_mp + config.multiplier2_mp * (level-1) + config.base_mp)
end 

function Vector2Make(x, y)
	return {x = x, y = y,}
end

function SerializableVector2Make(x, y)
	return {x = x, y = y,}
end

--跨service调用时候用，skynet序列化不支持Vector2
function Vector2Serialize(vec2)
	return {x = math.floor(vec2.x), y = math.floor(vec2.y),}
end

function Vector2Unserialize(vec2)
	return Vector2.new(math.floor(vec2.x), math.floor(vec2.y))
end