--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local empty_table = table.freeze {}
local pub_answer = { }
local answer = { }
pub_answer.__index = answer


const CLASS_MAP = {
	['meta'] = 'meta',
	['goto'] = 'goto',
	['scene'] = 'scene',
}


local function remapElement(element)
	local old = element.class

	for name, map in CLASS_MAP do
		if element.class == name then
			element.class = map
			return true, map, old
		end
	end

	return false, element.class, old
end


function pub_answer.new(self: sceny.dialogue, content)
	self.class = "answer"
	self.content = content or empty_table

	if content == nil then
		return self
	end

	for _, element in content do
		local success, kind = remapElement(element)
		if not success then
			error(`[Sceny]: expects goto, leave or scene; got {kind}`, 5)
		end

		if kind == 'meta' then
			self.meta = element.content
		end
	end

	return setmetatable(self, pub_answer)
end


function answer:open(reader: sceny.reader)
	-- nothing as of now
end


function answer:read(reader: sceny.reader)
	local copy = table.clone(self)
	copy.text = context.resolveText(self.text, reader)

	return context.new(copy, reader)
end


return pub_answer