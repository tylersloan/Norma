#!/usr/bin/env node
"use strict";


var Liftoff = require("Liftoff");
var Flags = require("minimist")(process.argv.slice(2));

var Norma = require("../lib/norma")
var cli = new Liftoff({
  name: "norma"
});

// STOP ----------------------------------------------------------------
process.on('SIGINT', function() {
  Norma.stop();
});


// ERRORS ---------------------------------------------------------------
Norma.domain.on("error", function(err){
  // err.level = "crash";
  // handle the error safely
  Norma.events.emit("error", err);
});


// CLI ----------------------------------------------------------
Norma.domain.run(function(){

  var launch = function(env) {
    Norma.launch(env, Norma)
  }
  
  // Require main file
  cli.launch({
    cwd: Flags.cwd,
    verbose: Flags.verbose,
    extensions: require('interpret').jsVariants
  }, launch);

});
