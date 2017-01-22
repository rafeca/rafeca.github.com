---
layout: post
title: SBT run&#58; choose automatically the App to launch
categories: [scala, sbt]
---

I like Christmas because, beside resting from work and having fun with family and friends, usually there is time to learn something new. During this Xmas I've been playing with Scala: First, trying to finish the [Coursera Functional Programming Principles course](https://class.coursera.org/progfun-2012-001/auth/auth_redirector?type=login&subtype=normal). Later, working a bit in a personal project. Better late than never :smile

As for my personal project, it provides more than one **executable entry point**:

- web application exposing a REST API using [Scalatra](http://www.scalatra.org/).
- offline script to retrieve data from a third party periodically. This could be easily done with [Rake](http://rake.rubyforge.org/) in the Ruby world, and as far as I know there's not a [task management tool "de facto standard" in python](http://code.activestate.com/pypm/search:rake/).

Working with Scala and SBT, the command **sbt run** looks like the natural alternative. It seeks for every Scala Object in the project that could be used as the assembly entry point:

- an object that defines a main method
- an object that inherits from App

If your application has more than one object fitting the previous requirement, the command *sbt run* will ask for your help to finish the execution.

Let's consider the following snippet of code, having two objects that define a *main* method:

{% highlight scala %}
# File src/main/Foo.scala
object Foo {
    def main(args: Array[String]) = println("Hello from Foo")
}

# File src/main/Bar.scala
object Bar extends App{
    println("Hello from Bar")
}

{% endhighlight %}

When you execute the **sbt run** command, the following text shows up:

{% highlight bash %}
> sbt run

Multiple main classes detected, select one to run:

 [1] Bar
 [2] Foo

Enter number: 2
[info] Running Foo
Hello from Foo
[success] Total time: 29 s, completed Dec 30, 2012 11:36:28 PM
{% endhighlight %}

It requires human action (in the previous example, fill in the number *2*), as the *run* command does not receive any parameter to automate the process.

Fortunately, there's an easy solution using the SBT plugin [sbt-start-script](https://github.com/sbt/sbt-start-script) :squirrel:. You just need to follow these three steps:

* Create (or update) the file *project/plugins.sbt*, including:

{% highlight scala %}
addSbtPlugin("com.typesafe.sbt" % "sbt-start-script" % "0.6.0")
{% endhighlight %}

* Create (or update) the file *build.sbt*, adding:

{% highlight scala %}
import com.typesafe.sbt.SbtStartScript
seq(SbtStartScript.startScriptForClassesSettings: _*)
{% endhighlight %}

* Execute:

{% highlight bash %}
sbt update
sbt start-script
{% endhighlight %}

As result, a new file **target/start** is created. A file that requires the main class name to be executed as the first argument:

{% highlight bash %}
> target/start Foo
Hello from Foo

> target/start Bar
Hello from Bar
{% endhighlight %}

Two last tips:

* In case your program just has a single main class, the script does not require any argument.

* Remember to add the automatically generated file *target/start* to your CVS
