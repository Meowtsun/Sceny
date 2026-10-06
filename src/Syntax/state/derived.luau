--!strict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local pub_derived = { }
local derived = { }
pub_derived.__index = derived


local function isStateReader(element)
	if typeof(element) == 'table' then
		return element.class == 'state' and element.kind == 'get'
	end

	return false
end


function pub_derived.new(name: string)
	return function (value: any)
		return setmetatable({
			class = "state",
			name = name,
			kind = "derived",
			recompute = value,
		}, pub_derived)
	end
end


function derived:open(reader: sceny.reader)
	local this = {
		recompute = self.recompute,
		kind = "derived",
		value = nil,

		dependencies = { },
		parents = { },
		invalid = false,
	}

	local symbol = reader.editor.derived
	reader.derived[self.name] = this
	reader.editor.set(self.name, this)

	reader.editor.set(symbol, this)
	this.value = this.recompute(reader.editor)
	reader.editor.set(symbol, nil)
end


function derived:read(reader: sceny.reader)
	return reader:forward()
end


return pub_derived.new