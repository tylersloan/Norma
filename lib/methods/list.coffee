Path = require "path"
Fs = require "fs-extra"
Chalk = require "chalk"
_ = require "underscore"

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


  if Norma.scaffold or Norma.scaffolds

    types = listTypes "/../../scaffolds", "folder"
    
    if types.length
      Norma.emit "message", types
    else
      Norma.emit "message", "No scaffolds installed"

  else
    pkgs = _.uniq(Norma.packages).join ", "
    Norma.emit "message", pkgs




# API ----------------------------------------------------------------------

module.exports.api = [
  # {
  #   command: ""
  #   description: "list all installed packages"
  # }
  {
    command: "--scaffold"
    description: "list all available scaffolds"
  }
]
