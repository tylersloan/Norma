## v.NEXT

* Added ability for packages to be extended in norma.json

To extend a package, it must use the second argument passed on require
and dynamically name its tasks from the name field. For example:

```coffeescript
module.exports = (config, name) ->

  # set default task name
  if !name then name = "copy"

  # return if the package trying to be loaded isn't in norma.json
  if !config.tasks[name]
    return

  # dynamically set task
  Norma.task "#{name}", (cb) ->
    # do things in here
    cb null
    return


  Norma.tasks["#{name}"].order = order
  module.exports.tasks = Norma.tasks

```

Now this package can be extended in a `norma.json` using the reserved @extend
key. For example:

```javascript
tasks: {
  "copy": {
    "src": "./raw",
    "dest": "./out"
  },
  "images": {
    "@extend": "copy"
    "src": "./second-raw",
    "dest": "./out"
  }
}
```
