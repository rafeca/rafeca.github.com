---
layout: post
title: "Hanoi. Toggle functionalities in python"
categories: [python, a/b testing, controlled deployment]
---

Upon deploying a new version of your product into production,
 it's usually handy to enable the new functionalities only to
 a subset of users. This allows to measure the impact of your
 code changes in a controlled way:

* Does the new functionality have an *unexpected impact in
  server performance* that was not detected in stress testing lab?
* Is the new functionality *increasing session duration*, global
  product usage, *customer satisfaction*, etc?
* Whas is the impact on the client side? Is it creating a
  battery drain or any other unexpected issue?

Feature toggling can be handy as well to *reduce the impact of
 dependencies among components*. If a new functionality in *component A*
 requires a new version of *component B*, the new functionality in
 component A can be toggle off till the new B version reaches production,
 then the **deployment pipeline is loosely coupled**.

Over my last Christmas holidays I spent some time visiting Vietnam,
 and back then I read about [rollout gem](https://github.com/FetLife/rollout),
 a ruby library that implements feature toggling using Redis as backend.
 [proclaim](https://github.com/asenchi/proclaim) python port is kind
 of outdated so I decided to build another python port, that has been
 named as [hanoi](https://github.com/juandebravo/hanoi).

**Hanoi** can be used for the following scenarios:

1. Enable/disable globally a functionality (toggle on/off)
1. Enable a functionality to a percentage of users, increasing
   the percentage gradually to ensure server and client behaviour.
1. Enable a functionality to specific users (whitelist users)

Currently three BackEnd are implemented (a memory based backend and
 REDIS backend in two different flavors). My expectation is to
 include additional BackEnds in the future to support additional
 storages, such as [memcached](http://memcached.org/)
 and [mongoDB](http://www.mongodb.org/).

For additional information about hanoi check the documentation in the [github repository]).

Happy deploying! :hammer:

![Hanoi](/gfx/hanoi.jpg)
