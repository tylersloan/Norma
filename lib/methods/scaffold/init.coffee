_				= require("lodash")
inquirer = require("inquirer")
fs			 = require("fs-extra")
chalk		= require("chalk")
mapTree = require("../directory-tools").mapTree
path = require("path")
build = require("./build")
removeTree = require("../directory-tools").removeTree



module.exports = (tasks, env) ->

	###

		Get all available scaffolds

		@todo - need to build out api to add custom scaffolds
			should be similar to nsp add --scaffold <git repo>

	###
	fileLoc = path.dirname(fs.realpathSync(__filename))
	scaffolds = path.join fileLoc, "/../../../scaffolds"
	scaffolds = mapTree scaffolds

	# Add in custom option
	scaffolds.children.push custom =
		path: process.cwd()
		name: 'custom'
		type: 'folder'
		children: []

	# Create list of scaffold names for prompt
	scaffoldNames = new Array
	scaffoldNames = (scaffold.name for scaffold in scaffolds.children)

	# Generate list of current files in directory
	cwdFiles = _.remove fs.readdirSync(env.cwd), (file) ->
		file.substring(0, 1) isnt "."


	chooseProject = (project, projectName) ->

		# Faster filter method
		projects = (proj for proj in scaffolds.children when proj.name is project)

		# If we found a project, build it
		if projects.length is 1
			build(projects[0], projectName)
		else
			console.log(
				chalk.red('That scaffold template is not found, try these:')
			)
			for name in scaffoldNames
				# Don't add an extra space after the last list
				if (_i + 1) isnt scaffoldNames.length
					console.log(chalk.cyan(name) )
				else
					console.log(chalk.cyan(name + '\n') )


	startInit = ->

		if typeof tasks is 'string'
			inquirer.prompt([
				{
					type: "list"
					message: "What type of project do you want to build?"
					name: "projectType"
					choices: scaffoldNames
				}
				{
					type: "input"
					message: "What do you want your project to be named?"
					name: "projectName"
					default: "My Awesome Project"
				}
			],
				(answer) ->
					chooseProject answer.projectType, answer.projectName
			)

		else
			inquirer.prompt
				type: "input"
				message: "What do you want your project to be named?"
				name: "projectName"
				default: "My Awesome Project"
			,
				(answer) ->

					chooseProject tasks[1], answer.projectName


	# Failsafe to make sure project is empty on creation of new folder
	if cwdFiles.length and tasks is 'create'
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
						removeTree(env.cwd, true)
						startInit()

					else
						process.exit 0

			else
				process.exit 0

	else if typeof tasks is 'string'
		startInit()

	else
		chooseProject(tasks[1])
