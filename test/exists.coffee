
Chai = require("chai").should()

Norma = require("./../lib/norma")


describe "Norma exists", ->

  it "should return a version number", ->
    type = typeof Norma.version
    type.should.equal "string"

  it "should be an object with many keys", ->
    type = typeof Norma
    keyNumber = Object.keys(Norma).length
    # type.should.equal "object"
    keyNumber.should.be.above 1

  it "should have a method for help", ->
    Norma.should.contain.any.keys('help')
