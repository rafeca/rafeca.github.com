---
layout: post
title: Things I like using python
categories: [python]
---

# Introduction

During last months I've been spending few hours everyday coding python. Not only it's been my first experience in a real project, before this stage I hadn't dropped a single line of python. That's why the former weeks were really hard for me to get things done. During the previous two years I had been coding ruby all the time, so coming outside the comfort zone made me felt myself really improductive.

That time (my feeling about being improductive) fortunately is over, still I cannot think of myself as an expert in python, but I feel comfortable in this environment though.

I would like to emphasize what are my favourites python features and know your thoughts about them and something that probably I'm missing. I'm just talking about python and in some cases comparing with ruby, every point I'm talking about deserves IMO a dedicated post, just take this as a summary of the things I like more.

# List comprehensions

```python
users = [{'name': 'John Doe', 'email': 'john@doe.com'},
		 {'name': 'Mike Cunhingam', 'email': 'mike@cunhingam.com'}]

# Retrieve users email
emails = [user['email'] for user in users]
```

Of course something similar can be done in ruby, but after some weeks I felt comfortable with the idea or iterate over objects in an array without calling a specific object method:

```ruby
users = [{name: 'John Doe', email: 'john@doe.com'},
		 {name: 'Mike Cunhingam', email: 'mike@cunhingam.com'}]

# Retrieve users email
emails = users.map{|x| x[:email]}
```

List comprehensions can be used with any iterable object, as strings and arrays instances.

# Generators

# Decorators

With decorators you can change any function behavior just adding annotations above the function definition. I was seeking an example about how to log the parameters being received in a method call, and I found [this implementation in python.org site](http://wiki.python.org/moin/PythonDecoratorLibrary#Easy_Dump_of_Function_Arguments):

```python
def dump_args(func):
    "This decorator dumps out the arguments passed to a function before calling it"
    argnames = func.func_code.co_varnames[:func.func_code.co_argcount]
    fname = func.func_name

    def echo_func(*args,**kwargs):
        print fname, ":", ', '.join(
            '%s=%r' % entry
            for entry in zip(argnames,args) + kwargs.items())
        return func(*args, **kwargs)

    return echo_func

@dump_args
def f1(a,b,c):
    print a + b + c

f1(1, 2, 3)
``


# Use blank spaces to define code blocks
