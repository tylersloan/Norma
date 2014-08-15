_				= require("lodash")
inquirer = require("inquirer")
fs			 = require("fs")
chalk		= require("chalk")
dirTree = require("./dirTree")
path = require("path")


rmDir = (dirPath, keep) ->
	try
		files = fs.readdirSync(dirPath)
	catch e
		return

	if files.length > 0
		i = 0

		while i < files.length

			filePath = dirPath + "/" + files[i]

			if fs.statSync(filePath).isFile()
				fs.unlinkSync filePath
			else
				rmDir filePath

			i++

	unless keep then fs.rmdirSync dirPath
	return

module.exports = (tasks, env) ->

	scaffolds = path.join(path.dirname(fs.realpathSync(__filename))) + "/../../scaffolds"
	scaffolds = dirTree scaffolds

	cwdFiles = _.remove(fs.readdirSync(env.cwd), (file) ->
		file.substring(0, 1) isnt "."
	)

	startInit = () ->

		inquirer.prompt
			type: "list"
			message: "What type of project do you want to build?"
			name: "projectType"
			choices: ['multisite', 'core-js plugin', 'core-css object', 'ee plugin']
			default: false
		, (answer) ->
			console.log answer.projectType
			for scaffold in scaffolds.children
				if scaffold.name is answer.projectType
					console.log scaffold



	if cwdFiles.length > 0
		inquirer.prompt
			type: "confirm"
			message: "Initializing will empty the current directory. Continue?"
			name: "override"
			default: false
		, (answer) ->

			if answer.override

				# Make really really sure that the user wants this
				inquirer.prompt
					type: "confirm"
					message: "Removed files are gone forever. Continue?"
					name: "overridconfirm"
					default: false
				, (answer) ->

					if answer.overridconfirm

						# Clean up directory
						console.log chalk.grey("Emptying current directory")
						rmDir(env.cwd, true)
						startInit()

					else
						process.exit 0

			else
				process.exit 0
	else
		startInit()
