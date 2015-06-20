
Chokidar = require "chokidar"
Anymatch = require "anymatch"
EventEmitter = require("events").EventEmitter

# comptability with existing gulp 3.0 events
mapEvents = (event) ->
  switch event
    when "add" then return "added"
    when "unlink" then return "deleted"
    when "change" then return "changed"


module.exports = (glob, opts, cb) ->

  out = new EventEmitter()

  if typeof opts is "function"
    cb = opts
    opts = {}

  opts or= {}

  if typeof opts.ignoreInitial isnt "boolean"
    opts.ignoreInitial = true

  watcher = Chokidar.watch glob, opts

  nomatch = true
  filteredCbs = []

  # all
  watcher.on "all", (event, path, stats) ->

    event = mapEvents event

    if not event or not path
      return

    nomatch = false
    outEvent =
      type: event
      path: path

    if stats
      outEvent.stats = stats


    out.emit "change", outEvent

    filteredCbs.forEach (pair) ->

      if pair.filter(path)
        pair.cb()


    cb and cb()


  # ready
  watcher.on "ready", ->
    if nomatch
      out.emit "nomatch"

    out.emit "ready"

  watcher.on "error", out.emit.bind(out, "error")

  out.add = (glob, cb) ->

    if cb
      filteredCbs.push({
        filter: Anymatch(glob)
        cb: cb
      })

    watcher.add glob
    return watcher

  out.end = ->
    watcher.close()
    out.emit("end")
    return watcher

  out.remove = watcher.unwatch.bind watcher
  out._watcher = watcher



  return out
