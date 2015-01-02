
# Norma
Norma is a developer assistant, _your_ developer assistant.

Building software should be about the product, not about the process of being able to build. Norma wants to remove the time between idea and execution by handling all of the tasks and processes related to creating modern software.

Norma has 5 core principles

1. Every developer is unique, and their assistant should reflect that.
2. Simplicity with expandability
3. Speed is critical
4. Automation with intention
5. Be invisible but available

These core principles drive development and interactions with Norma.

#### Requirements
Currently Norma has only been tested on Mac OS, although support for Windows and Linux are planned. Besides that, the only other requirement is to have node installed (which is covered in the installation section below.

### Installation
Getting started with Norma is easy enough if you have every worked with node before. Norma is available on npmjs.org and can be installed with `$ npm install normajs -g`.

> For those new to development in general, the `$` in the previous snippet means it should be run in a shell application (like terminal on macs). You should not type the `$`, only the parts afterwards `npm install normajs -g`

NPM will install Norma on your machine to be available globally (via the -g flag). After this is complete you are ready to start working with Norma!

If you have never worked with node before, you can install it [here](http://nodejs.org/). This includes NPM as part of the install and afterwards you can install Norma.

> You can also use home-brew for mac to install node. This is the preferred manner of the author but not the official method per nodejs. To install home-brew, go [here](http://brew.sh/) and go to the install instructions at the bottom of the page. They should look like this: `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`. After home-brew is installed, run `$ brew update; brew install node`. After this is done, you have node and can install Norma.

### Getting Started

Before we get to far into the abilities and workings of Norma, lets create a project to see how she works…

To create a new project run `$ norma create <project-name>`. This will start Norma who will walk you through creating a small project.

> These docs use code blocks denoted by the ` ` coloring around the text. These blocks will be in a variety of different programing languages (javscript, shell, coffee-script, etc) and will be denoted by coloring and some symbols. As already shown, the `$` blocks mean the text should be run in a shell application.
Within the languages, these docs also use symbols to denote when you should use your own words instead of the written. These are denoted in the docs (and in Norma’s inline documentation) by the `< >` symbols. These mean you should replace the section with your desired information.

Once you go through the setup process, you will have a new directory called `<project-name` that you can switch into (`$ cd <project-name`). This is a basic Norma project which contains the two needed things for Norma to succeed, a `norma.json` and `package.json`. If you open this folder in a text editor (you can open it using `$ norma open` in your preferred browser), you can see the generated files.

The first file of importance is the `package.json`. This is how npm works within the project for installing, reading, and running your project. It is required.

The second is where the fun happens, it is the `norma.json` file and it is where your project runs from. For starters, lets add compiling coffeescript to javascript as a part of our project.

```json
{  
  "name": "<project-name>",
  "tasks": {
    "javascript": {
      "src": "lib/**",
      "dest": "out"
    }
  }
}
```

Now lets create a folder called `lib` and a file to it called `test.coffee`. In that file add some coffeescript like below.

```coffeesript
console.log "this is pretty easy"
```

Now, all we have to do is tell Norma we want to work. This is done in a number of ways, but first lets try a build. `$ norma build`. This will download all needed dependencies, then run the  norma-javascript package to compile the coffeescript into javascript. Now you should have a directory named `out` with a file called `test.js` in it with our compiled code!

All it took to get to work was to tell Norma what you wanted to do in one place!


### Further exploration
Norma has a ton more to offer and a lot more power than what was just shown. Not that you have the basics, explore these docs to see what else Norma can help you with! Don’t forget to check out the contribution guidelines and issue reporting sections to help make Norma the best assistant you could want!


### Contributing to Norma

First, thank you for contributing to the Norma project!

#### How to contribute
Prerequisites:

- familiarity with [GitHub PRs](https://help.github.com/articles/using-pull-requests/) (pull requests) and issues
- knowledge of Markdown for editing .md documents
In particular, this community seeks the following types of contributions:
- ideas: participate in an Issues thread or start your own to have your voice heard
- resources: submit a PR to add to docs [README.md](https://github.com/NewSpring/Norma/blob/master/README.md) with links to related content
- outline sections: help us ensure that this repository is comprehensive. if there is a topic that is overlooked, please add it, even if it is just a stub in the form of a header and single sentence. Initially, most things fall into this category
- write: contribute your expertise in an area by helping us expand the included content
- copy editing: fix typos, clarify language, and generally improve the quality of the content
- formatting: help keep content easy to read with consistent formatting
- code: Fix issues or contribute new features to this or any related projects

#### Conduct
We are committed to providing a friendly, safe and welcoming environment for all, regardless of gender, sexual orientation, disability, ethnicity, religion, or similar personal characteristic.

Please be kind and courteous. There's no need to be mean or rude. Respect that people have differences of opinion and that every design or implementation choice carries a trade-off and numerous costs. There is seldom a right answer, merely an optimal answer given a set of values and circumstances.
Please keep unstructured critique to a minimum. If you have solid ideas you want to experiment with, make a fork and see how it works.

We will exclude you from interaction if you insult, demean or harass anyone. That is not welcome behavior. We interpret the term "harassment" as including the definition in the [Citizen Code of Conduct](http://citizencodeofconduct.org/); if you have any lack of clarity about what might be included in that concept, please read their definition. In particular, we don't tolerate behavior that excludes people in socially marginalized groups.

Private harassment is also unacceptable. No matter who you are, if you feel you have been or are being harassed or made uncomfortable by a community member, please contact one of the Norma core team immediately. Whether you're a regular contributor or a newcomer, we care about making this community a safe place for you and we've got your back.

Likewise any spamming, trolling, flaming, baiting or other attention-stealing behavior is not welcome.

### Issue Reporting

If you've found an issue with Norma here's how to report the problem...

First, check our [troubleshooting]() page for solutions to common problems.

How to file a bug
1. Go to our [issue tracker on GitHub](https://github.com/NewSpring/norma/issues)
2. Search for existing issues using the search field at the top of the page
3. File a new issue including the info listed below
4. Thanks a ton for helping make Norma a better assistant!

When filing a new bug, please include:
- Descriptive title - use keywords so others can find your bug (avoiding duplicates)
- Steps to trigger the problem that are specific, and repeatable
- What happens when you follow the steps, and what you expected to happen instead.
- Include the exact text of any error messages if applicable (or upload screenshots).
- Norma version
- Did this work in a previous version? If so, also provide the version that it worked in.
- OS version
- Packages? 
- Any errors logged in the console


#### Requesting a feature
Please first check our feature backlog on [waffle.io] to see if it's already there.

Feel free to file new feature requests as an issue on GitHub, just like a bug. We tag these issues "move to backlog" and periodically migrate them onto the feature backlog for you.

What happens after a bug is filed?

__Bug lifecycle__

1. New bug is filed; awaiting review
2. Triaged in bug review -- see below ('last reviewed' tag
3. Developer begins working on it -- bug is tagged 'fix in progress'
4. Developer opens pull request with a fix, which must be reviewed -- a link to the pull request appears in the bug's activity stream
5. Pull request is merged, and the bug's filer is pinged to verify that it's fixed -- bug is tagged 'fixed but not closed' ("FBNC")
6. Filer agrees that it's fixed -- bug is closed, and its milestone is set to the release the fix landed in

__Bug review__
We review all new issues on a regular basis. Several things typically happen as part of review:

- Ping the filer for clarification if needed.
- If the issue is a feature request, we'll tag it 'move to backlog'; the issue will be migrated to our feature backlog at a later date.
- Add priority labels (high, medium, low, or none - read more below).
- Add release milestone - typically only if a bug is a "release blocker" or related to features still in progress.
- Add feature area label, and possibly other category labels like 'starter bug' or 'Mac only.' See "Understanding issue labels" below.
- Depending on priority, milestone, and other workload, a developer may or may not begin working on the bug soon.
Some bugs may be closed without fixing - see "Hey! My bug wasn't fixed!" below.

__Hey! My bug wasn't fixed!__
Yeah, what's up with that? There are a number of reasons an issue might get closed without being fixed:

- Tagged 'move to backlog' - It's not forgotten! Look for a link in the comment thread to our feature backlog.
- Tagged 'fixed but not closed' - We think it's fixed. Make sure you have a Norma build containing the fix (check the milestone assigned to the bug). If you're still seeing it, let us know.
- Duplicate - There's already a bug for this.
- Unable to reproduce - We're unable to reproduce the result described in the bug report. If you're still seeing it, please reply with more detailed steps to trigger the bug.
- Out of scope / package idea - This change probably doesn't belong in Norma core... but it could still make for a great package!
- Not a bug / fact of life - This is the intended behavior. If it feels wrong, we should discuss how to improve the usability of the feature.

If you disagree with a bug being closed, feel free to post a comment asking for clarification or re-evaluation. The more new/updated info you can provide, the better.

__Can I help fix a bug?__
Yes please! But first...

- Make sure no one else is already working on it -- if the bug has a milestone assigned or is tagged 'fix in progress', then it's already under way. Otherwise, post a comment on the bug to let others know you're starting to work on it.
- Read the guidelines for contributing code, pull request guidelines, and coding conventions.

