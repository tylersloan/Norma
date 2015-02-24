require('xunit-file');

var Mocha = require('mocha'),
    fs = require('fs'),
    path = require('path'),
    testDir = path.join(__dirname, "../../", "test");

require("coffee-script/register");

// First, you need to instantiate a Mocha instance.
reporter = process.env.CI ? 'xunit-file' : 'spec'

// CI saving of tests output to the right place
console.log(process.env.CIRCLE_TEST_REPORTS)
if (process.env.CIRCLE_TEST_REPORTS) {
  process.env.XUNIT_FILE = process.env.CIRCLE_TEST_REPORTS
}

var mocha = new Mocha({
  reporter: reporter
});

// Then, you need to use the method "addFile" on the mocha
// object for each file.

// Here is an example:
fs.readdirSync(testDir).filter(function(file){
  // Only keep the .js files
  return file.substr(-7) === '.coffee';

}).forEach(function(file){
  // Use the method "addFile" to add the file to mocha
  mocha.addFile(
      path.join(testDir, file)
  );
});


// Now, you can run the tests.
mocha.run(function(failures){
  process.on('exit', function () {
    process.exit(failures);
  });
});
