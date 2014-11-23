###

  This script runs in a directory that is empty.  The name and scaffold template
  are passed in.  It copies the contents of the scaffold directory to this
  directory and then runs scripts.

  TODO: Need to set up questions regarding custom build

###


Fs       = require "fs-extra"
Path     = require "path"
Exec     = require('child_process').exec
Argv     = require('minimist')( process.argv.slice(2) )
ReadConfig   = require "./read-config"
ExecCommand = require "./execute-command"
BuildTasks = require './../methods/build'


module.exports = (project, name) ->

  # name = "My awesome project" or some other cool name
  # project = { path: '/Users/.../Norma/scaffolds/ee-multisite',
  #   name: 'ee-multisite',
  #   type: 'folder',
  #   children: [Object] }

  # See if a config file already exists (for local files)
  configName = "#{Tool}.json"
  configExists = Fs.existsSync Path.join(project.path, configName)

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
      message: "Write custom config items in this file"
      tasks: {}
      processes: {}

  ###

    Run preinstall command

    @note

      Thoughts on being able to make this an async task with a callback?
      Or perhaps promise based. I'm not really sure how to do this.
      Right now the move can happen while other scripts are being run.
      We need to figure out a way to have the move be delayed until after
      any preinstall scripts are ready. I might kill this feature until
      we can figure this out. We can get insight into how npm is doing it
      for their system here:

      [https://github.com/npm/npm/blob/master/lib/utils/lifecycle.js]

      If we restrict the type of scripts to just process scripts we
      can successfully register a fallback. In fact if we spawn a child
      process and run node <script name> then we should be able to do the
      same type of callback if it is a file.


  ###
  # if scaffoldConfig.scripts and scaffoldConfig.scripts.preinstall?
  #   ExecCommand(scaffoldConfig.scripts.preinstall, project.path)

  if project.path isnt process.cwd()

    # Copy over all of the things
    Fs.copySync project.path, process.cwd()

  # Save config
  Fs.writeFileSync(
    Path.join(process.cwd(), configName)
    JSON.stringify(scaffoldConfig, null, 2)
  )

  if scaffoldConfig.scripts

    for action of scaffoldConfig.scripts

      if action isnt 'preinstall' and action isnt 'postinstall' and
        action isnt 'custom'

          ExecCommand scaffoldConfig.scripts[action], process.cwd()

  # Before compiling, remove the nspignore folder
  Fs.remove Path.join(process.cwd(), '/norma-ignore')
  BuildTasks [ "build" ], process.cwd()

  # Run post installation scripts
  if scaffoldConfig.scripts and scaffoldConfig.scripts.postinstall

    ExecCommand(scaffoldConfig.scripts.postinstall, project.path)
