--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)
local context = require(Sceny.context)
local editor = require(script.editor)

local empty_table = table.freeze {}
local pub_reader = { }
local reader = { }
pub_reader.__index = reader


function pub_reader.new()
	return setmetatable({
		content = nil,
		queued = nil,
		next = 1,

		answers = {},
		cursor = {
			content = nil,
			index = nil,
		},

		derived = { },
		state = { },
		stack = { },

		editor = nil,
	}, pub_reader)
end


function reader:readscene(scene: sceny.scene)
	self.content = scene
	self.queued = nil
	self.next = 1

	self.answers = { }
	self.derived = { }
	self.state = { }

	local cursor = {
		content = scene,
		index = 1,
	}

	self.cursor = cursor
	self.stack = {
		cursor
	}

	self.editor = self.editor or editor.new(self)
end


function reader:forward(): context.context
	local index = self.next

	local element = self.content.content[index]
	self.cursor.index = index

	-- handling insertion from Sceny.scripts
	if self.queued then
		element = self.queued
		self.queued = nil
	else -- continue normally
		self.next += 1
	end

	-- open element and read it
	if element ~= nil then
		element:open(self)
		return element:read(self)
	end

	return self:goback()
end


function reader:goback()
	local laststack = table.remove(self.stack)

	if laststack then
		self.content = laststack.content
		self.next = laststack.index + 1
		self.cursor = laststack
		return self:forward()

	else -- no stack was found
		return self:abort()
	end
end


function reader:abort()
	return nil
end


function reader:hasPendingQuestion()
	return next(self.answers) ~= nil
end


function reader:getCurrentAnswers()
	return self.answers
end


local function containAnswer(answers, element)
	for _, answer in answers do
		if answer == element.item then
			return true
		end
	end

	return false
end


function reader:reply(element: any)
	if not containAnswer(self.answers, element) then
		error(`[Sceny]: invalid answer given!`, 2)
	end

	if element.item.content ~= nil then
		self.content = element.item
		self.next = 1

		-- temporary cursor; does not add to stack
		local cursor = {
			content = element.item,
			index = 1,
		}

		self.cursor = cursor
		self.answers = empty_table
	end
end


return pub_reader.new