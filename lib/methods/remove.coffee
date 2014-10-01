Fs = require "fs-extra"
Path = require "path"
ReadConfig = require "./read-config"
Exec = require('child_process').exec
Flags = require('minimist')( process.argv.slice(2) )
RemoveTree = require('./directory-tools').removeTree


# norma add --scaffold <git repo>
module.exports = (tasks, cwd) ->

	if Flags.scaffold
		tasks[1] = Flags.scaffold

		scaffoldLocation = Path.resolve __dirname, "../../scaffolds/", tasks[1]

		RemoveTree scaffoldLocation
