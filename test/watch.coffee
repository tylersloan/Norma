Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"

describe "Watch", ->

  fixtures = Path.resolve "./test/fixtures"

  it "should change Norma.watchStarted to true", ->
    @.timeout 100000
    Norma.watchStarted = false

    Norma.watch([], fixtures)

    Norma.watchStarted.should.be.true

    Norma.watch.stop()



  it "should respond to changes in a file", (done) ->

    oldprocess = process.cwd()
    process.chdir fixtures

    @.timeout 100000

    outFile = Path.join fixtures, "out", "test.js"
    inFile = Path.join fixtures, "lib", "test.js"

    oldContents = ""
    if Fs.existsSync outFile
      oldContents = Fs.readFileSync outFile, encoding: "utf8"

    Norma.watch([], fixtures)

    contents = Math.random()

    setTimeout ->
      Fs.writeFileSync inFile, contents
    , 1000

    # Fs.writeFileSync inFile, contents

    Norma.on "file-change", (event) ->

      if Path.resolve(event.path) is Path.resolve(inFile)
        setTimeout ->
          Fs.writeFileSync inFile, contents

          newContents = Fs.readFileSync outFile, encoding: "utf8"
          newContents.should.equal contents.toString()

          process.chdir oldprocess

          Norma.watch.stop()

          done()
        , 1000
