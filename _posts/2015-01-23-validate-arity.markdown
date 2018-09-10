---
layout: post
title: "Validating Arity in JavaScript"
categories: [javascript]
---

Last week I was discussing with my pals [@drslump](http://www.pollinimini.net)
 and [@ladybenko](http://www.ladybenko.net/) about a very simple idea I came up
 with while reading [John Resig](http://ejohn.org/about/)
 [Secrets of the JavaScript Ninja](http://ejohn.org/blog/secrets-of-the-javascript-ninja-released/) book on Christmas holidays.

The idea is very simple: ensure that a function is called with the expected number of parameters.

A function defined like:

{% highlight javascript %}
var fullName = function fullName (name, surname) {
    return name + ' ' + surname;
};
{% endhighlight %}

could be called with:

* **zero parameters**: *name* and *surname* will be undefined.
* **one parameter**: the parameter will be assigned to *name*, *surname* will be undefined.
* **two parameters**: the former parameter will be assigned to *name*, the latter to *surname*.
* **three or more parameters**: the first two parameters will be assigned to *name* and *surname* respectively, the next ones could be accessed via `arguments`.

You might want to ensure the function is always called with two parameters, so scenarios like this one won't happen:

{% highlight javascript %}
fullName("Foo");
'Foo undefined'
{% endhighlight %}

Let's do the magic by defining a method in the `Function prototype`:

{% highlight javascript %}
Function.prototype.validateArity = function validateArity () {
    var fn = this;
    return function () {
        if (arguments.length === fn.length) {
            return fn.apply(this, arguments);
        } else {
            throw new Error("Arity was <"+arguments.length+"> but expected <"+fn.length+">");
        }
    };
};
{% endhighlight %}

Simply adding to our previous function the following:

{% highlight javascript %}
var fullName = function fullName (name, surname) {
    return name + ' ' + surname;
}.validateArity();

// Correct call
console.log(fullName("Foo", "Bar"));
Foo Bar

// Incorrect call
console.log(fullName("Foo"));
Error: Arity was <1> but expected <2>
{% endhighlight %}

**Protip**: adding a function to `Function prototype` is usually NOT a good idea.
