_				= require("lodash")
inquirer = require("inquirer")
fs			 = require("fs")
chalk		= require("chalk")
mapTree = require("../dirTree").mapTree
path = require("path")
build = require("./build")
removeTree = require("../dirTree").removeTree



module.exports = (tasks, env) ->

	scaffolds = path.join(path.dirname(fs.realpathSync(__filename))) + "/../../../scaffolds"
	scaffolds = mapTree scaffolds
	scaffoldNames = new Array

	for scaffold in scaffolds.children
		scaffoldNames.push(scaffold.name)


	cwdFiles = _.remove(fs.readdirSync(env.cwd), (file) ->
		file.substring(0, 1) isnt "."
	)

	chooseProject = (project) ->
		projects = scaffolds.children.filter( (val) ->
			return val.name is project;
		)

		if projects.length is 1
			build(projects[0])
		else
			console.log(
				chalk.red('That scaffold template is not found, try these:')
			)
			for name in scaffoldNames

				if _i is scaffoldNames.length
					console.log(chalk.cyan(name) )
				else
					console.log(chalk.cyan(name + '\n') )
			console.log(chalk.grey('or'))
			console.log(chalk.red('run `nsp init`'))


	startInit = () ->

		inquirer.prompt
			type: "list"
			message: "What type of project do you want to build?"
			name: "projectType"
			choices: scaffoldNames
			default: false
		, (answer) ->
			chooseProject answer.projectType



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
