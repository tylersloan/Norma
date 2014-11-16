#!/usr/bin/env node
"use strict";

var EE = require('event-emitter');
var Emitter = EE({});

GLOBAL.Tool = "norma"

GLOBAL.Norma = {
  watchStarted: false,
  reloadTasks: [],
  emitter: Emitter
}

// Load Coffeescript for node tasks
require("coffee-script/register");

// Require main file
require("../lib/" + Tool + "-main");
