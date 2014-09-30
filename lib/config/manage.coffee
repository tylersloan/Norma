###

	In order to have a great build tool, I feel each developer needs
	the ability to add their own preferences of how things are run.
	This file uses the awesome `nconf` package to store global and local
	config data. This allows devs to choose custom info system wise and
	project wise
	~ @jbaxleyii

###

# Require packages
Fs    = require "fs-extra"
Nconf = require "nconf"
Flags = require("minimist")(process.argv.slice(2))
Chalk = require "chalk"
Path = require "path"


module.exports = (tasks) ->

	###

		If command has been run with --global or --g then
		swich to the global config, otherwise use current
		directory level to create and use config (local)

	###
	if Flags.global or Flags.g
		useDir = Path.resolve __dirname, "../../"
	else
		useDir = process.cwd()

	# See if a config file already exists (for local files)
	configExists = Fs.existsSync Path.join(useDir, ".#{Tool}")

	# If no file, then we create a new one with some preset items

	###

		@todo - Should we add in ability to set common copy tasks in global config
		This could be done based off of project type and/or add a default task?

		This might not be needed if all checks fall back to global?
		~ @jbaxleyiii

	###

	if !configExists
		config =
			Path: process.cwd()
			message : "Write custom config items in this file"

		# Save config
		Fs.writeFileSync(
			Path.join(useDir, ".#{Tool}")
			JSON.stringify(config, null, 2)
		)



	###

		Setup Nconf to use (in-order):
			1. Command-line arguments
			2. Environment variables
			3. A file located at "Path/to/config.json"

	###
	Nconf
		.env()
		.argv()
		.file("project", {
	    file: ".#{Tool}",
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

	if typeof tasks is "string"
		tasks = [tasks]

	# Empty config command returns print out of config
	if tasks.length is 1

		# Set directory
		dir = Path.join useDir, ".#{Tool}"

		try
			file = Fs.readFileSync dir, encoding: "utf8"

			configData = JSON.parse file

		catch err

			console.log(
				Chalk.red "The .#{Tool} file is not valid json. Aborting."
				err
			)
			process.exit 0

		# Print out cofing data for easy lookup
		console.log configData


	# Read config of a value
	if tasks[1] and tasks[2] is `undefined`

		# Gives users the options to remove config items
		if !Flags.remove
			console.log(
				Chalk.cyan( tasks[1] + ": ")
				Chalk.magenta( Nconf.get(tasks[1]))
			)
		else
			Nconf.clear tasks[1]

	# Save config with value
	if tasks[2]
		Nconf.set tasks[1], tasks[2]


	# Reset clears entire Nconf file
	if Flags.reset
		Nconf.reset()


	# Save the configuration object to file
	Nconf.save (err) ->
		throw err if err
