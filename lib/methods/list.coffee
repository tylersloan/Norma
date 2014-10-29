Path = require "path"
Fs = require "fs-extra"
Flags = require("minimist")( process.argv.slice(2) )
Chalk = require "chalk"

MapTree = require("./../utilities/directory-tools").mapTree
PkgeLookup = require "./../utilities/package-lookup"



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

    # # Get any project specific packages (from package.json)
    # projectTasks = PkgeLookup tasks, cwd
    #
    # # Get global packages added to Norma
    # rootGulpTasks = PkgeLookup tasks, Path.resolve(__dirname, "../../")
    #
    # # See if there are any project packages (from norma-packages dir)
    # # Should this check be in the PgkeLookup file?
    # customPackages = Fs.existsSync Path.join(cwd, "#{Tool}-packages")
    #
    # if customPackages
    #
    #   # Look for project specific packages (from norma-packages dir)
    #   customPackages = PkgeLookup tasks, Path.join(cwd, "#{Tool}-packages")
    #
    #   projectTasks = customPackages.concat projectTasks
    #
    #
    # combinedTasks = projectTasks.concat rootGulpTasks
    #
    # console.log rootGulpTasks
    #
    # for task in combinedTasks
    #   for taskKey of task
    #     console.log task[taskKey].name


    # list = listTypes "/../../tasks", "file"
    #
    # cleanedList = (
    #   name.split(".")[0] for name in list when name isnt ".DS_Store"
    # )
    #
    # console.log cleanedList

    console.log Chalk.red "Need to build out list for packages still"

    # packages = PkgeLookup tasks, (Path.resolve __dirname, "../../")
    # console.log packages


# API ----------------------------------------------------------------------

module.exports.api = [
  # {
  #   command: ""
  #   description: "list all available packages"
  # }
  {
    command: "--scaffold"
    description: "list all available scaffolds"
  }
]
