# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;



chalk = require 'chalk'
Liftoff = require 'liftoff'


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
launcher = require('./methods/launcher')

cli.launch({}, launcher)
