_				= require("lodash")
inquirer = require("inquirer")
fs			 = require("fs-extra")
chalk		= require("chalk")
copyTree = require("../dirTree").copyTree
copy = require("../dirTree").copy
path = require("path")
config = require "../../config/config"
exec = require('child_process').exec






module.exports = (project) ->

	compile = ->


		buildTasks = require('../tasks')
		buildTasks('build', process.cwd())



	runPostScripts = ->

		nspFile = config(process.cwd())
		if nspFile.scripts?
			for action of nspFile.scripts
				file = fs.existsSync(
					path.join(process.cwd(), nspFile.scripts[action])
				)

				if file
					console.log 'this is a file', nspFile.scripts[action]
					require path.join(process.cwd(), nspFile.scripts[action])
				else
					child = exec(nspFile.scripts[action], (err, stdout, stderr) ->
						throw err if err

					)


		# prepublish: Run BEFORE the package is published. (Also run on local npm install without any arguments.)
		# publish, postpublish: Run AFTER the package is published.
		# preinstall: Run BEFORE the package is installed
		# install, postinstall: Run AFTER the package is installed.
		# preuninstall, uninstall: Run BEFORE the package is uninstalled.
		# postuninstall: Run AFTER the package is uninstalled.
		# preupdate: Run BEFORE the package is updated with the update command.
		# update, postupdate: Run AFTER the package is updated with the update command.
		# pretest, test, posttest: Run by the npm test command.
		# prestop, stop, poststop: Run by the npm stop command.
		# prestart, start, poststart: Run by the npm start command.

		# Before compiling, remove the nspignore folder
		fs.remove(path.join(process.cwd() + '/nspignore') )

		# compile
		compile()

	# Copy over all of the things
	fs.copySync(project.path, process.cwd())

	# Do post scripts things here
	runPostScripts()
