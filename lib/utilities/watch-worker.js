

var Chokidar = require("chokidar")
    EventEmitter = require("events").EventEmitter;

var mapEvents = function(event) {
  switch (event) {
    case "add":
      return "added";
    case "unlink":
      return "deleted";
    case "change":
      return "changed";
  }
};

var watch = function(glob, opts) {

  var nomatch, out, watcher;

  out = new EventEmitter();

  opts || (opts = {});
  if (typeof opts.ignoreInitial !== "boolean") {
    opts.ignoreInitial = true;
  }

  watcher = Chokidar.watch(glob, opts);
  nomatch = true;


  watcher.on("all", function(event, path, stats) {

    var outEvent;
    event = mapEvents(event);
    if (!event || !path) {
      return;
    }

    nomatch = false;
    outEvent = {
      type: event,
      path: path
    };

    if (stats) {
      outEvent.stats = stats;
    }

    out.emit("change", outEvent);

    return
  });

  watcher.on("ready", function() {

    if (nomatch) {
      out.emit("nomatch");
    }

    return out.emit("ready");
  });

  watcher.on("error", out.emit.bind(out, "error"));

  out.end = function() {
    watcher.close();
    out.emit("end");
    return watcher;
  };

  out.remove = watcher.unwatch.bind(watcher);

  out._watcher = watcher;
  return out;
};


process.once("message", function(msg) {

  var watcher = watch(msg.path, msg.opts, msg.cb);

  // monkey patch the event emitter to pipe it through to the parent process
  var oldEmit = watcher.emit

  watcher.emit = function() {
    var args = Array.prototype.slice.call(arguments);
    process.send(args);
    oldEmit.apply(watcher, arguments);
  }


});

process.on("disconnect", function() {
  return process.exit();
});
