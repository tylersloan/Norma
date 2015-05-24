
Fs    = require "fs"
Path = require "path"
Nconf = require "nconf"
Bcrypt = require "bcrypt"
Crypto = require "crypto"
CSON = require "cson"


Norma = require "./../norma"
intialized = false

initialize = ->


  # CONFIG-TYPE -----------------------------------------------------------
  csonFormat =
    stringify: (obj, options) ->

      oldObj = obj

      # if not Object.keys(obj).length
      #   throw new Error("invalid object to be saved, #{obj}")
      #   return
      try
        data = CSON.stringify(obj)
        return data
      catch error
        Norma.emit "error", error

      return oldObj

    parse: (obj, options) ->
      try
        parsed = JSON.parse(obj)
      catch e

        try
          parsed = CSON.parse obj

          return parsed
        catch error
          error.level = "crash"
          Norma.emit "error", error
          return

  ###

    If command has been run with --global or --g then
    swich to the global config, otherwise use current
    directory level to create and use config (local)

  ###
  # global = Path.resolve Norma._.userHome, ".norma"
  global = Norma.config.getFile Norma._.userHome
  # See if a config file already exists (for global files)
  globalConfigExists = Fs.existsSync global

  localSettings = Path.join(process.cwd(), ".norma")
  # if not Fs.existsSync localSettings
  #   Fs.mkdirSync localSettings

  local = Norma.config.getFile(localSettings)
  # See if a config file already exists (for local files)
  localConfigExists = Fs.existsSync local



  # CONFIG-CREATE -------------------------------------------------------------


  # If no file, then we create a new one with some preset items
  if !globalConfigExists
    config =
      path: global

    # Save config
    Fs.writeFileSync(
      global
      CSON.stringify(config)
    )



  # CONFIG-SET ---------------------------------------------------------------


  Nconf.use "memory"
    .file("local", { file: local, format: csonFormat })
    .file("global", { file: global, format: csonFormat })


  intialized = true

  return Nconf



# ENCODING ---------------------------------------------------------------

privateFile = Path.join Norma._.userHome, ".private"

setSalt = (obj) ->
  obj.salt = Bcrypt.genSaltSync(10)

  try
    Fs.writeFileSync(
      privateFile
      CSON.stringify(obj)
    )
  catch err
    Norma.emit "error", "Cannot save private configuration"
    return false

  return obj.salt

getSalt = ->

  # lookup file
  if Fs.existsSync privateFile
    try
      file = Fs.readFileSync privateFile, encoding: "utf8"
      file = CSON.parse file
      file or= {}
    catch err
      err.level = "crash"
      Norma.emit "error", err
      return false

    # is there a salt
    if file.salt
      return file.salt

    return setSalt(file)


  return setSalt({})



decrypt = (salt, value) ->

  decipher = Crypto.createDecipher "aes-256-cbc", salt

  decrypted = decipher.update value["norma-hashed"], "base64", "utf8"
  decrypted += decipher.final "utf8"

  return decrypted



encrypt = (salt, value) ->

  obj = {}
  cipher = Crypto.createCipher "aes-256-cbc", salt

  encrypted = cipher.update value, "utf8", "base64"
  encrypted += cipher.final "base64"

  obj["norma-hashed"] = encrypted
  return obj



# Create files
prepareFile = (loc) ->

  dir = Path.resolve(loc, "../")
  packageJson = Path.resolve(dir, "../", "package.json")
  newPackage = Path.resolve(dir, "package.json")

  if Fs.existsSync(loc) and Fs.existsSync(newPackage)
    return

  if not Fs.existsSync dir
    Fs.mkdirSync dir

  Fs.writeFileSync loc

  if Fs.existsSync packageJson

    # read file
    # Using the require method keeps the same in memory, instead we use
    # a synchronous fileread of the JSON.
    config = Fs.readFileSync packageJson, encoding: "utf8"

    try
      config = JSON.parse(config)
    catch err
      err.level = "crash"

      Norma.emit "error", err

    # remove dependenices
    delete config["dependencies"]
    delete config["devDependencies"]
    delete config["peerDependencies"]
  else
    config =
      name: "global-packages"
      version: "1.0.0"
      description: "global packages for Norma build tool"
      main: "index.js"
      scripts:
        test: "echo \"Error: no test specified\" && exit 1"
      author: ""
      license: "MIT"
      repository:
        type: "git"
        url: "https://github.com/NewSpring/norma.git"
      README: "  "

  # save
  try
    Fs.writeFileSync(
      newPackage
      JSON.stringify(config, null, 2)
    )
  catch err
    Norma.emit "error", "Cannot save #{getFile(cwd)}"

  return


# ACCESS ------------------------------------------------------------------

get = (getter, store) ->

  if !intialized
    initialize()


  gotten = Nconf.get getter

  if gotten?["norma-hashed"]
    salt = getSalt()
    gotten = decrypt salt, gotten


  return gotten


set = (setter, value, hide) ->

  for store, obj of Nconf.stores
    if obj.file
      prepareFile obj.file

  if Norma.hide or hide
    salt = getSalt()
    value = encrypt salt, value

  return Nconf.set setter, value


module.exports = get
module.exports._ = Nconf
module.exports.get = get
module.exports.set = set
