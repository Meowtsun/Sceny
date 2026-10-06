
return {

	-- Syntaxs --
	character = require(script.Syntax.character),
	event = require(script.Syntax.event),

	reread = require(script.Syntax.reread),
	leave = require(script.Syntax.leave),
	goto = require(script.Syntax.goto),
	scene = require(script.Syntax.scene),

	scripts = require(script.Syntax.scripts),
	state = require(script.Syntax.state),

	meta = require(script.Syntax.meta),
	------------


	-- Parser --
	reader = require(script.reader)
	------------
}