--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_set = { }
local set = { }
pub_set.__index = set


local function isStateReader(element)
	if typeof(element) == 'table' then
		return element.class == 'state' and element.kind == 'get'
	end

	return false
end


function pub_set.new(name: string)
	return function (value: any)
		return setmetatable({
			class = "state",
			name = name,
			kind = "set",
			content = value,
		}, pub_set)
	end
end


function set:open(reader: sceny.reader)
	if isStateReader(self.content) then
		local resolved = self.editor.get(self.content.name)
		reader.editor.set(self.name, resolved)
	else
		reader.editor.set(self.name, self.content)
	end
end


function set:read(reader: sceny.reader)
	return reader:forward()
end


return pub_set.new