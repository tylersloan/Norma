###

	Helper logging functions.
	This file contains basic information about the build tool
	It might be better off breaking it up into seperate logging functions
	Need to watch and see how the tool grows first
	~ @jbaxleyiii

###

# require packages
Chalk = require 'chalk'


###

	@DEPRECEATED

	New API's need to be finalized and then this file needs to be updated

###
logTasks = ->
	console.log('Please use one of the following tasks:\n')
	console.log(
		Chalk.cyan('init'),
		'\t\tAdd the boilerplate files to the current directory'
	)
	console.log(
		Chalk.magenta('build'),
		'\t\tBuild the project\n',
		Chalk.grey('--production'),
		'\tMake a production ready build\n',
		Chalk.grey('--serve'),
		'\tServe the files on a static address\n',
		Chalk.grey('--open'),
		'\tOpen up a browser for you (default Google Chrome)\n',
		Chalk.grey('--edit'),
		'\tOpen the files in your editor (default Atom)\n',
	)
	console.log(
		Chalk.magenta('i'),
		'or',
		Chalk.magenta('info'),
		'to print out this message'
	)
	console.log(
		Chalk.magenta('-v'),
		'or',
		Chalk.magenta('--version'),
		'to print out the version of your nsp CLI\n'
	)


# PrettyPrint the NewSpring Church Logo -> https://newspring.cc
logInfo = (cliPackage) ->
	console.log(Chalk.green(
		'\n' +
		'\'     .ttttttttttttttttt.    \n' +
		'\'   :1111111111111111111111   \n' +
		'\' .111111111111111111111111i  \n' +
		'\'.1111111           .1111111;\n' +
		'\'t1111111     .1.     t11111t\n' +
		'\'11111111     111     1111111\n' +
		'\'t1111111     111     1111111\n' +
		'\' 1111111     111     1111111\n' +
		'\'  t1111111111111111111111111\n' +
		'\'    i11111111111111111111111\n',
		Chalk.grey('\nv' + cliPackage.version + '\nA worry-free workflow\n' +
		'➳  //newspring.io\n' +
		'\n' +
		'-------\n')
	))

	logTasks()


# Expose the logging functions
module.exports.logInfo = logInfo
module.exports.logTasks = logTasks
