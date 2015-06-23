Path = require "path"
Fs = require "fs"
Chalk = require "chalk"
_ = require "underscore"



module.exports = (tasks, cwd, scaffolds) ->

  Norma = require "./../norma"

  listTypes = (folderLocation, type) ->

    MapTree = require("./../utilities/directory-tools").mapTree
    
    scaffolds = MapTree(folderLocation).children

    scaffoldList = (
      scaffold.name for scaffold in scaffolds when scaffold.type is type
    )


    return scaffoldList


  if Norma.scaffold or Norma.scaffolds or scaffolds

    scaffoldLocation = Path.join Norma._.userHome, "scaffolds"


    types = listTypes scaffoldLocation, "folder"

    if types.length
      Norma.log types.join(", ")
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
