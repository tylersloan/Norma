Norma
===

Helpful development built on node

Learn more about [Norma](http://en.wikipedia.org/wiki/Norma_Cenva)

# Who is Norma

Norma is the assistant developer you always wanted. She helps you get to
your idea in as few of steps as possible. If you have ever expressed in
frustration "I just want to build websites!", Norma is for you.

Norma is built on the node streaming tool Gulp. If there is a gulp-package
for something you need, making a Norma package is only a few lines away. Norma
isn't dependent on gulp for packages though, its all node so if you want
something, it can probably be built.


# What is Norma

Norma is an assistant. She helps to coordinate the things you want to do.
She can help on things ranging from linting, compiling, and packaging assets
to watching your files for changes and reloading your browser. She can run
tests and do builds for deployment and let your CI know things have worked
or haven't. She can load a local server and expand it to your local network
to test on all the coolest new devices. If it has to do with building software,
Norma can help.

Technically, Norma is a node based application with a CLI api. It uses a
package system in order to carry out tasks. It is built to interface
with existing gulp methods out of the box.


# When do I use Norma

Are you building a website? -> Use Norma

Are you building a web application -> Use Norma

Are you building a node application -> Use Norma

Are you building software -> You can probably use Norma

Are you deploying your site/app -> Use Norma

Do you want to order a sandwhich? -> Coming soon to Norma


# Where is Norma

Norma lives on your local machine and on your deployment servers.
As of right now, only Unix based machines have been tested but windows
support is on the horizon. Norma is currently a CLI (Command Line Interface)
so it requires using the command line (terminal on mac) but there are plans
for a native GUI in the future.


# Why Norma?

You have a great idea, you want to build your great idea, anything that slows
you down from building your idea is a problem. Norma can help fix
that problem.

# How Do I Work With Norma?

How you work with Norma depends on what you want to do. In the wiki you
can find a number of different ways to work with Norma. For the most
part the example usage below gives you a pretty good start.


# Example Usage

Use the following commands to create a project and locally (only this new
project and not all norma projects on your machine) add a coffeescript compiler:

````bash
$ norma create myNormaApp
$ cd myNormaApp
$ norma add javascript
````

Now replace the contents of the norma.json file with this:

````json
{
  "name": "My Awesome Project",
  "tasks": {
    "javascript": {
      "src": "cs/*",
      "dest": "js/"
    }
  }
}
````

Now, your project is setup to compile all coffeescript files found in the cs
directory to javascript files in the js directory.  Add a directory named cs to
the root of your project and add a file called script.coffee with these
contents:

````coffeescript
console.log 'Hello, World!'
````

Now run the following command - a js directory will be created with a file
called script.js with the compiled javascript within:

````bash
$ norma build
````
