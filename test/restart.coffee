# Chai    = require("chai").should()
# Path    = require "path"
# Fs      = require "fs"
# Rimraf  = require "rimraf"
#
# Norma = require "./../lib/index"
#
#
# describe "Restart", ->
#
#   fixtures = Path.resolve "./test/fixtures"
#   Norma.silent = true
#
#   afterEach (done) ->
#     setTimeout ->
#       Norma.watch.stop()
#       done()
#     , 500
#
#
#   it "should watch for changes on a norma.json file", (done) ->
#     @.timeout 10000
#
#     Norma.watch([], fixtures)
#
#     Norma.on "close", (cb) ->
#       true.should.be.true
#       cb null
#       Norma.removeAllListeners "close"
#       done()
# 
#
#     setTimeout ->
#       oldConfig = Norma.config(fixtures)
#       Norma.config.save(oldConfig, fixtures)
#     , 1000
#
#
#   it "should start again after changes on a norma.json file", (done) ->
#     @.timeout 10000
#
#
#
#     Norma.watch([], fixtures)
#
#     Norma.on "start", ->
#       true.should.be.true
#       Norma.removeAllListeners "start"
#       done()
#
#
#     setTimeout ->
#       oldConfig = Norma.config(fixtures)
#       Norma.config.save(oldConfig, fixtures)
#     , 1000
