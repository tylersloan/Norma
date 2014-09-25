inquirer = require("inquirer")
fs       = require("fs-extra")
chalk    = require("chalk")
path     = require("path")
config   = require "../../config/config"
exec     = require('child_process').exec
argv     = require('minimist')( process.argv.slice(2) )

module.exports = (project, name) ->

	# See if a config file already exists (for local files)
	configExists = fs.existsSync path.join(project.path, 'nspfile.json')

	###

		This portions saves the name of the project to the nspfile. I wonder
		if there is a way to insert the name at the top. Ordering of keys
		will be needed for more complex initializations as well

	###
	if configExists
		scaffoldConfig = config path.join project.path
		scaffoldConfig.name = name
	else
		scaffoldConfig =
			name: name
			message : "Write custom config items in this file"



	###

		This function is used for running custom pre and post init scripts
		It can run a node script or a command line script such as
		mocha, npm run, etc

	###
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


	# Run the inital batch of scripts
	compile = ->


		buildTasks = require('../tasks')
		tasks = argv._
		tasks[0] = "build"

		buildTasks(tasks, process.cwd())

		# Run post installation scripts
		if scaffoldConfig.scripts and scaffoldConfig.scripts.postinstall?
			runConfigCommand(scaffoldConfig.scripts.postinstall, project.path)


	# Run any other scripts for the project
	runScripts = ->

		nspFile = config(process.cwd())

		if nspFile.scripts
			for action of nspFile.scripts
				if action isnt 'preinstall' or
					action isnt 'postinstall' or
					action isnt 'custom'
						runConfigCommand(nspFile.scripts[action], process.cwd())


		# Before compiling, remove the nspignore folder
		fs.remove(path.join(process.cwd() + '/nspignore') )

		compile()



	###

		Run preinstall command

		@note

			Thoughts on being able to make this an async task with a callback?
			Or perhaps promise based. I'm not really sure how to do this.
			Right now the move can happen while other scripts are being run.
			We need to figure out a way to have the move be delayed until after
			any preinstall scripts are ready. I might kill this feature until
			we can figure this out. We can get insight into how npm is doing it
			for their system here:

			[https://github.com/npm/npm/blob/master/lib/utils/lifecycle.js]

			If we restrict the type of scripts to just process scripts we
			can successfully register a fallback. In fact if we spawn a child
			process and run node <script name> then we should be able to do the
			same type of callback if it is a file.


	###
	# if scaffoldConfig.scripts and scaffoldConfig.scripts.preinstall?
	# 	runConfigCommand(scaffoldConfig.scripts.preinstall, project.path)

	if project.path isnt process.cwd()
		# Copy over all of the things
		fs.copySync(project.path, process.cwd())


	# Save config
	fs.writeFileSync(
		path.join(process.cwd(), 'nspfile.json')
		JSON.stringify(scaffoldConfig, null, 5)
	)


	# Do post scripts things here
	runScripts()
