Norma
===

Automated asset pipeline built on node

Learn more about [Norma](http://en.wikipedia.org/wiki/Norma_Cenva)

# Example Usage

Use the following commands to create a project and locally (only this new
project and not all norma projects on your machine) add a coffeescript compiler:

```
norma create myNormaApp
cd myNormaApp
norma add javascript
```

Now replace the contents of the norma.json file with this:

```
{
  "name": "My Awesome Project",
  "message": "Write custom config items in this file",
  "javascript": {
    "src": "cs/*",
    "dest": "js/"
  }
}
```

Now, your project is setup to compile all coffeescript files found in the cs
directory to javascript files in the js directory.  Add a directory named cs to
the root of your project and add a file called script.coffee with these
contents:

```
console.log 'Hello, World!'
```

Now run the following command - a js directory will be created with a file
called script.js with the compiled javascript within:

```
norma build javascript
```
