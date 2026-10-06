--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)

local Question = require(script.Parent.question)
local pub_dialogue = { }
local dialogue = { }
pub_dialogue.__index = dialogue


function pub_dialogue.new(character: sceny.character, text: string)
	return setmetatable({
		class = "dialogue",
		text = text,
		character = character,
	}, pub_dialogue)
end


function pub_dialogue:__call(content: {sceny.dialogue})
	return Question.new(self, content)
end


function dialogue:open(reader: sceny.reader)
	-- nothing as of now
end


function dialogue:read(reader: sceny.reader)
	local copy = table.clone(self)
	copy.text = context.resolveText(self.text, reader)

	return context.new(copy)
end


return pub_dialogue