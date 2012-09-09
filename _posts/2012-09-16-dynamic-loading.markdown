---
layout: post
title: Dynamic loading
categories: [python, django]
---

I usually don't use dynamic loading, but when I do, I log carefully any possible error that may raise while loading a specific file.

In my current project we are reusing a Django project to run two different products, productA and productB. These two products requires the same service logic often, but in some scenarios we need to write different code.

We're getting some advantages by reusing the Django project, I list some of them below:

* authentication
* authorization
* logging
* URL routes
* testing strategy
* security tests
* third party integrations

Instead of using project configuration, our current solution to run different logic in both products is dynamic loading. To implement it, we have defined our own code structure trying to respect the Django default structure:

{% highlight bash %}

- django_project_root
  - django_app_1
    - services.py
    - projectA
       - services.py
    - projectB
       - sevices.py
  - django_app_2
    - services.py
    - projectB
      - services.py

{% endhighlight %}

When the Django application is running as projectA, the service logic being used is:
- for django_app_1 application, the module django_app_1.projectA.services
- for django_app_2 application, the module django_app_2.services (as django_app_2.projectA.services module is not created).

ProjectB defines in both django applications specific logic, and therefore no generic one is used.

To know which module must be loaded, we're using the following snippet of code (simplified):

{% highlight python %}

def get_module(application_name, project, module):
    try:
        module_name = application_name + '.' + project + '.' + module
        return __import__(module_name)
    except ImportError as ex:
        logger.warn("Unable to import module: {0} -> {1}".format(module_name, ex))
        return __import__(application_name + '.' + module)

# Example

get_module('django_app_1', 'projectA', 'services')

{% endhighlight %}

Pretty simple. I'm trying to load a module, and if it fails, I'm logging a warning. Sometimes it's an expected behavior (projectA does not define its own django_app_2 service logic), but also it may happen that while parsing a module code, an exception is raised and the module cannot be imported (i.e. projectB django_app_2 service logic has a syntax error). Not logging this situation will hide possible undesired errors.

This is something that Django is not doing (at least in version 1.3.1) and caused me some paintful last Friday. I was running:

{% highlight python %}

python manage.py collectstatic --settings=projectA_settings

{% endhighlight %}

and getting as result:

{% highlight python %}

Unknown command: 'collectstatic'

{% endhighlight %}

WTF! I was getting crazy as I was pretty sure the *django.contrib.staticfiles* app was installed in the projectA settings file. After some debugging I came out with the problem: Django is using dynamic loading, I had a missing dependency in a model module, and the projectA settings wasn't been loaded, therefore collectstatic was not a valid command.

I usually don't use dynamic loading, but when I do, I log carefully any possible error the program raises while loading a specific file. You and Django should too.

{% highlight python %}
# django/utils/importlib.py

def import_module(name, package=None):
    """Import a module.

    The 'package' argument is required when performing a relative import. It
    specifies the package to use as the anchor point from which to resolve the
    relative import to an absolute import.

    """
    if name.startswith('.'):
        if not package:
            raise TypeError("relative imports require the 'package' argument")
        level = 0
        for character in name:
            if character != '.':
                break
            level += 1
        name = _resolve_name(name[level:], package, level)
    __import__(name)
    return sys.modules[name]

{% endhighlight %}
