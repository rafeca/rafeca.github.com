---
layout: post
title: Fix latest commit branch using git
categories: [git]
---

# Introduction

I like git, I hope you like it too. I like using the [git flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model while developing new features or fixing undesired bugs in a stable version.

Sometimes while you're starting a new feature, you forget changing your current branch and end up committing a change to the wrong branch (often develop).

Let's walk through the steps required to move your latest commit from the wrong branch to the right one:

# 1.- Prerequisites

* Create the repository with an initial content and create the develop branch.

{% highlight bash %}
bundle gem foo_bar
cd foo_bar
git commit -am "first commit"
git checkout -b develop
# modify version.rb file to increase the version number
git commit -am "bump version"
{% endhighlight %}

* Create your feature branch

{% highlight bash %}
git branch feature/hello
git lg                                                                                                                                   
* d62b49a - (HEAD, feature/hello, develop) bump version - juandebravo (66 seconds ago)
* 9158f06 - (master) first commit - juandebravo (2 minutes ago)
{% endhighlight %}

* Commit a change to develop (instead of your feature branch)

{% highlight bash %}
echo "require 'foo_bar/version'\n\nmodule FooBar\n  def self.hello(name)\n    print \"hello #{name}\"\n  end\nend" > lib/foo_bar.rb
git commit -am "add hello method"
{% endhighlight %}

WRONG! You commit to develop instead of feature/hello

{% highlight bash %}
git lg
* ecd59c3 - (HEAD, develop) add hello method - juandebravo (2 seconds ago)
* d62b49a - (feature/hello) bump version - juandebravo (40 minutes ago)
* 9158f06 - (master) first commit - juandebravo (40 minutes ago)
{% endhighlight %}

# 2.- Fix the wrong commit

* Merge develop to your feature branch
{% highlight bash %}
git checkout feature/crud_users
git merge develop
git lg
* ecd59c3 - (HEAD, feature/hello, develop) add hello method - juandebravo (3 minutes ago)
* d62b49a - bump version - juandebravo (43 minutes ago)
* 9158f06 - (master) first commit - juandebravo (44 minutes ago)
{% endhighlight %}

Now you already have the change in your feature branch. Now it's time to remove it from develop branch.

* Remove the commit from develop branch
{% highlight bash %}
git checkout develop
git reset --hard HEAD~1
git lg
* ecd59c3 - (feature/hello) add hello method - juandebravo (4 minutes ago)
* d62b49a - (HEAD, develop) bump version - juandebravo (44 minutes ago)
* 9158f06 - (master) first commit - juandebravo (44 minutes ago)
{% endhighlight %}

* That's all!!