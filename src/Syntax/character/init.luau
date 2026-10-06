--!nonstrict

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local Dialogue = require(script.dialogue)

local pub_character = { }
local character = { }


local function isDialogue(props)
	return type(props) == 'string'
end


function pub_character.new(name: string)
	return function <t> (props: t)
		return setmetatable({
			name = name,
			data = props,
		}, pub_character)
	end
end


function pub_character:__call(text: string)
	if isDialogue(text) then
		return Dialogue.new(self, text)
	end

	error(`[Sceny]: function expects string, got {typeof(text)}`, 2)
end


return pub_character.new