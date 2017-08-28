AoiObject = AoiObject or class()

function AoiObject:ctor()
	self.id = 0
	self.version = 0

	self.mode = {}
	self.mode.drop = false
	self.mode.move = false
	self.mode.watcher = false
	self.mode.marker = false

	self.lastPosition = nil
	self.position = nil
end