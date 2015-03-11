if process.env.CI or process.env.NODE_ENV isnt "development"
  return


Inquirer = require "inquirer"

Norma = require "../index"

name = Norma.getSettings.get "user:name"
browser = Norma.getSettings.get "user:browser"
editor = Norma.getSettings.get "user:editor"

# console.log name, browser, editor

if name or browser or editor
  return

Norma.log({
  message: "Thanks for installing me! \n" +
    "Before we get started, I have a few questions to know " +
    "how to help you the best..."
  color: "green"
})

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
        Norma.getSettings.set "user:#{question}", answer[question]


    # Save the configuration object to file
    Norma.getSettings._.save (err, data) ->
      throw err if err

)
