var Npm = require("npm"),
    Path = require("path"),
    Semver = require("semver"),
    Exec = require("child_process").exec
    user = process.env.NPMUSER,
    password = process.env.NPMPASSWORD,
    email = process.env.NPMEMAIL;

var publish = function() {
  console.log("trying to publish to npm");
  // console.log(Npm.registry.adduser.toString())
  if (user && password && email) {
      var configObj = {
        auth: {
          username: user,
          password: password,
          email: email
        }
      }
    Npm.registry.adduser("http://registry.npmjs.org/", configObj, function(err) {
      if (err) {
        console.log(err);
        throw err
      } else {
        Npm.commands.publish([], configObj, function(err){
          if (err) {
            console.log(err);
            throw err
          }
          console.log('Published to registry');
          process.exit(0);
          return;
        });
      }
    });
  }
}

Npm.load({}, function() {
  Npm.commands.view(["normajs", 'dist-tags.latest'], true,
    function(err, data) {
      var availableVersion,
          config,
          currentVersion,
          e,
          key;

      // error handling
      if (err) {
        throw err
      }

      // load config
      try {
        config = require(Path.join(__dirname, "../../", "package.json"));
      } catch (_error) {
        throw _error
      }

      // set versions
      currentVersion = config.version;
      availableVersion = currentVersion;

      // grab lastest from npm
      for (var ky in data) {
        availableVersion = ky;
        break;
      }

      // see if this version is newer than npm
      if (Semver.gte(currentVersion, availableVersion)) {
        publish();
      } else {
        process.exit(0);
        return
      }

    }
  )
});
