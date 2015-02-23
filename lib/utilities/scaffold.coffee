###

  This script runs in a directory that is empty.  The name and scaffold template
  are passed in.  It copies the contents of the scaffold directory to this
  directory and then runs scripts.

  TODO: Need to set up questions regarding custom build

###


Fs       = require "fs"
Path     = require "path"
Q        = require "kew"


Norma = require "./../norma"
ReadConfig   = require "./read-config"
ExecCommand = require "./execute-command"
CopySync = require("./directory-tools").copySync
RemoveSync = require("./directory-tools").removeSync


doAfterPreInstall = (proj, _config, cwd, promise) ->

  if !cwd then cwd = process.cwd()

  if proj.path isnt cwd
    # Copy over all of the things
    CopySync proj.path, cwd


  # Save config
  Fs.writeFileSync(
    Path.join(cwd, "norma.json")
    JSON.stringify(_config, null, 2)
  )

  if !Fs.existsSync( Path.join(cwd, "package.json") )

    defaultPackageData =
      name: _config.name
      version: "0.0.0"
      description: ""
      main: "index.js"
      scripts:
        test: "echo \"Error: no test specified\" && exit 1"
      author: ""
      license: "MIT"


    Fs.writeFile(
      Path.join(cwd, "package.json")
      JSON.stringify(defaultPackageData, null, 2)
    )


  clean = ->
    # Before compiling, remove the nspignore folder
    RemoveSync Path.join(cwd, "/norma-ignore")

    Norma.build([], cwd)
      .then( ->
        promise.resolve("ok")
      )
      .fail( (err) ->
        promise.reject err
      )


  # Run post installation scripts
  if _config.scripts and _config.scripts.postinstall

    ExecCommand(_config.scripts.postinstall, cwd, ->
      clean()
    )

  else
    clean()




module.exports = (project, name, cwd) ->

  created = Q.defer()

  if !project
    created.reject("no project passed")
    return created

  # name = "My awesome project" or some other cool name
  # project = { path: "/Users/.../Norma/scaffolds/ee-multisite",
  #   name: "ee-multisite",
  #   type: "folder",
  #   children: [Object] }

  # See if a config file already exists (for local files)
  configExists = Fs.existsSync Path.join(project.path, "norma.json")

  ###

    This portions saves the name of the project to the norma. I wonder
    if there is a way to insert the name at the top. Ordering of keys
    will be needed for more complex initializations as well

  ###
  if configExists

    scaffoldConfig = ReadConfig project.path
    scaffoldConfig.name = name

  else

    scaffoldConfig =
      name: name
      tasks: {}


  if scaffoldConfig.scripts and scaffoldConfig.scripts.preinstall?

    ExecCommand(scaffoldConfig.scripts.preinstall, project.path, ->
      doAfterPreInstall project, scaffoldConfig, cwd, created
    )

  else

    doAfterPreInstall project, scaffoldConfig, cwd, created

  return created
