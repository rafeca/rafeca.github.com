---
layout: post
title: First steps with Scala
categories: [scala]
---

Last week I started a [Coursera](https://www.coursera.org) online training course about Functional programming using Scala. The course is leaded by [Martin Odersky](http://en.wikipedia.org/wiki/Martin_Odersky), the creator of Scala language program, so it's a great chance to improve my little knowledge of funcional programming in general and Scala in particular.

When you start working with a new language, first thing you should do is find out the right tools that will make you feel comfortable while spending several hours learning and writing code.

I'll summarize the steps I followed on my computer (running Mac OS X).

# 1. Install the interpreter

{% highlight bash %}
brew install scala
{% endhighlight %}

# 2. Install SBT, the build tool
[SBT](https://github.com/harrah/xsbt/wiki) is for Scala what Maven is for Java. I haven't used it in depth yet, but hopefully it'll suck less than Maven.

{% highlight bash %}
brew install sbt
{% endhighlight %}

# 3. Write your first Scala code using the Scala REPL
Scala provides a built-in interpreter (Read-Evaluate-Print Loop) to write and run Scala code very easily.

You can run the Scala **REPL** either using sbt or **scala** command:

{% highlight bash %}
# Using SBT
juandebravo [~/bin] λ sbt console
scala>
scala> println("Hello world")
Hello world
# Using scala
juandebravo [~/bin] λ scala
scala>
scala> println("Hello world")
Hello world

{% endhighlight %}

# 4. Configure your IDE of choice. Sublime Text 2
My coworker [Toni Cebrian](http://www.tonicebrian.com) wrote a [post comparing IDEs](http://www.tonicebrian.com/2011/05/16/comparison-of-ides-for-scala-development/) to write Scala code. I'll not repeat his text but write a bit about my personal choice: [SublimeText2](http://www.sublimetext.com/2). I started using Sublime Text 2 one year and a half ago coding ruby, I stayed on that when I switched to python, and I'll give it a try for Scala too. I starred some time ago [this tweet](https://twitter.com/alexey_r/status/185839109049303044) about [how to use Sublime Text 2 for Scala development](http://blog.hugeaim.com/2012/03/22/use-sublime-text-2-for-scala-development/), and eventually I read it :-)

It seems that the best option is to install the plugin [sublime-ensime](https://github.com/sublimescala/sublime-ensime). It was a good surprise to find out that my pal [@casualjim](http://www.twitter.com/casualjim) is the original author of this plugin. [Sublime-ensime](https://github.com/sublimescala/sublime-ensime) is a plugin that provides integration between Scala and [ENSIME](http://aemoncannon.github.com/ensime/index.html), the ENhanced Scala Interaction Mode for Emacs.
Follow the instructions in the [sublime-ensime github main page](https://github.com/sublimescala/sublime-ensime) to make it work.

Some months ago I created project showing some cool Scala features, check it out in my [github repository](https://github.com/juandebravo/scala-examples). To run it using Sublime Text 2, create a new Build system with the following configuration:

{% highlight javascript %}
{
	"cmd": ["sbt", "test"],
	"selector": "source.scala",
	"working_dir": "${project_path}"
}
{% endhighlight %}


