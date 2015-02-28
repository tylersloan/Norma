
require("coffee-script/register");

/*

  Ths may look odd but right now is the best idea I can come up
  with for a single Norma instance to be run and shared between
  the global tool and the local pacakge. I'm trying to shy away
  from GLOBAL.Norma = Norma beacuse I dont like the idea of polluting
  the global namespace. Binding it to process.Norma seems simillar but
  safer and not too bad considering the use case is a ** process **
  oriented application.

  Open to better ideas from people much smarter than I am!

*/
if (!process.Norma) {
  var Norma = require("./norma");
  require("./libraries")(Norma);
  process.Norma = Norma
}
else {
  var Norma = process.Norma
}

module.exports = Norma
