###

	This file finds the nspfile.json for a project.
	It then parses it and returns the object as the result of the function

###

# Require packages
fs = require 'fs'
path = require 'path'
chalk = require 'chalk'

module.exports = (cwd) ->

	# Find file based on cwd argument
	fileLoc = path.join(cwd, 'nspfile.json')

	# Create empty config object for empty returns
	config = {}

	parseFile = (data) ->

		if data is `undefined`
			console.log chalk.red("Cannot find nspfile.json. Have you initiated nsp?")
			process.exit 0

		# Try parsing the config data as JSON
		try
			config = JSON.parse(data)
		catch err
			console.log chalk.red("The nspfile.json file is not valid json. Aborting."), err
			process.exit 0


	###

		Try and read file
		This is done syncronously in order to return read data correctly

	###
	nspfile = parseFile( fs.readFileSync(fileLoc, {encoding: 'utf8'}) )

	# Return the config object
	return config
