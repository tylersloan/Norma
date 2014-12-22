Npm = require "npm"
Inquirer = require "inquirer"
Path = require "path"
Fs = require "fs-extra"
Exec = require("child_process").exec
Nconf = require "nconf"
Chalk = require "chalk"

ExecCommand = require "./../utilities/execute-command"


module.exports = ->


  # This should only run locally
  if process.env.NODE_ENV isnt "production"

    # SETTINGS -------------------------------------------------------------

    global = Path.resolve __dirname, "../../", ".norma"

    # See if a config file already exists (for global files)
    globalConfigExists = Fs.existsSync global

    # If no file, then we create a new one with some preset items
    if !globalConfigExists
      config =
        path: global

      # Save config
      Fs.writeFileSync(
        global
        JSON.stringify(config, null, 2)
      )

    Nconf.file "global", global


    if Nconf.get "no-local-tld"
      return


    # INSTALL --------------------------------------------------------------

    # This needs to look up node root but I can't figure out how yet
    tld = Path.join "/usr/local/lib/node_modules", "local-tld"

    if !Fs.existsSync tld

      name = Chalk.magenta "Install:"
      message = "In order to maintain local top level domains, " +
        "Norma uses a package called local-tld to reroute requests" +
        "to your application. This requires sudo access so Norma will " +
        "ask for your password. This isn't stored in Norma, only in local-tld"


      console.log name, message


      # SETUP --------------------------------------------------------------

      Inquirer.prompt([
        {
          type: "list"
          message: "Would you like to add domain support?"
          name: "domain"
          choices: ["yes", "no"]
        }

        ],
        (answer) ->
          if answer.domain is "yes"

            ExecCommand(
              "npm i -g local-tld"
              process.cwd()
            )


            name = Chalk.magenta "Log:"

            console.log name, "Installing...."

          else

            name = Chalk.magenta "Log:"

            console.log name, "will not install local-tld"

            Nconf.set "no-local-tld", true

            Nconf.save (err) ->
              throw err if err

      )
