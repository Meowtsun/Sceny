--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_scene = { }
local scene = { }
pub_scene.__index = scene


function pub_scene.new(content: {sceny.elements}): sceny.scene
	return setmetatable({
		class = "scene",
		content = content,
		meta = nil,
	}, pub_scene)
end


function pub_scene:__call()
	return self
end


function scene:open(reader: sceny.reader)
	reader.content = self
	reader.next = 1

	local cursor = {
		content = self,
		index = 1,
	}

	reader.cursor = cursor
	table.insert(reader.stack, cursor)
end


function scene:read(reader: sceny.reader)
	return reader:forward()
end


return pub_scene.new