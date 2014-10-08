Path = require "path"
Fs = require "fs-extra"
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"

MapTree = require("./../utilities/directory-tools").mapTree
PkgeLookup = require "./../utilities/package-lookup"

# norma add --scaffold <git repo>
module.exports = (tasks, cwd) ->

	listTypes = (folderLocation, type) ->

		fileLoc = Path.dirname Fs.realpathSync(__filename)
		scaffolds = Path.join fileLoc, folderLocation
		scaffolds = MapTree(scaffolds).children

		scaffoldList = (
			scaffold.name for scaffold in scaffolds when scaffold.type is type
		)

		return scaffoldList


	if Flags.scaffold or Flags.scaffolds

		console.log listTypes "/../../scaffolds", "folder"

	else

		# list = listTypes "/../../tasks", "file"
		#
		# cleanedList = (
		# 	name.split(".")[0] for name in list when name isnt ".DS_Store"
		# )
		#
		# console.log cleanedList

		console.log Chalk.red "Need to build out list for packages still"

		# packages = PkgeLookup tasks, (Path.resolve __dirname, "../../")
		# console.log packages
