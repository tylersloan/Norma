inquirer = require("inquirer")
fs       = require("fs-extra")
chalk    = require("chalk")
path     = require("path")
config   = require "../../config/config"
exec     = require('child_process').exec
argv     = require('minimist')( process.argv.slice(2) )

module.exports = (project) ->


	scaffoldConfig = config path.join(project.path)


	runConfigCommand = (action, cwd) ->

		file = fs.existsSync(
			path.join(cwd, action)
		)

		if file
			require path.join(cwd, action)

		else
			child = exec(action, (err, stdout, stderr) ->
				throw err if err

			)



	compile = ->


		buildTasks = require('../tasks')
		tasks = argv._
		tasks[0] = "build"

		buildTasks(tasks, process.cwd())

		if scaffoldConfig.scripts.postinstall?
			runConfigCommand(scaffoldConfig.scripts.postinstall, project.path)



	runPostScripts = ->

		nspFile = config(process.cwd())
		if nspFile.scripts?
			for action of nspFile.scripts
				unless action is 'preinstall' or action is 'postinstall'
					runConfigCommand(nspFile.scripts[action], process.cwd())



		# Before compiling, remove the nspignore folder
		fs.remove(path.join(process.cwd() + '/nspignore') )

		# compile
		compile()



	###

		Run preinstall command

		Thoughts on being able to make this an async task with a callback?
		Or perhaps promise based

		[todo]

	###
	if scaffoldConfig.scripts.preinstall?
		runConfigCommand(scaffoldConfig.scripts.preinstall, project.path)



	# Copy over all of the things
	fs.copySync(project.path, process.cwd())

	# Do post scripts things here
	runPostScripts()
