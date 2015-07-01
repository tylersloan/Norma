Chai    = require("chai").should()
Path    = require "path"
Fs      = require "fs"

Norma = require "./../lib/index"

describe "Watch", ->

  fixtures = Path.resolve "./test/fixtures"


  it "should change Norma.watchStarted to true", ->
    # @.timeout 10000
    Norma.watchStarted = false

    Norma.watch([], fixtures)

    Norma.watchStarted.should.be.true

    Norma.watch.stop()



  it "should respond to changes in a file", (done) ->

    @.timeout 100000

    oldprocess = process.cwd()
    process.chdir fixtures

    outFile = Path.join fixtures, "out", "test.js"
    inFile = Path.join fixtures, "lib", "test.js"

    oldContents = ""
    if Fs.existsSync outFile
      oldContents = Fs.readFileSync outFile, encoding: "utf8"

    Norma.watch([], fixtures)

    contents = Math.random()

    setTimeout ->
      Fs.writeFileSync inFile, contents
    , 500

    Fs.writeFileSync inFile, contents

    Norma.on "file-change", (event) ->

      if Path.resolve(event.path) is Path.resolve(inFile)
        setTimeout ->

          newContents = Fs.readFileSync outFile, encoding: "utf8"
          newContents.should.equal contents.toString()

          process.chdir oldprocess

          Norma.watch.stop()

          done()
        , 500
