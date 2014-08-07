// Small wrapper function for using gulp with coffeescript

require('coffee-script/register');

var requireDir = require('require-dir');
var dir        = requireDir('./tasks');
