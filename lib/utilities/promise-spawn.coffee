Spawn = require("child_process").spawn
Q = require "kew"
_ = require "underscore"

Norma = require "./../norma"

module.exports = (command, args, cwd) ->

  deferred = Q.defer()
  cwd or= process.cwd()
  if not command

    deferred.reject "must include a command"
    return deferred

  cleaned = (if Array.isArray(args) then args else args.split(" "))
  args = (if args then cleaned else [])


  child = Spawn(
    command
    args
    cwd: cwd
  )

  child.stdout.on "data", (data) ->
    msg = data.toString()

    Norma.emit "message", msg
    return

  child.stderr.on "data", (data) ->
    msg = data.toString()

    Norma.emit "error", msg
    return

  child.on "error", (error) ->

    deferred.reject(
      "#{command} #{args.join(" ")} in #{cwd} errored with #{error.message}"
    )
    return

  child.on "exit", (code) ->

    if code isnt 0
      deferred.reject(
        "#{command} #{args.join(" ")} in #{cwd} exited with #{code}"
      )
    else
      deferred.resolve("ok")
    return

  return deferred
