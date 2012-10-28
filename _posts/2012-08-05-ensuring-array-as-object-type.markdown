---
layout: post
title: Ensuring Array as object type
categories: [python, ruby]
---

It happens often that you need an array as object type, and even if you have defined your API like that, you still want to double check that the parameter received in your method is an array:

{% highlight ruby %}

def foo(param)
  param = Array[param] if !param.is_a?(Array)
  # Service logic here
end

{% endhighlight %}

Fortunalety in ruby you have the following feature that converts your parameter to an array, or does nothing in case it is already an array:

{% highlight ruby %}

def foo(param)
  param = Array(param)
end

{% endhighlight %}

This feature does not exist in python, or I haven't found it though.

The following snippet covers that funcionality:

{% highlight python %}

# list_utils.py

def list_(values, *more_values):
    """
    Creates a list using one or more elements.
    If the parameter is a list, do nothing
    """
    if not isinstance(values, list):
        values = [values]
    if len(more_values) > 0:
        values.extend(more_values)
    return values

{% endhighlight %}

Example:

{% highlight python %}

from list_utils import list_

def send_mail(destinations, *args, *kwargs):
    destinations = list_(destinations)

    for destination in destinations:
        # your service logic

{% endhighlight %}


You can check the behavior with the following chunk of unit tests:

{% highlight python %}

import unittest

from list_utils import list_

class ListTests(unittest.TestCase):

    def test_parameter_is_a_string(self):
        self.assertEquals(list_("foo"), ["foo"])

    def test_parameter_is_an_array(self):
        self.assertEquals(list_(["foo"]), ["foo"])

    def test_parameter_is_an_integer(self):
        self.assertEquals(list_(1), [1])

    def test_parameter_is_a_list_with_multiple_elements(self):
        self.assertEquals(list_([1,2,3,4]), [1,2,3,4])

    def test_parameter_is_multiple(self):
        self.assertEquals(list_(1,2,3,4), [1,2,3,4])

    def test_parameter_is_none(self):
        self.assertEquals(list_(None), [None])

if __name__ == '__main__':
    unittest.main()

{% endhighlight %}