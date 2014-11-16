---
layout: post
title: "Using travis-ci to build this blog"
categories: [jekyll, travis, github]
---

This blog is built using Jekyll as static code site generator and GitHub as the deployment target.

One of the great things about using GitHub together with Jekyll is the support that GitHub provides out of the box to generate your HTML pages using Jekyll in the server side whenever a new content is added to your repository.

Some months ago I ran some experiments to include *emojis support* to this blog :smile:. Jekyll
supports a plugin mechanism to extend the framework functionality.
Bad news are that Github, while building your Jekyll based web page (like this
one), does not allow third-party plugins, probably to avoid any kind of attack from a malicious user. Then I needed to either build the site locally and upload the HTML version to GitHub, or get rid of emojies.

That's why I started playing with *travis*. Those are the relevant steps that I did:


* Create a new account in Travis
* Configure your build in **.travis.yaml** file
* Run the command *travis-lint* to validate the file syntax
* Unable to configure more than one language. By default, ruby is properly configured so you don't need to specify it. On the other hand, python libraries are installed by default in /usr/local/lib, which is not granted
* You can configure the branches that you want travis to build
* Jekyll did not raise any error in case of pygments not being available. This caused a downtime in the blog content
* In order to use a github OAuth token, the configured URL should be the HTTPS one:
    - travis encrypt -r <USER>/<REPOSITORY> GH_TOKEN=<GH-TOKEN> --add env.global
* Travis only downloads the latest 50 revisions.
