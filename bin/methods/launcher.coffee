path = require 'path'
fs = require 'fs'
_ = require 'lodash'
argv = require('minimist')( process.argv.slice(2) )
gulp = require 'gulp'
chalk = require 'chalk'

gulpFile = require( path.join(path.dirname(fs.realpathSync(__filename)), '../../gulpfile.js'))


logger = require '../logging/logger'

module.exports = (env) ->

	cliPackage = require '../../package'

	versionFlag = argv.v or argv.version

	allowedTasks = [
		'init'
		'build'
		'i'
		'info'
		'test'
	]

	task = argv._

	numTasks = task.length


	# Check for version flag
	if versionFlag

		console.log 'nsp CLI version', chalk.cyan(cliPackage.version)

		process.exit 0


	# Log info if no tasks are passed in
	if !numTasks

		logger.logInfo(cliPackage)

		process.exit 0


	# Warn if more than one tasks has been passed in
	if numTasks > 1 and numTasks[0] isnt "init"

		console.log chalk.red('\nOnly one task can be provided. Aborting.\n')

		logger.logTasks()

		process.exit 0


	# Print info if needed
	if task is 'i' or task is 'info'

		logger.logInfo(cliPackage)

		process.exit 0


	# Check if task is valid
	if _.indexOf(allowedTasks, task) < 0
		console.log(
			chalk.red(
				'\nThe provided task "' + task + '" was not recognized. Aborting.\n'
			)
		)

		logger.logTasks()

		process.exit 0



	# Change directory to where nsp was called from
	if process.cwd() isnt env.cwd
		process.chdir env.cwd
		console.log(
			chalk.cyan('Working directory changed to', chalk.magenta(env.cwd))
		)


	# Start the task through Gulp
	process.nextTick( ->
		gulp.start.apply gulp, [task]
	)
