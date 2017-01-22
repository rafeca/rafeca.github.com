---
layout: post
title: "Using travis-ci to build this blog"
categories: [jekyll, travis, github]
---

This [blog is built](/2012/05/31/yet-another-blog-in-the-world/) using Jekyll as static code site generator and GitHub as the deployment target thanks to its support to Jekyll via GitHub pages.

One of the great things about using GitHub together with Jekyll is the support that GitHub provides out of the box to generate your HTML pages using Jekyll in the server side whenever a new content is added to your repository.

Some months ago I ran some experiments to include *emojis support* to this blog :smile:. Jekyll
supports a plugin mechanism to extend the framework functionality.

Bad news are that GitHub does not allow third-party plugins to build your Jekyll based web page, like this
one. The reason behind this might be to avoid any kind of attack from a malicious user. Then I needed to either build the site locally and upload the HTML version to GitHub, or get rid of emojies.

I have been working on local compiling over the last months, but some weeks ago I started playing with *[travis](http://travis-ci.org)* to remove this boring work from my side. Those are the relevant steps that I did:

* Create a new account in Travis

* Configure your GitHub project to support *travis*. [Here](https://developer.github.com/webhooks/#services) you can find the list of supported services & webhooks ([JSON format](https://api.github.com/hooks)).

* Install the *travis* gem in your local environment

{% highlight bash %}
gem install travis
{% endhighlight %}

* Generate a valid token in the GitHub project settings page.

* Hash the token for travis to be able to use it in a secured way (as the value will be included in your repository)

{% highlight bash %}
travis encrypt -r <USER>/<REPOSITORY> GH_TOKEN=<GH-TOKEN> --add env.global
{% endhighlight %}

* [Configure your build](http://docs.travis-ci.com/) in the **.travis.yaml** file at the root of your repository.

* In order to use a GitHub OAuth token, [the configured URL should be the HTTPS one](https://github.com/juandebravo/juandebravo.github.com/blob/master/.travis.yml#L36):

{% highlight bash %}
git remote set-url origin https://${GH_TOKEN}@github.com/juandebravo/juandebravo.github.com.git
{% endhighlight %}

* Run the command *travis-lint* to validate the file syntax.

*[Travis](http://travis-ci.org)* is a great piece of software that you can take advantage of very easily!! :bowtie: :neckbeard:
