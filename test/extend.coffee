Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"



describe "Extend", ->

  fixtures = Path.resolve "./test/fixtures"
  Norma.silent = true
  oldCwd = process.cwd()
  oldConfig = Norma.config(fixtures)

  before (done) ->

    process.chdir fixtures

    newConfig = Norma.config fixtures

    newConfig.tasks["images"] =
      "@extend": "copy"
      "src": "images/**/*",
      "dest": "out/images"

    Norma.config.save newConfig, fixtures

    done()

    return


  it "should expose new tasks based on name of task", (done) ->

    Norma.getPackages(fixtures)
      .then( (packages) ->
        # Norm.packages.
        packages.should
          .contain.any.keys["images"]
        return done()
      )


  it "should copy assets from images to out/images", (done) ->

    @.timeout 10000
    # create new file contents
    contents = Math.random()

    # write to file
    inFile = Path.join(fixtures, "images/test.html")
    outFile = Path.join(fixtures, "out/images/test.html")
    Fs.writeFileSync inFile, contents

    Norma.build([], fixtures)
      .then( ->
        newContents = Fs.readFileSync outFile, encoding: "utf8"
        newContents.should.equal contents.toString()
        done()

      ).fail( (err) ->
        if err then console.log err
        done()
      )


  after (done) ->

    Norma.config.save(oldConfig, fixtures)

    process.chdir oldCwd

    done()

    return
