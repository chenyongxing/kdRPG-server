require("session.session")

SessionManager = SessionManager or class()

function SessionManager.getInstance()
	if SessionManager.instance == nil then
		SessionManager.new()
	end

	return SessionManager.instance
end

function SessionManager:ctor()
	if SessionManager.instance then 
		error( "SessionManager instance is existed" )
	end

	SessionManager.instance = self

    self.sessions = {}
end

function SessionManager:dtor()
	SessionManager.instance = nil
end

function SessionManager:bind(socketId)
    local session = Session.new()
    self.sessions[socketId] = session
    return session
end

function SessionManager:get(socketId)
    return self.sessions[socketId]
end

function SessionManager:remove(socketId)
	self.sessions[socketId] = nil
end

function SessionManager:removeSession(session)
	for k, v in pairs(self.sessions) do
		if v == session then
			self.sessions[k] = nil
		end
	end
end
