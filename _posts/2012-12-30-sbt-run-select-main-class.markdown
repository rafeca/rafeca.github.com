---
layout: post
title: SBT run&#58; choose automatically the App to launch
categories: [scala sbt]
---

I like Christmas because, besides resting from work and having a lot of fun with your family and friends, usually there is room left to learn something new. This eve I have been playing with Scala, both trying to finish the [Coursera Functional Programming Princicples course](https://class.coursera.org/progfun-2012-001/auth/auth_redirector?type=login&subtype=normal), late is better than never :smile:, and also working in a personal project.

Regarding that project, I have more than one **executable entry point**:

- web application exposing a REST API using [Scalatra](http://www.scalatra.org/).
- offline script to retrieve data from a third party asynchronously.

The command **sbt run** looks for every object in your project that could be used as entry point of the program:

- an object that defines a main method
- an object that inherits from App

If your application has more than one object like this, the command *sbt run* will ask for your help to finish the execution:

```scala
# File src/main/Foo.scala
object Foo {
    def main(args: Array[String]) = println("Hello from Foo")
}

# File src/main/Bar.scala
object Bar extends App{
    println("Hello from Bar")
}

```

When you execute the **sbt run** command, the following text is shown:
```bash
> sbt run

Multiple main classes detected, select one to run:

 [1] Bar
 [2] Foo

Enter number: 2
[info] Running Foo
Hello from Foo
[success] Total time: 29 s, completed Dec 30, 2012 11:36:28 PM
```

This is a bit annoying, the *run* command does not receive any parameter to automate the process.

Fortunately, there's an easy solution :smile:

* Create (or update) the file *project/plugins.sbt*, including:

```scala
addSbtPlugin("com.typesafe.sbt" % "sbt-start-script" % "0.6.0")
```

* Create (or update) the file *build.sbt*, adding:

```scala
import com.typesafe.sbt.SbtStartScript
seq(SbtStartScript.startScriptForClassesSettings: _*)
```

* Execute:

```bash
sbt update
sbt start-script
```

As result, a new file *target/start* has been created. This file requires the main class name as the first argument:

```bash
> target/start Foo
Hello from Foo

> target/start Bar
Hello from Bar
```

In case of your program having only one main class, the script does not require any argument.