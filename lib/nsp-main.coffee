# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;

# Require the needed packages
chalk = require 'chalk'
Liftoff = require 'liftoff'
argv = require('minimist')( process.argv.slice(2) )


# CLI configuration ----------------------------------------------------------

cli = new Liftoff({
	name: 'nsp'
})
	.on('require', (name, module) ->

		# Handling of extenal modules via Liftoff's require method
		console.log chalk.grey('Requiring external module: '+name+'...')

		if name is 'coffee-script'
			module.register()

	)
	.on( 'requireFail', (name, err) ->

		# Handle failures
		console.log chalk.black.bgRed('Unable to load:', name, err)
	)


# Launch CLI -----------------------------------------------------------------

###

	Invoke acts as the main router file of the commands to be run

###
invoke = require('./methods/launcher')

# Launch the CLI (Command Line Interface)
cli.launch({
	cwd: argv.cwd
	configPath: argv.nspfile
	require: argv.require
	completion: argv.completion
	verbose: argv.verbose
	}, invoke)
