
EventEmitter = require("events").EventEmitter
Fork = require("child_process").fork
Path = require "path"


class Watcher

  constructor: (glob, opts, cb) ->

    self = @
    self.glob = glob
    self.opts = opts
    self.cb = cb

    self.events = new EventEmitter()

    self._startChild()


  _startChild: ->

    self = @

    if self.child
      return

    self.child = Fork(Path.join(__dirname, "watch-worker"))

    self.child.send({
      path: self.glob
      opts: self.opts
      cb: self.cb
    })

    self.child.on("message", (message) ->
      self.events.emit.apply(self.events, message)
    )

    self.child.on("error", (error) ->
      self.events.emit "error", error
    )


    # restart on exit
    self.child.on("exit", (exit, signal) ->
      if self.closing
        self.closing = false
        self.closed = true

      self.events.emit "watcher-dead", self.child.pid, exit, signal
      self.child = null
      console.log exit, signal, "create new watcher"
      # self._startChild()

    )

  end: (cb) ->
    self = @

    if self.child
      self.closing = true

    if cb
      self.child.on("exit", cb)

      self.child.kill()

      return

    if cb then cb null




module.exports = (path, opts, cb) ->

  if typeof opts is "function"
    cb = opts
    opts = {}

  watcher = new Watcher(path, opts, cb)

  watcher.events.on("all", (event, path, stats) ->
    console.log event
  )

  watcher.events.on "ready", cb

  return watcher
