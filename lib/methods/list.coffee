Path = require "path"
Fs = require "fs-extra"
Flags = require('minimist')( process.argv.slice(2) )

MapTree = require("./directory-tools").mapTree

# norma add --scaffold <git repo>
module.exports = (tasks, cwd) ->

	if Flags.scaffold
		tasks[1] = Flags.scaffold

		fileLoc = Path.dirname Fs.realpathSync(__filename)
		scaffolds = Path.join fileLoc, "/../../scaffolds"
		scaffolds = MapTree(scaffolds).children

		scaffoldList = (
	    scaffold.name for scaffold in scaffolds when scaffold.type is 'folder'
		)

		console.log scaffoldList
