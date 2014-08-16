
argv = require('minimist')( process.argv.slice(2) )
chalk = require 'chalk'

logger = require '../logging/logger'


module.exports = (env) ->

	cliPackage = require '../../package'

	versionFlag = argv.v or argv.version
	task = argv._


	# Check for version flag
	if versionFlag

		console.log 'nsp CLI version', chalk.cyan(cliPackage.version)

		process.exit 0


	if task.length is 1
		task = task[0]

	else if task.length is 0

		logger.logInfo(cliPackage)

		process.exit 0


	# Print info if needed
	if task is 'i' or task is 'info'

		logger.logInfo(cliPackage)

		process.exit 0


	# Change directory to where nsp was called from
	if process.cwd() isnt env.cwd
		process.chdir env.cwd
		console.log(
			chalk.cyan('Working directory changed to', chalk.magenta(env.cwd))
		)


	if task is 'build' or task[0] is 'build'
		runTasks = require './tasks'
		runTasks(task, env)


	if task is 'init' or task[0] is 'init'
		scaffold = require './scaffold/init'
		scaffold(task, env)

	if task is 'watch' or task[0] is 'watch'
		serve = require './serve'
		serve(task, env)
		
