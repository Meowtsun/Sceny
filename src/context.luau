--!nonstrict
--!optimize 2

local Sceny = script:FindFirstAncestor('Sceny')
local sceny = require(Sceny.kind)

local pub_context = { }
local Context = { }
pub_context.__index = Context

type queries = | 'message' | 'character' | 'meta' | 'eventparam' | 'answers'
type viewables = | 'dialogue' | 'question' | 'event'

type getcontext = ((self: any, field: 'message') -> (string))
& ((self: any, field: 'character') -> (sceny.character))
& ((self: any, field: 'eventparam') -> (any))
& ((self: any, field: 'meta') -> (any))
& ((self: any, field: 'answers') -> {context})


export type context = typeof(setmetatable({
	get = nil :: getcontext
}, pub_context))


const INTERPOLATOR_CAPTURES = "%$%[([^%]]+)%]"
const RESPOND_MAP = {
	eventparam = { parent = 'event' },
	message = { key = 'text' },
	character = { key = 'character' },

	answers = {
		parent = 'question',
		whitelist = {
			['answer'] = true
		},
	},
}


function pub_context.new(element, reader): context
	return setmetatable({
		item = element,
		reader = reader,
	}, pub_context)
end


function Context:isA(kind: viewables): boolean
	return self.item.class == kind
end


local function getChildrenOf(element, whitelist: { [string]: true }?)
	local children = { }

	for _, item in element.content do
		if whitelist then
			if whitelist[item.class] then
				table.insert(children, pub_context.new(item))
			end
		else -- no whitelist
			table.insert(children, pub_context.new(item))
		end
	end

	return children
end


local function isStateReader(value)
	if typeof(value) == 'table' then
		return value.class == 'Sceny.state' and value.kind == 'get'
	end

	return false
end


local function queryMetadata(self)
	local meta = self.item.meta

	local invalid_query = `[Sceny]: this {self.item.class} doesn't contain meta!`
	if meta == nil then
		error(invalid_query, 3)
	end

	local reader = self.reader

	if typeof(meta) == 'table' then
		local copy = table.clone(meta)

		for key, value in copy do
			if isStateReader(value) then
				copy[key] = reader.editor.get(value.name)
			end
		end

		return copy

	else -- check and map only one accordingly
		if isStateReader(meta) then
			return self.state.get(meta.name)
		end
	end
end


function Context:get(query: queries)

	if query == 'meta' then
		return queryMetadata(self)
	end

	local invalid_query = `[Sceny]: this {self.item.class} doesn't contain {query}!`
	local mapping = RESPOND_MAP[query]
	if mapping == nil then
		error(invalid_query, 2)
	end

	local whitelist = mapping.whitelist
	local class = mapping.parent
	local kind = self.item.class

	-- having whitelist mean getting entire table
	if whitelist ~= nil then
		if class == nil then
			return getChildrenOf(self.item)

		-- have a class filter, has to be valid
		elseif kind == class then
			return getChildrenOf(self.item, whitelist)
		end
	end

	-- not having whitelist mean only getting one value
	local key = mapping.key or 'content'

	if class == nil then
		local result = self.item[key]
		if result == nil then
			error(invalid_query, 2)
		end

		return result

	-- have a class filter, has to be valid
	elseif kind == class then
		local result = self.item[key]
		if result == nil then
			error(invalid_query, 2)
		end

		return result
	end

	error(invalid_query, 2)
end


function pub_context.resolveText(text: string, reader: sceny.reader)
	return string.gsub(text, INTERPOLATOR_CAPTURES, function(name)
		return tostring(reader.editor.get(name))
	end)
end


return pub_context