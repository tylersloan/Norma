Fs = require("fs-extra")
Chalk	= require("chalk")
Flags = require('minimist')( process.argv.slice(2) )

Init = require('./init')

module.exports = (tasks, cwd) ->


	if Flags.package
		###

			We should probably create a sample package for creating tasks and
			a sample scaffold. Is a package a task or a scaffold? This should
			be clearer

		###
		console.log "build a package here"

	if Flags.search
		###

			What would it look like to include a package system built on
			npm to pull in packages with a norma- prefix. This is getting ahead
			of the scope right now but could be really useful for packages

		###
		console.log "searching for packages"


	if tasks.length > 1
		# making directory without exception if exists
		try
			Fs.mkdirSync tasks[1]
		catch e
			throw e	unless e.code is "EEXIST"

		process.chdir tasks[1]

		tasks = ["create"]

		Init tasks, process.cwd()

	else
		console.log(
			"Usage: nsp create <name>\n" +
			"   nsp create --list\n" +
			"   nsp create --package [<package_name>]\n"
		)

		console.log Chalk.red "Please specify a project name"

		process.exit 0
