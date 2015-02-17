###

  This script runs in a directory that is empty.  The name and scaffold template
  are passed in.  It copies the contents of the scaffold directory to this
  directory and then runs scripts.

  TODO: Need to set up questions regarding custom build

###


Fs       = require "fs"
Path     = require "path"

ReadConfig   = require "./read-config"
ExecCommand = require "./execute-command"
CopySync = require("./directory-tools").copySync
RemoveSync = require("./directory-tools").removeSync


doAfterPreInstall = (project, scaffoldConfig) ->


  if project.path isnt process.cwd()

    # Copy over all of the things
    CopySync project.path, process.cwd()

  # Save config
  Fs.writeFileSync(
    Path.join(process.cwd(), "norma.json")
    JSON.stringify(scaffoldConfig, null, 2)
  )

  if !Fs.existsSync('package.json')

    defaultPackageData =
      name: scaffoldConfig.name
      version: "0.0.0"
      description: ""
      main: "index.js"
      scripts:
        test: "echo \"Error: no test specified\" && exit 1"
      author: ""
      license: "MIT"


    Fs.writeFile 'package.json', JSON.stringify(defaultPackageData, null, 2)


  clean = ->
    # Before compiling, remove the nspignore folder
    RemoveSync Path.join(process.cwd(), '/norma-ignore')

    Norma.run ["build"], process.cwd()


  # Run post installation scripts
  if scaffoldConfig.scripts and scaffoldConfig.scripts.postinstall

    ExecCommand(scaffoldConfig.scripts.postinstall, process.cwd(), ->
      clean()
    )

  else
    clean()


module.exports = (project, name) ->



  # name = "My awesome project" or some other cool name
  # project = { path: '/Users/.../Norma/scaffolds/ee-multisite',
  #   name: 'ee-multisite',
  #   type: 'folder',
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
      doAfterPreInstall project, scaffoldConfig
    )

  else

    doAfterPreInstall project, scaffoldConfig
