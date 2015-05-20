
Flags = require("minimist")( process.argv.slice(2) )

Norma = require "./../norma"


module.exports = (Norma) ->

  # Mode utilities
  link = (string, key) ->
    Norma[string] = Flags[key]
    return

  # settingsLink = (key) ->
  #
  #   try
  #     if Norma.getSettings.get "modes:#{key}"
  #       Norma[key] = true
  #   catch e


  # MODES -------------------------------------------------------------------

  # process var
  if process.env.NODE_ENV is "production"
    Norma.production = true
  else
    Norma.development = true


  # settings vars
  # modes = ["production", "development", "verbose", "silent", "debug"]
  # settingsLink mode for mode in modes



  # argugment vars (flags)
  for key of Flags
    if !Norma[key]
      Norma[key] = Flags[key]

    switch key
      when "g"
        link "global", key
      when "v"
        link "version", key
      when "h"
        link "help", key

      when "prod"
        link "production", key
      when "dev"
        link "development", key
      when "stag"
        link "staging", key

      when "s"
        link "silent", key
