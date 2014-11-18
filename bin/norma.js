#!/usr/bin/env node
"use strict";

var EventEmitter = new (require("events").EventEmitter)();

GLOBAL.Tool = "norma"

GLOBAL.Norma = {
  watchStarted: false,
  reloadTasks: [],
  emitter: EventEmitter
}

// Load Coffeescript for node tasks
require("coffee-script/register");

// Require main file
require("../lib/" + Tool + "-main");
