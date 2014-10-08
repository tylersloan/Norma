Fs = require("fs-extra")
Chalk	= require("chalk")
Flags = require("minimist")( process.argv.slice(2) )

Init = require("./init")
Package = require "./package"

module.exports = (tasks, cwd) ->

	args = process.argv.slice(2)

	count = 0
	for argument in args

		if !argument.match /(-|--)package/
			index = args.indexOf argument
			tasks[count] = argument
			count++

	if tasks.length > 1
		# making directory without exception if exists
		try
			Fs.mkdirSync tasks[1]
		catch e
			throw e	unless e.code is "EEXIST"

		process.chdir tasks[1]

		if Flags.package

			Package tasks, cwd

		else
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
