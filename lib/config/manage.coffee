###

	In order to have a great build tool, I feel each developer needs
	the ability to add their own preferences of how things are run.
	This file uses the awesome `nconf` package to store global and local
	config data. This allows devs to choose custom info system wise and
	project wise
	~ @jbaxleyii

###

# Require packages
fs    = require("fs-extra")
nconf = require("nconf")
flags = require("minimist")(process.argv.slice(2))
chalk = require("chalk")
path = require 'path'


module.exports = (tasks) ->

	###

		If command has been run with --global or --g then swich to the global config
		Otherwise use current directory level to create and use config (local)

	###
	unless flags.global or flags.g
		useDir = process.cwd()
	else
		useDir = path.resolve(__dirname, '../../')

	# See if a config file already exists (for local files)
	configExists = fs.existsSync path.join(useDir, '.nspconfig')

	# If no file, then we create a new one with some preset items

	###

		@todo - Should we add in ability to set common copy tasks in global config
		This could be done based off of project type and/or add a default task?

		This might not be needed if all checks fall back to global?
		~ @jbaxleyiii

	###

	unless configExists
		config =
			path: process.cwd()
			message : "Write custom config items in this file"

		# Save config
		fs.writeFileSync(path.join(useDir, '.nspconfig'), JSON.stringify(config, null, 5))



	###

		Setup nconf to use (in-order):
			1. Command-line arguments
			2. Environment variables
			3. A file located at 'path/to/config.json'

	###
	nconf
		.env()
		.argv()
		.file('project', {
	    file: '.nspconfig',
	    dir: useDir,
	    search: true
	  })


	# Convert back to array

	###

		@note this lends back to the discussion of stringifying the task list
		This is the only current string -> array we are using but if it
		grows to more then we should reset and always keep tasks as an array
		~ @jbaxleyiii

	###

	if typeof tasks is 'string'
		tasks = [tasks]

	# Empty config command returns print out of config
	if tasks.length is 1

		# Set directory
		dir = path.join(useDir, '.nspconfig')

		try
			configData = JSON.parse( fs.readFileSync(dir, {encoding: 'utf8'}) )
		catch err
			console.log chalk.red("The nspfile.json file is not valid json. Aborting."), err
			process.exit 0

		console.log configData

	# Read config of a value
	if tasks[1]? and tasks[2] is `undefined`

		# Gives users the options to remove config items
		unless flags.remove
			console.log(
				chalk.cyan( tasks[1] + ": ")
				chalk.magenta( nconf.get(tasks[1]))
			)
		else
			nconf.clear tasks[1]

	# Save config with value
	if tasks[2]?
		nconf.set tasks[1], tasks[2]


	# Reset clears entire nconf file
	if flags.reset
		nconf.reset()


	# Save the configuration object to file
	nconf.save (err) ->
		throw err if err
