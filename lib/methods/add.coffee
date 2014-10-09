Path = require "path"
Exec = require("child_process").exec
Chalk = require "chalk"
Flags = require("minimist")( process.argv.slice(2) )
Ghdownload = require "github-download"
ExecCommand = require "./../utilities/execute-command"

module.exports.api = [
	{
		command: "<git-repo> --scaffold"
		description: "install global scaffold"
	}
	{
		command: "<package-name>"
		description: "install local package"
	}
	{
		command: "<package-name> --global"
		description: "install global package"
	}
]

module.exports = (tasks, cwd) ->


	# LOGS -------------------------------------------------------------------

	# User tried to run `norma add` without argument
	if tasks.length is 1

		console.log Chalk.red "Please specify a task or --scaffold <repo>"

		process.exit 0


	# SCAFFOLD ---------------------------------------------------------------

	if Flags.scaffold

		# Clean out args to find git repo
		tasks[1] = Flags.scaffold
		finalLoc = tasks[1].split "norma-"
		finalLoc = finalLoc[1]

		# Get final resting place of global scaffolds
		scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", finalLoc

		# Download from github
		Ghdownload(
		  tasks[1]
			scaffoldLocation + "/"
		).on "end", ->
		  Exec "tree", (err, stdout, sderr) ->
		    console.log "Scaffold ready!"
		    return

		return


	# PACKAGES ---------------------------------------------------------------

	action = "npm i --save #{Tool}-#{tasks[1]}"


	if Flags.global
		# Do work on users global norma
		process.chdir Path.resolve __dirname, "../../"

		ExecCommand(
			action
			process.cwd()
		,
			->
				# Change back to project cwd for further tasks
				process.chdir cwd
				process.exit 0
		)

	else
		ExecCommand(
			action
			process.cwd()
		,
			->
				process.exit 0
		)
