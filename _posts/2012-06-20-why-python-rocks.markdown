---
layout: post
title: Things I like using python
categories: [python]
---

# Introduction

[As you know](2012/06/26/git-tip-how-to-change-the-branch-of-a-commit/) these lasts months I've sepnt quite some time coding python, the language chosen for the project to which I've devoted heart, soul and most of my weekends too...

During the first weeks I really struggled to get the code alive as during the previous two years it was all bout ruby, so python has taken me out of my comfort zone which really hit me. Although I cannot call myself a python expert (yet), I'm enjoying this new friendship.

# Things I like using python

I'm going to share some of my favourites features and I'd like to know yours, yours thoughts about them and any missed bit that may be key:

* List comprehensions
* Generators
* Decorators
* Use blank spaces to define code blocks
* Context managers

Find below a brief description and example about the first two dots.

# List comprehensions

As python doc says, ["list comprehensions provide a concise way to create lists"](http://docs.python.org/tutorial/datastructures.html#list-comprehensions).

### Example
```python
users = [{'name': 'John Doe', 'email': 'john@doe.com'},
		 {'name': 'Mike Cunhingam', 'email': 'mike@cunhingam.com'}]

# Retrieve users email
emails = [user['email'] for user in users]
```

Of course something similar can be done in ruby, but after some weeks I felt comfortable with the idea of iterate over objects in an array without calling a specific object method:

```ruby
users = [{name: 'John Doe', email: 'john@doe.com'},
		 {name: 'Mike Cunhingam', email: 'mike@cunhingam.com'}]

# Retrieve users email
emails = users.map{|x| x[:email]}
```

List comprehensions can be used with any iterable object, as strings and arrays instances.

# Generators

Again reading through python docs, ["generators are a simple and powerful tool for creating iterators"](http://docs.python.org/tutorial/classes.html#generators), covered in [PEP255](http://www.python.org/dev/peps/pep-0255/). Generators may be used when you need to maintain state between values produced and allows you to avoid callback functions.

Let's imagine that [Github API](http://developer.github.com) only allows to download an user gist per API call. In the example below we're using a generator to create an iterator over user gists. To retrieve an user gist we're maintainng the state between calls (the current page) and we're retrieving the data only when is actually needed. Of course another approach could be to retrieve a chunk of gists and return them upon request, but it seems a good example about how to use generators :-)

{% include "gist" with "1474101" %}

To be continued...
