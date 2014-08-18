fs = require 'fs'
path = require 'path'
chalk = require 'chalk'

module.exports = (cwd) ->

	fileLoc = path.join(cwd, 'nspfile.json')

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

	nspfile = parseFile( fs.readFileSync(fileLoc, {encoding: 'utf8'}) )


	return config
