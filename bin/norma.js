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
  events: EventEmitter,
  domain: Domain,
  prefix: "Ø ",
  packages: []
}


// EVENTS ---------------------------------------------------------------

// Event shorthand
Norma.subscribe = function(evt, cb) {
  return Norma.events.on(evt, cb);
};

Norma.emit = function(evt, obj) {
  return Norma.events.emit(evt, obj);
};

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

Domain.on("error", function(err){

  // err.level = "crash";

  // handle the error safely
  Norma.events.emit("error", err);

});

// Domain.add(Norma.events)

// APPLICATION ----------------------------------------------------------

process.on('SIGINT', function() {
  Norma.stop();
});

Domain.run(function(){

  // Require main file
  require("../lib/" + Tool + "-main");

});
