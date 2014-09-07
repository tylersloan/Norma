// Small wrapper function for using gulp with coffeescript
require('coffee-script/register');

// Dynamically load all gulp tasks
var requireDir = require('require-dir');
var dir        = requireDir('./tasks');
