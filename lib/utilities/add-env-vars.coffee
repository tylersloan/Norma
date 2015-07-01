Path = require "path"
Fs = require "fs"
_ = require "underscore"


module.exports = (cwd) ->

  Norma = require "./../norma"

  cwd or= process.cwd()

  config = Norma.config(cwd)
  globalConfig = Norma.config Path.resolve(Norma._.userHome)

  if Fs.existsSync Path.join(cwd, ".norma")
    localSettings = Norma.config Path.join(cwd, ".norma")

  localSettings or= {}
  globalConfig.env or= {}
  config.env or= {}
  localSettings.env or= {}

  env = _.extend globalConfig.env, config.env, localSettings.env


  if env
    for variable, value of env
      process.env[variable] = value
