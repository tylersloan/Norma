Path = require "path"
Fs = require "fs"
_ = require "underscore"
Norma = require "./../norma"

CopySync = require("./directory-tools").copySync

module.exports = (list, callback) ->

  if not list
    callback()

  # ensure our caching directory is here
  cacheDir = Path.join Norma._.userHome, "packages"

  if not Fs.existsSync cacheDir
    Fs.mkdirSync cacheDir


  packages = list.split(" ")
  # Need to only cache norma- packages
  # TODO
  Norma.log "caching #{list} for future use"

  globalModules = Path.join Norma._.userHome, "node_modules"
  localModules = Path.join process.cwd(), "node_modules"


  for pkge in packages

    pkgePath = Path.join(localModules, pkge)

    if Fs.existsSync( Path.join(globalModules, pkge) )
      pkgePath = Path.join(globalModules, pkge)

    packageJSON = Path.join(pkgePath, "package.json")

    if not Fs.existsSync packageJSON
      continue

    version = require(packageJSON).version
    versionPath = Path.join(cacheDir, pkge, version)

    # ensure package dir
    if not Fs.existsSync( Path.join(cacheDir, pkge) )
      Fs.mkdirSync Path.join(cacheDir, pkge)

    # ensure version dir and copy
    if not Fs.existsSync( versionPath )
      Fs.mkdirSync versionPath

      CopySync pkgePath, versionPath



  if typeof callback is "function"
    callback null
