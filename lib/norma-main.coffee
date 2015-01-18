# To see an extended Error Stack Trace, uncomment
# Error.stackTraceLimit = 9000;

# Require the needed packages
Chalk = require "chalk"
Liftoff = require "Liftoff"
Flags = require("minimist")( process.argv.slice(2) )

Launcher = require "./utilities/launcher"



# CLI configuration ---------------------------------------------------------

cli = new Liftoff({
  name: Tool
})


# Launch CLI -----------------------------------------------------------------

###

  Invoke acts as the main router file of the commands to be run

###
invoke = require("./utilities/launcher")

# Launch the CLI (Command Line Interface)
cli.launch(
  cwd: Flags.cwd
  configPath: Flags[Tool]
  verbose: Flags.verbose
  extensions: require('interpret').jsVariants
  ,
    invoke
)
