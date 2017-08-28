require("channel.channel")

ChannelManager = ChannelManager or class()

function ChannelManager.getInstance()
	if ChannelManager.instance == nil then
		ChannelManager.new()
	end

	return ChannelManager.instance
end

function ChannelManager:ctor()
	if ChannelManager.instance then 
		error( "ChannelManager instance is existed" )
	end

	ChannelManager.instance = self

    self.channels = {}
end

function ChannelManager:dtor()
	ChannelManager.instance = nil
end

function ChannelManager:create()
end

function ChannelManager:destroy()
end

function ChannelManager:pushMessage(channel)
end

function ChannelManager:broadcast()
end
