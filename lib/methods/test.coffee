Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"
Chalk = require "chalk"
Gulp = require "gulp"
_ = require "underscore"

ReadConfig = require "./read-config"


arrayify = (el) ->
	(if Array.isArray(el) then el else [el])


camelize = (str) ->
	str.replace /-(\w)/g, (m, p1) ->
		p1.toUpperCase()


module.exports = (tasks, cwd) ->


	config = ReadConfig cwd

	if config.type isnt "package"
		return

	npmPackage = require Findup "package.json", cwd: cwd

	if !npmPackage.main
		console.log(
			Chalk.red "Please specify an entry file in the projects package.json"
		)

		return

	pkge = require Path.resolve cwd, npmPackage.main

	taskObject = pkge config, Path.resolve(__dirname, '../../')
	taskObject = null

	_.extend Gulp.tasks, pkge.tasks

	console.log(
		Chalk.green "✔ Testing your package!"
	)

	Build = require("./build")(tasks, cwd)
