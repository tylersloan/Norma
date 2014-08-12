# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;



chalk = require 'chalk'
Liftoff = require 'liftoff'
argv = require('minimist')( process.argv.slice(2) )

# CLI configuration ----------------------------------------------------------

cli = new Liftoff({
	name: 'nsp'
})
	.on('require', (name, module) ->

		console.log chalk.grey('Requiring external module: '+name+'...')

		if name is 'coffee-script'
			module.register()

	)
	.on( 'requireFail', (name, err) ->
		console.log chalk.black.bgRed('Unable to load:', name, err)
	)


# Launch CLI -----------------------------------------------------------------
invoke = require('./methods/launcher')

cli.launch({
	cwd: argv.cwd
	configPath: argv.nspfile
	require: argv.require
	completion: argv.completion
	verbose: argv.verbose
	}, invoke)
