
type kinds = | "get" | "set" | "increment" | "derived" | "map"

export type controls = | goto | leave | scene | reread
export type readables = | dialogue | question | event
export type states = | state | scripts
export type elements = readables | controls | states | meta


export type scene = {
	class: "scene",
	content: {
		elements
	},

	meta: any?,
}


export type state = {
	class: "state",
	name: string,
	kind: kinds,
	content: any,
}


export type scripts = {
	class: "scripts",
	content: (content: content) -> (controls),
}


export type reread = {
	class: "reread",
}


export type leave = {
	class: "leave",
}


export type goto = {
	class: "goto",
	content: scene,
}


export type meta = {
	class: "meta",
	content: any,
}


export type event = {
	class: "event",
	content: any,
}


export type dialogue = {
	class: "dialogue",
	character: character,
	text: string,
}


export type question = {
	class: "question",
	character: character,
	text: string,
	content: {
		| answer
		| meta
	},

	meta: any?,
}


export type answer = {
	class: "answer",
	character: character,
	text: string,
	content: {
		controls
	},

	meta: any?,
}


-- API --
type provider = (content: content) -> (any)
export type content = {
	get: (name: string) -> (any),
}


export type state_api  = {
	increment: (name: string) -> (value: number?) -> (state),
	set: (name: string) -> (value: any) -> (state),
	get: (name: string) -> (state),

	derived: (name: string) -> (provider) -> (state),
	map: (name: string) -> (provider) -> (state),
}


export type derived = {
	kind: "derived",
	value: any,

	dependencies: { [string]: true },
	parents: { [string]: true },
	invalid: boolean,
	recompute: provider,
}


type reader_api = {
	goback: (self: reader_api) -> (),
	forward: (self: reader_api) -> (),
	abort: (self: reader_api) -> (),
	readscene: (self: reader_api, scene: scene) -> (),
}


export type reader = reader_api & {

	content: elements,
	next: number,
	queued: controls?,

	answers: { answer },
	cursor: {
		content: elements,
		index: number,
	},

	derived: { [string]: derived },
	state: {
		[string]: any,
	},

	stack: {
		{ -- from reader.cursor
			content: elements,
			index: number,
		}
	},

	editor: any,
}


export type content_api = {
	get: (name: string) -> (any),
}


export type character = {
	[any]: any,

	name: string,
	data: {
		[any]: any,
	},
}


return nil