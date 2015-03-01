
require("coffee-script/register");

// only create one instance
if (!Norma) {
  var Norma = require("./norma");
  require("./libraries")(Norma);
  // global namespace
  GLOBAL.Norma = Norma
}


module.exports = Norma
