Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"
Chalk = require "chalk"
Gulp = require "gulp"
Flags = require("minimist")( process.argv.slice(2) )
_ = require "underscore"

Build = require "./../methods/build"


module.exports = (tasks, cwd) ->

	if Flags.package

		console.log(
			Chalk.green "✔ Testing your package!"
		)

		Build tasks, cwd
