
Chai = require("chai").should()

Norma = require "./../lib/index"

describe "Norma", ->

  it "should return a version number", ->
    Norma.version.should.be.a "string"


  it "should be an object with many keys", ->
    keyNumber = Object.keys(Norma).length
    keyNumber.should.be.above 1


  it "should have a method for help", ->
    Norma.should.contain.any.keys("help")


  it "should have a value for prefix that is a string", ->
    Norma._.prefix.should.be.a "string"
