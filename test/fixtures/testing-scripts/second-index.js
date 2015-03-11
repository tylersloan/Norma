var Fs = require("fs"),
    Path = require("path"),
    inFile = Path.resolve(__dirname, "../images/test.html"),
    outFile = Path.resolve(__dirname, "../out/images/second-test.html");


Fs.createReadStream(inFile)
  .pipe(
    Fs.createWriteStream(outFile)
  );
