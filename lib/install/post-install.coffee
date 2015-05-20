if process.env.CI or process.env.NODE_ENV isnt "development"
  return

Inquirer = require "inquirer"


# Temporary shim to move ~/norma to ~/.norma
Fs = require "fs-extra"
Path = require "path"
Rimraf = require "rimraf"
Home = require "user-home"

if Home
  homePath = Path.resolve Home, ".norma"
else
  homePath = Path.resolve __dirname, "../../.norma"

oldHome = Path.resolve homePath, "../norma"

if Fs.existsSync oldHome

  if Fs.existsSync homePath
    existingFile = Fs.lstatSync homePath
    if not existingFile.isDirectory()
      Rimraf.sync homePath
    else
      # things already moved over
      return

  Fs.mkdirSync homePath
  Fs.copySync oldHome, homePath
  Rimraf.sync oldHome

# End shim



Norma = require "../index"

# name = Norma.getSettings.get "user:name"
# browser = Norma.getSettings.get "user:browser"
# editor = Norma.getSettings.get "user:editor"

# console.log name, browser, editor

# if name or browser or editor
#   return
#
# Norma.log({
#   message: "Thanks for installing me! \n" +
#     "Before we get started, I have a few questions to know " +
#     "how to help you the best..."
#   color: "green"
# })
#
# Inquirer.prompt([
#   {
#     type: "input"
#     message: "What would you like to be called (name)?"
#     name: "name"
#   }
#   {
#     type: "input"
#     message: "What browser do you prefer to develop with?"
#     name: "browser"
#   }
#   {
#     type: "input"
#     message: "What editor do you prefer to develop with?"
#     name: "editor"
#   }
#
#   ],
#   (answer) ->
#
#
#     for question of answer
#       if answer[question]
#         # Save config with value
#         Norma.getSettings.set "user:#{question}", answer[question]
#
#
#     # Save the configuration object to file
#     Norma.getSettings._.save (err, data) ->
#       throw err if err
#
# )
