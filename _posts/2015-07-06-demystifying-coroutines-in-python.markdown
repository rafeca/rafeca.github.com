---
layout: post
title: "Demystifying coroutines in python"
categories: [python]
---

[Coroutines](http://en.wikipedia.org/wiki/Coroutine) are *special functions* that differ from *usual ones* in four aspects:

* **exposes several entry points to a function**. An entry point is the line of code inside the function where it will take control over the execution.
* **can receive a different input** in every entry point while executing the coroutine.
* can **return different outputs** as response to the different entry points.
* can **save control state** between entry points calls.

**Python implements coroutines starting in *Python 2.5* by reusing the generator syntax**, as defined in [PEP 342 - Coroutines via Enhanced Generators](https://www.python.org/dev/peps/pep-0342/).

Generator syntax is defined in [PEP 255 - Simple generators](https://www.python.org/dev/peps/pep-0255/). I covered briefly the generator functionality in a [previous post](/2012/07/16/why-python-rocks/). The basic usage of generators is creating an iterator over a data source. For example, the function in the snippet below returns a generator that iterates from a specific number down to 0, decreasing an unit in every iteration.

{% highlight python %}
def countdown(n):
    print "Counting down from %s to 0" % n
    i = n
    while i >= 0:
        yield i
        i = i - 1
{% endhighlight %}

{% highlight bash %}
>>> for i in countdown(5):
>>>     print i
...
Counting down from 5 to 0
5
4
3
2
1
0
{% endhighlight %}

In the example above, the keyword **yield** is used to return a new value in every iteration while *consuming* the generator. It's interesting to note that *a generator can be consumed only once*, opposite to a list that can be consumed/iterate as much as needed. A generator is considered *exhausted* upon being consumed the first time.


**[PEP 342](https://www.python.org/dev/peps/pep-0342/)** takes advantage of the keyword **yield** for pointing out entry points where the function/coroutine will receive inputs while being executed. Let's see a very simple example of a coroutine that
concatenates every string inserted by the user from the command line:

{% highlight python %}
def concatenate(_str):
    """
    Coroutine that receives a new string in every
    iteration and concatenates to the original one
    """
    temp = None

    while temp != '':
        # Wait for a new input (suspend the coroutine)...
        temp = yield
        # ... and save control state (resume the execution)
        _str += temp
        print _str

# Instantiate a new coroutine...
a = concatenate('foo')

# ... and "move" the coroutine state till the `yield` keyword
a.next()

while True:
    try:
        # Send the raw input from the user to the coroutine...
        a.send(raw_input())
    except StopIteration:
        # ... and capture the coroutine end by means
        # of StopIteration exception
        break

{% endhighlight %}

What is really interesting is how the coroutine execution is suspended and resumed by means of the
**yield** keyword, allowing the program flow to be moved from the coroutine to the external program
and back to it.

{% highlight bash %}

python coroutine.py
bar
    foobar
bazz
    foobarbazz

    foobarbazz

{% endhighlight %}

May you be interested in additional information about this topic, I recommend going through [Daviz Beazley](http://www.dabeaz.com/) slides regarding [generators](http://www.dabeaz.com/generators/Generators.pdf) and [coroutines](http://www.dabeaz.com/coroutines/Coroutines.pdf).

As a side project I have implemented a tiny library called **[washington](https://github.com/juandebravo/washington)** that exposes a chainable API for building a coroutines stream. I had a lot of fun while digging into the implementation, even though the real usage of the library is expected to be very limited :blush:

Happy coroutining!!! :bicyclist: :fireworks:
