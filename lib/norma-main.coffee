# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;

# Require the needed packages
Chalk = require "chalk"
Liftoff = require "Liftoff"
Argv = require("minimist")( process.argv.slice(2) )


# CLI configuration ----------------------------------------------------------

cli = new Liftoff({
	name: Tool
})
	.on("require", (name, module) ->

		# Handling of extenal modules via Liftoff's require method
		console.log Chalk.grey("Requiring external module: "+name+"...")

		if name is "coffee-script"
			module.register()

	)
	.on( "requireFail", (name, err) ->

		# Handle failures
		console.log Chalk.black.bgRed("Unable to load:", name, err)
	)


# Launch CLI -----------------------------------------------------------------

###

	Invoke acts as the main router file of the commands to be run

###
invoke = require("./utilities/launcher")

# Launch the CLI (Command Line Interface)
cli.launch(
	cwd: Argv.cwd
	configPath: Argv[Tool]
	require: Argv.require
	completion: Argv.completion
	verbose: Argv.verbose
	,
		invoke
)
