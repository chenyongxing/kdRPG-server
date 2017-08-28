Session = Session or class()

function Session:ctor()
	self.values = {}
end

function Session:set(key, value)
    self.values[key] = value
end

function Session:get(key)
    return self.values[key]
end