
Chai = require("chai").should()

Norma = require "./../lib/index"


describe "Modes", ->

  it "should pull in compilers flag from test runner", ->

    Norma.compilers.should.equal "coffee:coffee-script/register"

  it "should pull in spec flag from test runner", ->

    Norma.reporter.should.equal "spec"

  it "should pull in envrioment variable", ->

    env = process.env.NODE_ENV

    if env is "production"
      Norma.production.should.be.true

    else
      Norma.development.should.be.true
