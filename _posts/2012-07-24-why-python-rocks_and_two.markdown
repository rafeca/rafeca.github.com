---
layout: post
title: Things I like using python (part II)
categories: [python]
---

# Introduction

Here it goes my second and last post on the "things that I like about coding in python" serie in which was missing a small section on how cool these features (below) are:

* Decorators
* Context managers
* Use blank spaces to define code blocks

# Decorators
A decorator is a function that takes at least an argument, a function object, and returns a single value, a function object. It's commonly used to, taking advantage of python closures support, add new features to the original function object (the one received as argument).

[Decorators were defined in PEP 318](http://www.python.org/dev/peps/pep-0318/) as a way to ease the definition of class and static methods.

Before decorators reached python, the following excerpt was needed to create a class/static method:

{% highlight python %}

class Foo(object):
    
    def bar(self, name):
        return "Hello {0} from my class method".format(name)

    def bazz(name):
        return "Hello {0} from my static method".format(name)
    
    # Convert bar from instance to class method
    bar = classmethod(bar)
    
    # Create a static method
    bazz = staticmethod(bazz)

if __name__ == '__main__':
    print Foo.bar('John Doe')
    print Foo.bazz('John Doe')

{% endhighlight %}

Reminder: the main difference between static and class methods is that a class method can be overriden by a child, which is not true for a static method. Also a class method needs the class object as first parameter in the method definition. At this point, I don't find a good reason to define a static method though.

Using decorators and its syntax sugar (the **@** symbol), the previous excerpt can be re-written to:

{% highlight python %}
class Foo(object):
    
    # Define bar as a class method
    # As first parameter we could use 'self', but the facto standard is to use 'cls' while
    # defining class methods
    @classmethod
    def bar(cls, name):
        return "Hello {0} from my class method".format(name)

    # Define bazz as a static method
    @staticmethod
    def bazz(name):
        return "Hello {0} from my static method".format(name)
    
if __name__ == '__main__':
    print Foo.bar('John Doe')
    print Foo.bazz('John Doe')
{% endhighlight %}

The best blog post explaining decorators I've found so far is [this one from Steve Ferg](http://pythonconquerstheuniverse.wordpress.com/2012/04/29/python-decorators). I find decorators quite useful when you need transversal functionalities in your code. A set of examples can be found in [wiki.python.org](http://wiki.python.org/moin/PythonDecoratorLibrary).

### Example

The following code creates a decorator that dumps the arguments that a function/method receives when executed. The base of that code is taken from [wiki.python.org#Easy_Dump_Of_Function_Arguments](http://wiki.python.org/moin/PythonDecoratorLibrary#Easy_Dump_of_Function_Arguments).

{% highlight python %}

# decorator_utils.py

import logging

logging.basicConfig(level=logging.DEBUG)

def dump_args(func):
    # get function arguments name
    argnames = func.func_code.co_varnames[:func.func_code.co_argcount]

    # get function name
    fname = func.func_name
    logger = logging.getLogger(fname)

    def echo_func(*args, **kwargs):
        """
        Log arguments, including name, type and value
        """
        def format_arg(arg):
            return '%s=%s<%s>' % (arg[0], arg[1].__class__.__name__, arg[1])
        logger.debug(" args => {0}".format(', '.join(
            format_arg(entry) for entry in zip(argnames, args) + kwargs.items())))
        return func(*args, **kwargs)

    return echo_func

# example.py

from decorator_utils import dump_args

class UserModel(object):
    """
    User model object
    """

    def __init__(self, user_id=None):
        self.user_id = user_id

    @classmethod
    @dump_args
    def find_by_id(cls, user_id):
        pass

    @dump_args
    def update(self, **kwargs):
        pass

    def __str__(self):
        return unicode(self).encode('utf-8')

    def __unicode__(self):
        return str(self.user_id)


@dump_args
def f1(user_id, arg1, arg2, **kwargs):
    pass


if __name__ == '__main__':
    UserModel.find_by_id('foo')

    u = UserModel('879234-32423423')
    u.update(name="John", surname="Doe")
    f1(u, 2, 3)

    f1(u, 2, 3, foo='bazz', bar=23)

{% endhighlight %}

The execution of the previous code generates the following output:

{% highlight bash %}

λ python example.py

DEBUG:find_by_id: args => cls=type<<class '__main__.UserModel'>>, user_id=str<foo>
DEBUG:update: args => self=UserModel<879234-32423423>, surname=str<Doe>, name=str<John>
DEBUG:f1: args => user_id=UserModel<879234-32423423>, arg1=int<2>, arg2=int<3>
DEBUG:f1: args => user_id=UserModel<879234-32423423>, arg1=int<2>, arg2=int<3>, foo=str<bazz>, bar=int<23>

{% endhighlight %}

As it's shown above (method *find_by_id*), you can use more than one decorator in a function/method (and are executed bottom-up).

# Context managers (**with** statement)

A context manager allows you to create and manage a run time context. It is created when starting a **with** statement, it's available during the code execution inside the *with* block, and is exited at the end of the *with* code. The most commonly used scenario is while **allocating resources**: a context manager ensures you use the resource only while it's actually required and deallocates it when it should not be used anymore (of course python needs you to write the code properly for that if you are defining your own context manager).

The basic example using python native library to handle a file object:

{% highlight python %}

with open('/var/log/events.log', 'w') as f:
    n = f.write("New user created")

{% endhighlight %}

The file */var/log/events.log* is opened when entering into the context manager, and closed when the code block is finished. You don't need to catch exceptions, close the file, etc.

To create a context manager you need to define a class that implements two methods, **__enter__** and **__exit__**. In the following code I'm creating a context manager, *user*, that retrieves an object from an external source and stores it back if updated:

{% highlight python %}

class User(dict):
    """
    Database object
    """
    def __init__(self, user_id, **kwargs):
        self.user_id = user_id
        self.update(kwargs)

    def has_changed(self):
        # logic to check if any user property has been updated
        return True

class user(object):
    """
    Context manager for a User object
    """

    def __init__(self, user_id):
        self.user_id = user_id

    def __enter__(self):
        """
        This code block is executed while entering a context manager
        """
        # mock that returns always a basic User
        self.user = User(self.user_id, name="John", surname="Doe")
        return self.user

    def __exit__(self, _type, value, tb):
        """
        This code block is executed at context manager exit
        """
        if self.user.has_changed():
            # here the save logic
            pass

if __name__ == '__main__':
    with user('00000-11111') as u:
        u['name'] = 'Johnny'


{% endhighlight %}

Switching to ruby, something similar can be achieved with the following snippet:

{% highlight ruby %}

class User < Hash
  attr_reader :user_id
  
  def initialize(user_id, params = {})
    @user_id = user_id
    self.update(params) if params.length > 0
    if block_given?
      yield self
      if self.has_changed?
        # here the save logic
      end
    end
  end
  
  def has_changed?
    # logic to check if any user property has been updated
    return True
  end
  
  class << self
    def find!(user_id)
      # mock that returns always a basic User instance
      if block_given?
        User.new(user_id, {name:"John", surname:"Doe"}, &Proc.new)
      else
        User.new(user_id, {name:"John", surname:"Doe"})
      end
    end
  end
end

User.find!('0000-1111') do |u|
  u[:name] = "Johnny"
end

{% endhighlight %}

# Use blank spaces to define code blocks
Not too much to say about this. I thinks it increases readability.

# Conclusion
I hope you've found these articles interesting. I'm sure some good points, like functions being first-class citizens or the collections and functools modules, are missing but at this point I just wanted to highlight my five coolest features. Let me know which are yours so my top five list could easily be "re-prioritized" :-)