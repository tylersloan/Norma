#!/usr/bin/env node
"use strict";

// Load Coffeescript for node tasks
require("coffee-script/register");

var EventEmitter = new (require("events").EventEmitter)();
var Domain = require("domain").create();
var Path = require("path")


GLOBAL.Tool = "norma"

GLOBAL.Norma = {
  watchStarted: false,
  reloadTasks: [],
  events: EventEmitter
}


// EVENTS ---------------------------------------------------------------

var MapTree = require("./../lib/utilities/directory-tools").mapTree

var loadEvents = function() {

  var events,
  evt,
  eventDir,
  _i,
  _len,
  _ref,
  _results;

  eventDir = Path.resolve(__dirname, "./../lib/events/")

  events = MapTree(eventDir);


  _ref = events.children;
  _results = [];

  for (_i = 0, _len = _ref.length; _i < _len; _i++) {

    evt = _ref[_i];

    if (evt.path) {
      _results.push(require(evt.path)());
    } else {
      _results.push(void 0);
    }

  }

  return _results;
}

loadEvents();


// ERRORS ---------------------------------------------------------------

var NormaEvents = require("../lib/events/error")()

Domain.on("error", function(err){
  // handle the error safely
  err.severity = "crash"

  Norma.events.emit("error", err)
});


// APPLICATION ----------------------------------------------------------
Domain.run(function(){

  // Require main file
  require("../lib/" + Tool + "-main");

});
