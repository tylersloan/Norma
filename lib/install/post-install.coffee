
Chalk = require "chalk"
Inquirer = require "inquirer"

Settings = require "./../utilities/read-settings"

Settings.get()

# remove memory settings to use just global for intial questions
Settings._.remove "memory"
Settings._.remove "local"

name = Settings.get "user:name"
browser = Settings.get "user:browser"
editor = Settings.get "user:editor"

if name or browser or editor
  return


msg = "Ø Thanks for installing me! \n" +
  "Ø Before we get started, I have a few questions to know " +
  "how to help you the best..."

console.log Chalk.green msg

Inquirer.prompt([
  {
    type: "input"
    message: "What would you like to be called (name)?"
    name: "name"
  }
  {
    type: "input"
    message: "What browser do you prefer to develop with?"
    name: "browser"
  }
  {
    type: "input"
    message: "What editor do you prefer to develop with?"
    name: "editor"
  }

  ],
  (answer) ->


    for question of answer
      if answer[question]
        # Save config with value
        Settings.set "user:#{question}", answer[question]


    # Save the configuration object to file
    Settings._.save (err, data) ->
      throw err if err

)
