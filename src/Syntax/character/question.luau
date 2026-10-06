--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local Answer = require(script.Parent.answer)
local pub_question = { }
local question = { }
pub_question.__index = question


const CLASS_MAP = {
	['scripts'] = 'scripts',
	['scene'] = 'scene',

	['question'] = 'answer',
	['dialogue'] = 'answer',
	-- since I didn't validate last
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


function pub_question.new(self: sceny.dialogue, content)
	self.class = "question"
	self.content = content

	for _, element in content do
		local success, kind, old = remapElement(element)
		if not success then
			error(`[Sceny]: expects dialogue; got {kind}`, 3)
		end

		if kind == 'meta' then
			self.meta = element.content

		elseif kind == 'answer' then
			Answer.new(element, element.content)
		end
	end

	return setmetatable(self, pub_question)
end


function question:open(reader: sceny.reader)
	reader.answers = self.content
end


function question:read(reader: sceny.reader)
	local copy = table.clone(self)
	copy.text = context.resolveText(self.text, reader)

	return context.new(copy, reader)
end


return pub_question