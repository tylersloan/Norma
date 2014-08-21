fs    = require("fs-extra")
nconf = require("nconf")
flags = require("minimist")(process.argv.slice(2))
chalk = require("chalk")
path = require 'path'


module.exports = (tasks) ->

	useDir = unless flags.global then process.cwd() else path.resolve(__dirname, '../../')

	configExists = fs.existsSync path.join(useDir, '.nspconfig')

	unless configExists
		config =
			path: process.cwd()
			message : "Write custom config items in this file"

		fs.writeFileSync(path.join(useDir, '.nspconfig'), JSON.stringify(config, null, 5))



	# Setup nconf to use (in-order):
	#   1. Command-line arguments
	#   2. Environment variables
	#   3. A file located at 'path/to/config.json'
	#
	nconf
		.env()
		.argv()
		.file('project', {
	    file: '.nspconfig',
	    dir: useDir,
	    search: true
	  })


	if typeof tasks is 'string'
		tasks = [tasks]

	#
	# Set a few variables on `nconf`.
	#
	if tasks[2]?
		nconf.set tasks[1], tasks[2]


	if tasks[1]? and tasks[2] is `undefined`
		unless flags.remove
			console.log(
				chalk.cyan( tasks[1] + ": ")
				chalk.magenta( nconf.get(tasks[1]))
			)
		else
			nconf.clear tasks[1]

	if flags.reset
		nconf.reset()


	#
	# Save the configuration object to disk
	#
	nconf.save (err) ->
		throw err if err
