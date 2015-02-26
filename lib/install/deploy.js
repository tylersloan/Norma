var Npm = require('npm'),
    user = process.env.NPMUSER,
    password = process.env.NPMPASSWORD,
    email = process.env.NPMEMAIL;

var publish = function() {
  console.log("trying to publish to npm")
  if (user && password && email) {
    Npm.registry.adduser(user, password, email), function(err) {
      if (err) {
        console.log(err);
        process.exit(0);
        return;
      } else {
        Npm.config.set("email", email, "user");
        Npm.commands.publish([], function(err){
          console.log(err || 'Published to registry');
          process.exit(0);
          return;
        });
      }
    }
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
        console.log(err);
        process.exit(0);
        return;
      }

      // load config
      try {
        config = require(Path.join(__dirname, "../../", "package.json"));
      } catch (_error) {
        console.log(_error);
        process.exit(0);
        return;
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
