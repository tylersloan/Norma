var Npm = require("npm"),
    Path = require("path"),
    Semver = require("semver"),
    Spawn = require("child_process").spawn
    user = process.env.NPMUSER,
    password = process.env.NPMPASSWORD,
    email = process.env.NPMEMAIL;

var publish = function() {
  console.log("trying to publish to npm");
  // console.log(Npm.registry.adduser.toString())
  if (user && password && email) {
    var results = [],
        errors = []
        _npm = null;

    _npm = Spawn("npm", ["login"], {
        cwd: process.cwd()
      }
    );

    var checkResponse = function(string) {

      if (string.match(/Username/)) {
        console.log(string);
        _npm.stdin.write(user + "\n")
        return
      }

      if (string.match(/Password/)) {
        console.log(string);
        _npm.stdin.write(password + "\n");
        return
      }

      if (string.match(/Email/)) {
        console.log(string);
        _npm.stdin.write(email + "\n");
        _npm.stdin.end()
        return
      }
    }

    _npm.stdout.setEncoding("utf8");

    _npm.stderr.on("data", function(data) {
      var i, lines, message, str;
      str = data.toString();
      lines = str.split(/(\r?\n)/g);
      i = 0;
      while (i < lines.length) {
        if (!lines[i].match("\n")) {
          message = lines[i].split("] ");
          if (message.length > 1) {
            message.splice(0, 1);
            errors.push(message.join(" "));
            i++;
            return;
          }
        }
      }
    });


    _npm.stdin.on("data", function(data) {
      var i, lines, message, str;
      str = data.toString();
      lines = str.split(/(\r?\n)/g);
      i = 0;
      while (i < lines.length) {
        if (!lines[i].match("\n")) {
          message = lines[i].split("] ");
          if (message.length > 1) {
            message.splice(0, 1);
            console.log(message.join(" "))
            i++;
            return;
          }
        }
      }
    });


    _npm.stdout.on("data", function(data) {
      str = data.toString();
      lines = str.split(/(\r?\n)/g);
      i = 0;
      while (i < lines.length) {
        if (!lines[i].match("\n")) {
          message = lines[i].split("] ");
          if (message.length > 1) {
            message.splice(0, 1);
          }
          results.push(message.join(" "));
          checkResponse(message.join(" "))
        }
        i++;
      }
    });

    _npm.on("close", function(err) {
      if (errors.length) {
        throw errors
      }

      if (err) {
        throw err
      }
      // _npm.stdin.end()

      console.log("time to publish!");
      Npm.commands.publish([], function(err){
        if (err) {
          throw err
        }
        console.log('Published to registry');
        process.exit(0);
        return;
      });


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
