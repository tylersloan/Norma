
Inquirer = require "inquirer"
_ = require "underscore"

Norma = require "./../norma"

module.exports = (questions, callback) ->

  # see if string is asked (defaults to input)
  if _.isString questions
    questions =
      type: "input"
      name: "_"
      message: questions


  # see if object is asked (wrap in array)
  if _.isObject questions
    questions = [questions]


  # Handle empty questions
  if !questions
    if !questions
      Norma.emit "error", "no questions asked"

    return

  # Handle empty callback
  if !callback or typeof callback isnt "function"
    Norma.emit "error", "no callback specified"
    return

  # Check of name since Inquirer has poor error handling
  for question in questions
    if !question.name
      Norma.emit "error", "question must have a name"
      return


  Inquirer.prompt questions, callback

  return
