Path = require "path"
Fs = require "fs-extra"
Chalk = require "chalk"
Gulp = require "gulp"
_ = require "underscore"

ExecCommand = require "./execute-command"


module.exports = (tasks, cwd) ->

	console.log Chalk.green "Creating your package..."

	# PACKAGE-TEMPLATE ----------------------------------------------------

	Fs.copySync(
		Path.resolve __dirname , "./base-package.coffee"
		Path.join process.cwd(), "package.coffee"
	)

	# NORMA.JSON ----------------------------------------------------------

	fileName = "#{Tool}.json"

	config =
  name: Tool + "-" + tasks[1]
  type: "package"

	# Save config
	Fs.writeFileSync(
		Path.join(process.cwd(), fileName)
		JSON.stringify(config, null, 2)
	)

	# PACKAGE.JSON --------------------------------------------------------

	pkgeConfig =
	  name: "norma-" + tasks[1]
	  version: "0.0.1"
	  main: "package.coffee"
		keywords: [
	    "norma"
	    "gulp"
	  ]

	# Save package.json
	Fs.writeFileSync(
		Path.join(process.cwd(), "package.json")
		JSON.stringify(pkgeConfig, null, 2)
	)


	ExecCommand(
		"npm i --save gulp"
		process.cwd()
	,
		->
			console.log Chalk.magenta "Package Ready!"
	)
