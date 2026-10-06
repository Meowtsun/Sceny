--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_increment = { }
local increment = { }
pub_increment.__index = increment


local function isStateReader(element)
	if typeof(element) == 'table' then
		return element.class == 'state' and element.kind == 'get'
	end

	return false
end


function pub_increment.new(name: string)
	return setmetatable({
		class = "state",
		name = name,
		kind = "increment",
		content = 1,
	}, pub_increment)
end


function pub_increment:__call(value: number)
	self.content = value
	return self
end


function increment:open(reader: sceny.reader)
	if isStateReader(self.content) then
		local resolved = self.editor.get(self.content.name)
		reader.editor.increment(self.name, resolved)
	else
		reader.editor.increment(self.name, self.content)
	end
end


function increment:read(reader: sceny.reader)
	return reader:forward()
end


return pub_increment.new