fs			 = require("fs-extra")
chalk		= require("chalk")
path = require("path")
argv = require('minimist')( process.argv.slice(2) )
init = require('./init')

module.exports = (tasks, env) ->

	if argv.list
		console.log "set up listing of projects here"
	if argv.package
		console.log "build a package here"


	if tasks is "create"

		console.log(
			"Usage: nsp create <name>\n" +
			"   nsp create --list\n" +
			"   nsp create --package [<package_name>]\n"
		)

		# Resassign to array
		tasks = [tasks]


	if tasks.length > 1
		# making directory without exception if exists
		try
			fs.mkdirSync tasks[1]
		catch e
			throw e	unless e.code is "EEXIST"

		process.chdir tasks[1]
		env.cwd = process.cwd()

		init "create", env

	else
		console.log chalk.red "Please specify a project name"

		process.exit 0
