
require("coffee-script/register");

var Norma = require("./norma");

// Norma.setOptions(options);

require("./libraries")(Norma);

// Deprecated! Will be removed after 1.0
GLOBAL.Norma = Norma


module.exports = Norma
