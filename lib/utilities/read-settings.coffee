
Fs    = require "fs-extra"
Nconf = require "nconf"
Path = require "path"


module.exports = ->
  # CONFIG-TYPE -----------------------------------------------------------

  ###

    If command has been run with --global or --g then
    swich to the global config, otherwise use current
    directory level to create and use config (local)

  ###

  global = Path.resolve __dirname, "../../", ".#{Tool}"
  local = Path.join process.cwd(), ".#{Tool}"


  # See if a config file already exists (for global files)
  globalConfigExists = Fs.existsSync global

  # See if a config file already exists (for local files)
  localConfigExists = Fs.existsSync local


  # CONFIG-CREATE -------------------------------------------------------------

  # If no file, then we create a new one with some preset items
  if !globalConfigExists
    config =
      path: global

    # Save config
    Fs.writeFileSync(
      global
      JSON.stringify(config, null, 2)
    )

  # If no file, then we create a new one with some preset items
  if !localConfigExists
    config =
      path: local

    # Save config
    Fs.writeFileSync(
      local
      JSON.stringify(config, null, 2)
    )



  # CONFIG-SET ---------------------------------------------------------------


  Nconf.use "memory"
    .file "user", local
    .file "global", global

  get = (getter) ->
    return Nconf.get getter


  return Nconf.get()

  # set = (setter, value) ->
  #   return Nconf.set setter, value



  module.exports.get = get
# module.exports.set = set
