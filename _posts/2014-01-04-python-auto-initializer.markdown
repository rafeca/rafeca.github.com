---
layout: post
title: "Building an automatic initializer in python"
categories: [python, scala]
---

One of the cool things of Scala is that, in general, you don't need to write a lot of boilerplate while doing things in the "normal way".

As an example, while defining a class which constructor requires one or more arguments, there's no need to assign the parameters to instance attributes, this is done out of the box by the compiler while creating the Java code:

{% highlight scala %}

class Foo(val x: String, val y: String)

val value = new Foo("bar", "bazz")
println(value.x)
//> bar

{% endhighlight %}

Python, like many other languages, does not behave that way, therefore you must assign the attributes to instance variables. Someone would argue that this is indeed the pythonic way to work, [making things as explicit as possible](http://www.python.org/dev/peps/pep-0020/). Letting aside that the method [\_\_init\_\_](http://docs.python.org/2/reference/datamodel.html#object.__init__) is not a constructor, you can do the assigment with the following snippet of code:

{% highlight python %}

class Foo(object):

    def __init__(self, x, y):
        self.x = x
        self.y = y

value = Foo("bar", "bazz")
print value.x
// bar

{% endhighlight %}

It turns out that a high percentage of the time, the only thing you may need to do in your \_\_init\_\_ methods is assigning the parameters to instance variables.  Being a common behavior, it seems to me like a nice chance to build a
[decorator](2012/07/24/why-python-rocks_and_two/) :smile_cat:. Here it goes:

{% highlight python %}

import inspect

def autoinit(fn):
    co_varnames = fn.func_code.co_varnames
    kwa_defaults = inspect.getargspec(fn).defaults

    def _wrap(*args, **kwargs):
        self, nargs = args[0], args[1:]
        names = co_varnames[1:len(nargs)+1]
        kwa_keys = co_varnames[len(nargs)+1:]
        nargs = dict((k, nargs[names.index(k)]) for k in names)
        # Add the keyword arguments
        for k in kwa_keys:
            nargs[k] = kwargs[k] if k in kwargs else kwa_defaults[kwa_keys.index(k)]

        # Set the values to the instance attributes
        for k, v in nargs.iteritems():
            setattr(self, k, v)

        return fn(*args, **kwargs)

    return _wrap

{% endhighlight %}

The function that builds the decorator (autoinit) is doing simple things:

- retrieve the parameter names and the default keyword parameter values
- build a function, which is the value returned by the function autoinit, which will inspect both args and kwargs while creating a new instance object, retrieve the actual value for every parameter, and assign them to instance attributes.

An usage example:

{% highlight python %}
class Foo(object):

    @autoinit
    def __init__(self, x, y, a=10, b=100):
        pass

f = Foo(1, 2, 4)

print f.x, f.y, f.a, f.b
// 1 2 4 10
{% endhighlight %}

