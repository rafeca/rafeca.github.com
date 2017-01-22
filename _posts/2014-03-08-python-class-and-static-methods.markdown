---
layout: post
title: "Class and static methods in python"
categories: [python]
---

Last week we had a nice conversation during a python code review about when class and static methods should be used, or either they should not be used at all.

Find below my opinions around this topic, feel free to comment and bring some discussion :satisfied:.

In general, you should think about **moving a class or static method to the module** that holds the class definition. As you may well know, functions are first class citizens in python:

{% highlight python %}

class Foo(object):

    VALUES = ('1', '2', '3')

    def __init__(self, bar):
        self.bar = bar

    @staticmethod
    def get_values():
        return VALUES

{% endhighlight %}

This snippet can be refactored to:

{% highlight python %}

def get_foo_values():
    return Foo.VALUES

class Foo(object):

    VALUES = ('1', '2', '3')

    def __init__(self, bar):
        self.bar = bar

{% endhighlight %}

Some exception that might apply:

* The class provides several staticmethod to validate attributes, retrieve class information, etc. Moving all these methods might fill up the module with too many definitions that are clearly tight to a specific class.

* The module holds several classes

* You want to define an *auxiliar method* to create an instance, and you want the childs to be able to override the initialization (think if you should use composition instead of inheritance!):

{% highlight python %}

PROPERTIES = {'name': 'john',
              'surname': 'doe',
              'age': 28,
              'email': 'john@pollinimini.net'}


class Foo(object):

    @classmethod
    def from_properties(cls, properties):
        ins = cls()
        for k, v in properties.iteritems():
            ins.k = v
        return ins

    def __str__(self):
        return ', '.join(self.__dict__.keys())


class Bar(Foo):

    @classmethod
    def from_properties(cls, properties):
        ins = super(Bar, cls).from_properties(properties)
        ins.deferred = True
        return ins

print Foo.from_properties(PROPERTIES)
print Bar.from_properties(PROPERTIES)

{% endhighlight %}

The output of the program is:

{% highlight bash %}

age, surname, name, email
deferred, age, surname, name, email

{% endhighlight %}

**Bar** includes an additional attribute to the instance, but the preliminar instance initilization is similar to what **Foo** does.

There are other alternatives to the class method in this case though:

* defining a **factory class** to return the proper class.

* define a function that receives as parameter a function to be applied while defining the instance:

{% highlight python %}

PROPERTIES = {'name': 'john',
              'surname': 'doe',
              'age': 28,
              'email': 'john@pollinimini.net'}


def create_foo_with_function(properties, func=None):
    ins = Foo.from_properties(properties)
    if func:
        func(ins)
    return ins


class Foo(object):

    @classmethod
    def from_properties(cls, properties):
        ins = cls()
        for (k, v) in properties.iteritems():
            ins.__setattr__(k, v)
        return ins

    def __str__(self):
        return ', '.join(self.__dict__.keys())


# Create a Foo instance
print create_foo_with_function(PROPERTIES)

# Create a Bar instance
print create_foo_with_function(PROPERTIES,
                               lambda ins: ins.__setattr__('deferred', True))

{% endhighlight %}

Happy coding! :kissing_cat:
