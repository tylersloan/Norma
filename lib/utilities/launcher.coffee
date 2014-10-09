###

	This is the main routing file for commands

###

# Require the needed packages
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"


# Logger is where console output info for the CLI is stored
Logger = require "./../logging/logger"


module.exports = (env) ->


	# VARIABLES ----------------------------------------------------------------

	# Get the package.json for nsp info
	cliPackage = require "../../package"

	# Bind tasks to variable for easy passing
	tasks = Flags._



	# UTILITY ------------------------------------------------------------------

	# Check for version flag and report version
	if Flags.v or Flags.version

		console.log "nsp CLI version", Chalk.cyan(cliPackage.version)

		# exit
		process.exit 0

	# set default task to watch if running bare
	if tasks.length is 0
		tasks = ["watch"]


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

	task = require "./../methods/#{tasks[0]}"
	task tasks, env.cwd
