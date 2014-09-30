###

	This is the main routing file for commands

###

# Require the needed packages
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"


# Logger is where console output info for the CLI is stored
Logger = require "../logging/logger"


module.exports = (env) ->


	# VARIABLES ----------------------------------------------------------------

	# Get the package.json for nsp info
	cliPackage = require "../../package"

	# Bind tasks to variable for easy passing
	task = Flags._



	# UTILITY ------------------------------------------------------------------

	# Check for version flag and report version
	if Flags.v or Flags.version

		console.log "nsp CLI version", Chalk.cyan(cliPackage.version)

		# exit
		process.exit 0

	# set default task to watch if running bare
	if task.length is 0
		task = ["watch"]

	###

		If only one task argument is passed, turn it into a string.
		We do this to be able to type check in tasks for empty commands.
		This may not be the best way to do it but I'm fond of it
		~ @jbaxleyiii

	###
	if task.length is 1
		task = task[0]

	# See if help or h task is trying to be run
	if Flags.help or Flags.h
		Logger.logInfo(cliPackage)

		process.exit 0


	###

		Change directory to where nsp was called from.
		This allows the tool to work is way up the tree to find an nspfile.

	###
	if process.cwd() isnt env.cwd
		process.chdir env.cwd
		console.log(
			Chalk.cyan("Working directory changed to", Chalk.magenta(env.cwd))
		)



	# TASKS -------------------------------------------------------------------

	if task is "create" or task[0] is "create"
		create = require "./scaffold/create"
		create(task, env)


	if task is "init" or task[0] is "init"
		init = require "./scaffold/init"
		init(task, env)


	if task is "build" or task[0] is "build"
		runTasks = require "./tasks"
		runTasks(task, process.cwd())


	if task is "watch" or task[0] is "watch"
		serve = require "./serve"
		serve(task, env)


	if task is "config" or task[0] is "config"
		manage = require "../config/manage"
		manage(task, env)
