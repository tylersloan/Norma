# Need to set up questions regarding custom build
# inquirer = require("inquirer")
Fs       = require("fs-extra")
Path     = require("path")
ReadConfig   = require "./read-config"
Exec     = require('child_process').exec
Argv     = require('minimist')( process.argv.slice(2) )

module.exports = (project, name) ->

	# See if a config file already exists (for local files)
	fileName = "#{Tool}.json"
	console.log project
	configExists = Fs.existsSync Path.join(project.path, fileName)

	###

		This portions saves the name of the project to the norma. I wonder
		if there is a way to insert the name at the top. Ordering of keys
		will be needed for more complex initializations as well

	###
	if configExists
		scaffoldConfig = ReadConfig Path.join project.path
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

		file = Fs.existsSync(
			Path.join(cwd, action)
		)

		if file
			require Path.join(cwd, action)

		else
			child = Exec(
				action
				(err, stdout, stderr) ->
					throw err if err
			)


	# Run the inital batch of scripts
	compile = ->


		buildTasks = require './build'
		tasks = Argv._
		tasks[0] = "build"

		buildTasks tasks, process.cwd()

		# Run post installation scripts
		if scaffoldConfig.scripts and scaffoldConfig.scripts.postinstall?
			runConfigCommand(scaffoldConfig.scripts.postinstall, project.path)


	# Run any other scripts for the project
	runScripts = ->

		file = ReadConfig process.cwd()

		if file.scripts
			for action of file.scripts
				if action isnt 'preinstall' or
					action isnt 'postinstall' or
					action isnt 'custom'
						runConfigCommand(file.scripts[action], process.cwd())


		# Before compiling, remove the nspignore folder
		Fs.remove(Path.join(process.cwd() + '/norma-ignore') )

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
		Fs.copySync(project.path, process.cwd())


	# Save config
	Fs.writeFileSync(
		Path.join(process.cwd(), fileName)
		JSON.stringify(scaffoldConfig, null, 2)
	)


	# Do post scripts things here
	runScripts()
