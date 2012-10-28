---
layout: post
title: Baruco, First day
categories: [ruby]
---

# Introduction

This weekend [CosmoCaixa building](http://obrasocial.lacaixa.es/nuestroscentros/cosmocaixabarcelona/cosmocaixabarcelona_es.html), in Barcelona, is hosting the [BArcelona RUby COnference](http://www.baruco.org).

So I'll summarize the weekend talks, let you know about the awesome speakers, the wonderful venue and the great organization.

# Keynote by Scott Chacon. Back to First Principles

[Scott Chacon](http://twitter.com/chacon), [github](https://www.github.com) cofunder, was the first speaker on stage. He talked us through how he sees the future of working for a software company or at least how he'd like it to be:

- **No timetable**: stop working 8 to 17, start acting as an artist that needs inspiration and work in creative moments.
- **No vacations**: consider that anyone should know when can go on holidays, no rules on that. (I do know that this is something already in place in some companies such as [Netflix](http://mashable.com/2012/04/13/netflix-unlimited-vacation/))
- **No expenses sheets**: give people the freedom to know what/when/how much he may spend.
- **No managers**: consider when or why you need a manager. In those situations, could he be replaced by a software program? :)

All the above defines the way an open source project works nowdays.

Some examples of companies that are questioning the usual way to work:

- [valve](http://www.valvesoftware.com/company/people.html)
- [gore](http://www.gore.com/en_xx/aboutus/culture/index.html)
- [github](http://github.com)

# RubyMotion

[RubyMotion](http://www.rubymotion.com/) is a commercial product (162,61 € a licence, coming soon a free licence alternative) that enables a way to create iOS applications using Ruby language.

**Good points**:

- Reuse your Ruby knowledge instead of learning a new language, new patterns, etc.
- Use the expressiveness of Ruby instead of Objective-C syntax
- Get rid of XCode and use your IDE/text editor of choice
- Community
- Commandline: you can use your commandline to build the project
- Storyboards
- [Cocoapods](https://github.com/CocoaPods/Specs)

How to create the simplest RubyMotion application:

{% highlight bash %}

motion create sample
cd sample
rake

{% endhighlight %}

Speakers pointed out that ARC (Automatic Reference Counter) it's the gear that enables RubyMotion (so you need at least iOS 5). Underneath, RubyMotion uses a MacRuby.

To them it should not be used for production right now, perhaps in six months time.

My personal opinion, you should learn more than one programming language and at least try the native Objective-C language, create your own opinion about if you should use RubyMotion or any other high level framework such as [PhoneGap](http://phonegap.com/) or [Titanium](http://www.appcelerator.com/).

# Getting consistent behavior across your API

Principles for either internal or external API:

- Less Surprise principle
- Consistent formatting
- Consistent naming and format in the overall API
- Handle carefully unexpected responses
- Ensure you are not creating bad or missing error messages
- Let people know what you accept and give them examples

How to achieve:

- Centralize behavior
- DRY (dont repeat yourself)

Warm up:

- Treat you API like the interface it is
- Aim for consitency
- Become your own client and challenge your API design

# Deconstructing the framework
Gary Bernhardt talked about how useful is the SRP (Single Responsability Principle) while creating a well-defined application that should be maintained during a long period. I do agree.
Regarding this principle, he mentioned Rails controller as a piece of software that, by default, is in charge of different tasks: authorization, authentication, service logic, form validation, serialization.
He has been working on that OS project called [raptor](https://github.com/garybernhardt/raptor) that is a proof of concept, not ready to use in production, about how to split code and separate reponsabilities in a Rails application.

# Life beyond HTTP
Consider a protocol as a tool you can use to improve your system. About application protocols:

- **SMTP** (Simple Mail Transfer Protocol)
- **DNS** (Domain Name System)
- **XMPP** (Extensible Messaging and Presence Protocol)
- **IRC**
- **SSH** (Secure Shell)
- **STOMP** (Streaming Text Oriented Messaging Protocol)
- **SPDY** (): Multiplexed HTTP:
	- open an HTTP connection and can send several requests in parallel.
	- request priorization
	- compressed headers
	- server pushed streams

# Why Agile

Software engineering has failed during the past decades while trying to achieve:
- Reduce code
- Eliminate human errors
- Eliminate project variability

[Paolo](http://www.twitter.com/nusco) suggests using the scientific method when developing software:
- observation
- hypothesis
- experiment

Something that has become lately to the news as part of the [Lean Startup](http://en.wikipedia.org/wiki/Lean_Startup) approach.


# Lighting talks

Last, but not least, there has been ten lightings talks (5' each) about different stuff like graph databases and the new service by [aentos](http://www.aentos.com/en) called [GrapheneDB](http://graphendb.com)

# Warm up
Great speakers (Scott Chacon, Anthony Eden, Paolo Perrotta), great contents (API uniformity, Deconstructing the framework), cool people, and two new t-shirts for my ever growing collection.