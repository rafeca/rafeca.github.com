---
layout: post
title: Dynamic loading
categories: [python, django]
---

![Dynamic loading](/gfx/posts/dynamic-loading/most-interesing-man.png)

In the project I am working right now, we are reusing a Django project to develop two different products, productA and productB :-). These products frequently require the same service layer and the code can be directly reused, but in some scenarios different code is required.

Django project reusage gives us some advantages. Here I highlight some of them:

* authentication
* authorization
* logging
* URL routes
* testing strategy
* security tests
* third party integrations

Our current solution to run different logic in both products, instead of using project configuration, is **dynamic loading**. To implement it, we have defined our own code structure respecting Django default structure:

{% highlight bash %}

- django_project_root
  - django_app_1
    - __init__.py
    - services.py
    - projectA
       - __init__.py
       - services.py
    - projectB
       - __init__.py
       - sevices.py
  - django_app_2
    - __init__.py
    - services.py
    - projectB
      - __init__.py
      - services.py

{% endhighlight %}

If the Django application is running as projectA, the service logic being used is:
- for django_app_1 application, the module django_app_1.projectA.services
- for django_app_2 application, the module django_app_2.services (as django_app_2.projectA.services module is not created).

ProjectB has defined specific logic in both Django applications, and therefore no generic one is used.

Find underneath the snippet of code (simplified) we're using to know which module must be loaded:

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

Pretty simple. I'm trying to load a module, and if it fails, I'm logging a warning.
Sometimes the warning is the expected behavior (i.e. projectA does not define its own django_app_2 service logic), but it could also happen that an exception is raised while parsing a module code, and therefore the module cannot be imported (i.e. projectB django_app_2 service logic has a syntax error). Not logging this situation will hide possible undesired errors.

This is something that Django is not doing (at least in version 1.3.1) and caused me some paintful last Friday. This command:

{% highlight python %}

python manage.py collectstatic --settings=projectA_settings

{% endhighlight %}

generated the following result:

{% highlight python %}

Unknown command: 'collectstatic'

{% endhighlight %}

WTF! I was getting crazy as I was pretty sure the *django.contrib.staticfiles* app was installed in the projectA settings file. After some debugging I came out with the problem: Django is using dynamic loading, I had a missing dependency in a model module, and the projectA settings wasn't been loaded, therefore collectstatic was not a valid command.

# Conclusion

To sum up, be careful while dynamic loading your code and log any possible error that may raise during the process. I do, you and [Django](https://github.com/django/django/blob/master/django/utils/importlib.py) should too. Otherwise, weird errors will happen because the root of the problem is being hidden.

