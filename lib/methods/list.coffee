Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"

MapTree = require("./../utilities/directory-tools").mapTree
PkgeLookup = require "./../utilities/package-lookup"



module.exports = (tasks, cwd, scaffolds) ->

  listTypes = (folderLocation, type) ->

    scaffolds = MapTree(folderLocation).children

    scaffoldList = (
      scaffold.name for scaffold in scaffolds when scaffold.type is type
    )

    return scaffoldList


  if Norma.scaffold or Norma.scaffolds or scaffolds

    scaffoldLocation = Path.join Norma.userHome, "scaffolds"

    types = listTypes scaffoldLocation, "folder"

    if types.length
      Norma.emit "message", types
    else
      Norma.emit "message", "No scaffolds installed"

    return types

  else
    pkgs = _.uniq(Norma.packages).join ", "
    Norma.emit "message", pkgs

    return _.uniq(Norma.packages)




# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "list all installed packages"
  }
  {
    command: "--scaffold"
    description: "list all available scaffolds"
  }
]
